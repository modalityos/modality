#!/usr/bin/env bash
# Remove the test VM made by tools/vm/create.sh: the libvirt domain "modality-dev" with
# its UEFI variables, its disk and its address reservation. Nothing else is touched.
#
#   tools/vm/destroy.sh
set -euo pipefail

# These must match tools/vm/create.sh.
domain=modality-dev
uri=qemu:///system
pool=default
volume=$domain.qcow2
network=default
mac=52:54:00:4d:44:50
ip=192.168.122.50

case ${1:-} in
    "") ;;
    -h | --help) sed -n '2,5p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "destroy.sh: unknown argument: $1" >&2; exit 2 ;;
esac

virsh() { command virsh --connect "$uri" "$@"; }

if virsh dominfo "$domain" >/dev/null 2>&1; then
    if [[ $(virsh domstate "$domain") != "shut off" ]]; then
        virsh destroy "$domain" >/dev/null
    fi
    virsh undefine "$domain" --nvram >/dev/null
    echo "Removed domain $domain"
else
    echo "No domain $domain"
fi

if virsh vol-info --pool "$pool" "$volume" >/dev/null 2>&1; then
    virsh vol-delete --pool "$pool" "$volume" >/dev/null
    echo "Removed disk $pool/$volume"
else
    echo "No disk $pool/$volume"
fi

# Only the exact entry create.sh adds is deleted.
host="<host mac='$mac' name='$domain' ip='$ip'/>"
if virsh net-dumpxml "$network" | grep -qF "$host"; then
    virsh net-update "$network" delete ip-dhcp-host "$host" --live --config >/dev/null
    echo "Removed the reservation of $ip on network $network"
else
    echo "No reservation for $domain on network $network"
fi

# The VM's host key dies with it; a rebuild at the same address gets a new one.
[[ -f $HOME/.ssh/known_hosts ]] && ssh-keygen -R "$ip" >/dev/null 2>&1 || true
