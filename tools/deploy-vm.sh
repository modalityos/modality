#!/usr/bin/env bash
# Deploy a development build into the test VM, or roll the VM back to its previous login.
#
#   tools/deploy-vm.sh deploy   [--vm TARGET] [--prefix DIR] [--reboot]
#   tools/deploy-vm.sh sync     [--vm TARGET] [--prefix DIR]
#   tools/deploy-vm.sh rollback [--vm TARGET] [--purge] [--reboot]
#
# TARGET is an ssh destination (user@host or a ~/.ssh/config alias); it defaults to
# $MODALITYOS_VM. The user needs sudo in the VM. DIR is the VM's dev root (ADR 0002),
# default /opt/modalityos-dev.
#
# deploy installs the build into the dev root, installs greetd, Cage, Quickshell and the
# fonts, points greetd at the Greeter, lets the greeter user suspend, restart and shut down
# (a polkit rule) and makes greetd the display manager. SSH and a text console on tty2 stay
# enabled. rollback restores the previous display manager and greetd config and removes the
# polkit rule; --purge also removes the dev root. From a text console in the VM, rollback is
#   sudo /var/lib/modalityos-dev-deploy/remote.sh rollback
#
# sync is the quick path after one full deploy: it rebuilds the dev root and sends only the
# files that changed, with no packages and no greetd, PAM or polkit config. Quickshell
# reloads changed QML by itself; a changed launcher, Session entry or tmpfiles rule (the
# files from session/) restarts greetd so the Greeter relaunches.
set -euo pipefail

usage() {
    sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

[[ $# -gt 0 ]] || usage 2
action=$1
shift
case $action in
    deploy | sync | rollback) ;;
    -h | --help) usage ;;
    *) echo "deploy-vm.sh: unknown action: $action" >&2; usage 2 ;;
esac

vm=${MODALITYOS_VM:-}
prefix=/opt/modalityos-dev
remote_args=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --vm) vm=$2; shift 2 ;;
        --prefix) prefix=$2; shift 2 ;;
        --reboot | --purge)
            [[ $action != sync ]] || { echo "deploy-vm.sh: sync takes no $1" >&2; exit 2; }
            remote_args+=("$1"); shift ;;
        -h | --help) usage ;;
        *) echo "deploy-vm.sh: unknown argument: $1" >&2; usage 2 ;;
    esac
done

if [[ -z $vm ]]; then
    echo "deploy-vm.sh: no VM given: pass --vm TARGET or set MODALITYOS_VM" >&2
    exit 2
fi
# The dev root is synced with --delete, so it must be a folder of its own.
if [[ $prefix != /opt/?* ]]; then
    echo "deploy-vm.sh: --prefix must be a folder under /opt, not $prefix" >&2
    exit 2
fi

repo=$(cd "$(dirname "$0")/.." && pwd)
stage="$repo/build/stage"
# Files land in the ssh user's cache first; remote.sh, as root, moves them into place.
remote_dir=.cache/modalityos-deploy
# Where remote.sh records a full deploy; sync needs one first.
state=/var/lib/modalityos-dev-deploy

# One shared SSH connection for every step, so a sync costs one handshake.
control_dir=$(mktemp -d)
trap 'ssh -o ControlPath="$control_dir/socket" -O exit "$vm" 2>/dev/null; rm -rf "$control_dir"' EXIT
ssh_opts=(-o ControlMaster=auto -o ControlPath="$control_dir/socket" -o ControlPersist=60)
export RSYNC_RSH="ssh ${ssh_opts[*]}"

if ! ssh "${ssh_opts[@]}" "$vm" "mkdir -p $remote_dir && command -v rsync >/dev/null"; then
    echo "deploy-vm.sh: cannot reach $vm, or rsync is not installed there (pacman -S rsync)" >&2
    exit 1
fi
if [[ $action == sync ]] && ! ssh "${ssh_opts[@]}" "$vm" "[ \"\$(cat $state/prefix 2>/dev/null)\" = $prefix ]"; then
    echo "deploy-vm.sh: $vm has no full deploy into $prefix yet; run just deploy first" >&2
    exit 1
fi
rsync -a "$repo/tools/deploy-vm/" "$vm:$remote_dir/"

if [[ $action == deploy || $action == sync ]]; then
    rm -rf "$stage"
    if [[ $action == sync ]]; then
        "$repo/tools/install.sh" --prefix "$prefix" --destdir "$stage" >/dev/null
    else
        "$repo/tools/install.sh" --prefix "$prefix" --destdir "$stage"
    fi
    # install.sh copies afresh, so compare contents, not times; list only what was sent.
    rsync -a --checksum --delete --omit-dir-times --out-format='sent %n' \
        "$stage$prefix/" "$vm:$remote_dir/root/" | grep -v '/$' || true
    rsync -a --checksum "$repo/session/greetd/config.toml.in" \
        "$repo/session/polkit/50-modalityos-greeter.rules" "$vm:$remote_dir/"
fi

# -t gives sudo a terminal to ask for the password, when there is one to give.
tty=()
[[ -t 0 ]] && tty=(-t)
ssh "${ssh_opts[@]}" "${tty[@]}" "$vm" sudo bash "$remote_dir/remote.sh" "$action" --prefix "$prefix" \
    --from "$remote_dir" "${remote_args[@]}"
