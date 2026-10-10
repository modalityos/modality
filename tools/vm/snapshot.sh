#!/usr/bin/env bash
# Save and restore the test VM, libvirt domain "modality-dev", as named snapshots of its disk.
#
#   tools/vm/snapshot.sh take NAME "DESCRIPTION"
#   tools/vm/snapshot.sh list
#   tools/vm/snapshot.sh revert NAME
#   tools/vm/snapshot.sh delete NAME
#
# take shuts the VM down cleanly, snapshots it and starts it again; revert puts the disk
# back and boots the VM, waiting for SSH. tools/vm/create.sh takes "initial" during a build.
# NAME is letters, digits, ".", "_" and "-", starting with a letter or digit.
set -euo pipefail

# The VM's 3D graphics (virgl) cannot be saved, so libvirt refuses snapshots of it running:
# each snapshot is of the VM shut off, an internal snapshot kept inside its qcow2 disk.

# These must match tools/vm/create.sh.
domain=modality-dev
uri=qemu:///system
target=${MODALITYOS_VM:-dev@192.168.122.50}

usage() {
    sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}
die() {
    echo "snapshot.sh: $*" >&2
    exit 1
}

virsh() { command virsh --connect "$uri" "$@"; }

valid_name() {
    [[ $1 =~ ^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$ ]] || die "not a valid snapshot name: $1"
}

require_domain() {
    virsh dominfo "$domain" >/dev/null 2>&1 || die "no domain $domain; build it with: just vm-create"
}

require_snapshot() {
    virsh snapshot-info "$domain" "$1" >/dev/null 2>&1 || die "no snapshot $1; see: just vm-snapshots"
}

# One field of a snapshot's XML as plain text; empty if it has none.
snapshot_field() {
    local text
    text=$(virsh snapshot-dumpxml "$domain" "$1" --xpath "/domainsnapshot/$2/text()" 2>/dev/null) || true
    text=${text//&lt;/<} text=${text//&gt;/>} text=${text//&quot;/\"} text=${text//&apos;/\'}
    echo "${text//&amp;/"&"}"
}

shut_off() { [[ $(virsh domstate "$domain") == "shut off" ]]; }

wait_for_ssh() {
    echo "Waiting for $domain to boot and open SSH"
    for ((i = 0; i < 60; i++)); do
        ssh -o ConnectTimeout=5 -o BatchMode=yes "$target" true 2>/dev/null && return 0
        sleep 3
    done
    die "no SSH to $target after 3 minutes; open the console in virt-manager"
}

[[ $# -ge 1 ]] || usage 2
action=$1
shift

case $action in
    take)
        [[ $# -eq 2 ]] || usage 2
        name=$1 description=$2
        valid_name "$name"
        [[ -n $description ]] || die "give the snapshot a description"
        require_domain
        virsh snapshot-info "$domain" "$name" >/dev/null 2>&1 &&
            die "snapshot $name already exists; delete it first with: just vm-snapshot-delete $name"
        was_running=false
        if ! shut_off; then
            was_running=true
            echo "Shutting $domain down for the snapshot"
            virsh shutdown "$domain" >/dev/null
            for ((i = 0; i < 60; i++)); do
                shut_off && break
                sleep 2
            done
            shut_off || die "$domain did not shut down within 2 minutes; nothing was taken"
        fi
        virsh snapshot-create-as "$domain" "$name" "$description" >/dev/null
        echo "Took snapshot $name"
        if $was_running; then
            virsh start "$domain" >/dev/null
            wait_for_ssh
        fi
        ;;
    list)
        [[ $# -eq 0 ]] || usage 2
        require_domain
        rows=()
        while read -r name; do
            [[ -n $name ]] || continue
            created=$(snapshot_field "$name" creationTime)
            description=$(snapshot_field "$name" description)
            rows+=("$created"$'\t'"$name"$'\t'"$description")
        done < <(virsh snapshot-list "$domain" --name)
        if [[ ${#rows[@]} -eq 0 ]]; then
            echo "No snapshots of $domain; take one with: just vm-snapshot NAME \"DESCRIPTION\""
            exit 0
        fi
        current=$(virsh snapshot-current "$domain" --name 2>/dev/null) || current=""
        printf '%-20s  %-16s  %s\n' NAME DATE DESCRIPTION
        while IFS=$'\t' read -r created name description; do
            marker=""
            [[ $name == "$current" ]] && marker=" (last taken or reverted to)"
            printf '%-20s  %-16s  %s%s\n' "$name" "$(date -d "@$created" '+%Y-%m-%d %H:%M')" "$description" "$marker"
        done < <(printf '%s\n' "${rows[@]}" | sort -n)
        ;;
    revert)
        [[ $# -eq 1 ]] || usage 2
        name=$1
        valid_name "$name"
        require_domain
        require_snapshot "$name"
        # The running VM is switched off hard: everything since the snapshot is thrown away anyway.
        echo "Reverting $domain to snapshot $name"
        virsh snapshot-revert "$domain" "$name" --running >/dev/null
        wait_for_ssh
        echo "$domain is back at snapshot $name"
        ;;
    delete)
        [[ $# -eq 1 ]] || usage 2
        name=$1
        valid_name "$name"
        require_domain
        require_snapshot "$name"
        virsh snapshot-delete "$domain" "$name" >/dev/null
        echo "Deleted snapshot $name"
        ;;
    -h | --help) usage ;;
    *) usage 2 ;;
esac
