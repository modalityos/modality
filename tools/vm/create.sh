#!/usr/bin/env bash
# Create the test VM, libvirt domain "modality-dev", from Arch's official cloud image.
#
#   tools/vm/create.sh [--ssh-key FILE.pub]
#
# The VM gets user "dev" with passwordless sudo, the given SSH public key (default: the
# first key in ssh-add -L), rsync, and the fixed address 192.168.122.50 on libvirt's
# "default" network. It prints the MODALITYOS_VM line for just deploy when SSH is ready.
# The image is pinned to one release and checked against its SHA256; packages installed
# on top are current Arch. Remove the VM with tools/vm/destroy.sh.
set -euo pipefail

# Pinned arch-boxes release. To move it, take a newer vYYYYMMDD.BUILD folder from the
# mirror and copy its .SHA256 here after checking the .SHA256.sig.
image_release=20261001.604814
image_sha256=360f0fa49db6813bdc8e35bed230a2dc2ae3567b7b5ab74719c0a706e4e34e87
image_name=Arch-Linux-x86_64-cloudimg-$image_release.qcow2
image_url=https://geo.mirror.pkgbuild.com/images/v$image_release/$image_name

domain=modality-dev
uri=qemu:///system
pool=default
volume=$domain.qcow2
disk_size=40G
network=default
mac=52:54:00:4d:44:50
ip=192.168.122.50
memory_mib=16384
vcpus=8
user=dev

usage() {
    sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

die() {
    echo "create.sh: $*" >&2
    exit 1
}

ssh_key=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --ssh-key) [[ $# -ge 2 ]] || usage 2; ssh_key=$2; shift 2 ;;
        -h | --help) usage ;;
        *) echo "create.sh: unknown argument: $1" >&2; usage 2 ;;
    esac
done

virsh() { command virsh --connect "$uri" "$@"; }
# virt-install is a Python script run through env; a user Python (pyenv, mise) lacks its
# gi module, so it runs against the system Python.
virt_install() { PATH=/usr/bin:$PATH virt-install --connect "$uri" "$@"; }

for tool in virsh virt-install qemu-img xorriso curl sha256sum ssh; do
    command -v "$tool" >/dev/null || die "$tool is missing; see docs/vm.md for the packages"
done
virsh uri >/dev/null 2>&1 || die "cannot reach $uri; is libvirtd running and are you in the libvirt group?"

if virsh dominfo "$domain" >/dev/null 2>&1; then
    die "domain $domain already exists; remove it first with: just vm-destroy"
fi
if virsh vol-info --pool "$pool" "$volume" >/dev/null 2>&1; then
    die "disk $pool/$volume already exists (left from an earlier run); remove it with: just vm-destroy"
fi
[[ $(virsh net-info "$network" 2>/dev/null | awk '/^Active:/ {print $2}') == yes ]] ||
    die "libvirt network $network is not active; start it with: sudo virsh net-start $network"

# The public key goes into the VM; only its shape is checked, never printed.
if [[ -n $ssh_key ]]; then
    [[ -r $ssh_key ]] || die "cannot read $ssh_key"
    pubkey=$(head -n 1 "$ssh_key")
else
    pubkey=$(ssh-add -L 2>/dev/null | head -n 1) || true
    [[ -n $pubkey ]] || die "no key in ssh-add -L; pass --ssh-key FILE.pub"
fi
[[ $pubkey =~ ^(ssh-|ecdsa-|sk-) ]] || die "not an SSH public key: ${ssh_key:-the first key in ssh-add -L}"

# Reserve the fixed address for the domain's MAC, once.
net_xml=$(virsh net-dumpxml "$network")
if grep -q "mac='$mac'" <<<"$net_xml"; then
    grep -q "mac='$mac'[^>]*ip='$ip'" <<<"$net_xml" ||
        die "network $network reserves another address for $mac; run just vm-destroy"
    echo "Address reservation for $ip already in place"
else
    grep -q "ip='$ip'" <<<"$net_xml" && die "network $network already reserves $ip for another host"
    if virsh net-dhcp-leases "$network" | grep -v -i "$mac" | grep -q " $ip/"; then
        die "$ip is leased to another machine on network $network"
    fi
    virsh net-update "$network" add-last ip-dhcp-host \
        "<host mac='$mac' name='$domain' ip='$ip'/>" --live --config >/dev/null
    echo "Reserved $ip for $domain on network $network"
fi

# Download and verify the pinned image once; later runs reuse the cache.
cache=${XDG_CACHE_HOME:-$HOME/.cache}/modalityos/vm
image=$cache/$image_name
mkdir -p "$cache"
verify_image() { echo "$image_sha256  $image" | sha256sum --check --status; }
if [[ -f $image ]] && ! verify_image; then
    echo "Cached image fails its checksum; downloading it again"
    rm -f "$image"
fi
if [[ ! -f $image ]]; then
    echo "Downloading $image_name"
    curl --fail --location --progress-bar --output "$image.part" "$image_url"
    mv "$image.part" "$image"
    verify_image || { rm -f "$image"; die "downloaded image fails its SHA256 check"; }
fi
echo "Image $image_name verified"

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

# The VM's disk is a full copy, grown to $disk_size, uploaded into libvirt's pool so
# no root access is needed. The cloud image grows its root filesystem on first boot.
qemu-img convert -O qcow2 "$image" "$work/disk.qcow2"
qemu-img resize -q "$work/disk.qcow2" "$disk_size"
virsh vol-create-as "$pool" "$volume" "$disk_size" --format qcow2 >/dev/null
virsh vol-upload --pool "$pool" "$volume" "$work/disk.qcow2"
virsh pool-refresh "$pool" >/dev/null

cat >"$work/user-data" <<EOF
#cloud-config
hostname: $domain
users:
  - name: $user
    groups: [wheel]
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    shell: /bin/bash
    lock_passwd: true
    ssh_authorized_keys:
      - $pubkey
# A full upgrade before installing anything, so no package is a partial upgrade.
package_upgrade: true
packages: [rsync]
EOF
cat >"$work/meta-data" <<EOF
instance-id: $domain
local-hostname: $domain
EOF

# Specs match the project's reference test VM; the firmware is OVMF without Secure Boot,
# since the cloud image is not signed.
virt_install \
    --name "$domain" \
    --osinfo archlinux \
    --memory "$memory_mib" \
    --vcpus "$vcpus" \
    --cpu host-passthrough \
    --boot uefi,firmware.feature0.name=secure-boot,firmware.feature0.enabled=no,firmware.feature1.name=enrolled-keys,firmware.feature1.enabled=no \
    --import \
    --disk "vol=$pool/$volume,bus=virtio,discard=unmap" \
    --network "network=$network,model=virtio,mac=$mac" \
    --graphics spice,listen=none,gl.enable=no \
    --graphics egl-headless \
    --video virtio,model.acceleration.accel3d=yes \
    --channel spicevmc \
    --cloud-init "user-data=$work/user-data,meta-data=$work/meta-data" \
    --noautoconsole

# A rebuilt VM has new host keys at the same address, so drop the old entry.
[[ -f $HOME/.ssh/known_hosts ]] && ssh-keygen -R "$ip" >/dev/null 2>&1 || true

ssh_opts=(-o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new)
private_key=${ssh_key%.pub}
if [[ -n $ssh_key && $private_key != "$ssh_key" && -r $private_key ]]; then
    ssh_opts+=(-o IdentitiesOnly=yes -i "$private_key")
fi

echo "Waiting for $domain to boot and open SSH on $ip"
for ((i = 0; i < 120; i++)); do
    (exec 3<>"/dev/tcp/$ip/22") 2>/dev/null && break
    sleep 5
done
(exec 3<>"/dev/tcp/$ip/22") 2>/dev/null || die "no SSH on $ip after 10 minutes; see docs/vm.md, Troubleshooting"

# cloud-init adds the user and key shortly after sshd starts, so retry a few times.
for ((i = 0; ; i++)); do
    ssh "${ssh_opts[@]}" -o BatchMode=yes "$user@$ip" true 2>/dev/null && break
    ((i < 24)) || die "SSH to $user@$ip failed; see docs/vm.md, Troubleshooting"
    sleep 5
done

echo "Waiting for cloud-init to finish (a full system upgrade)"
# Exit status 2 means done with recoverable errors; the status line says which.
status=0
ssh "${ssh_opts[@]}" "$user@$ip" cloud-init status --wait --long || status=$?
((status == 0 || status == 2)) || die "cloud-init failed in $domain; see docs/vm.md, Troubleshooting"

echo
echo "$domain is ready. To deploy into it:"
echo "  export MODALITYOS_VM=$user@$ip"
