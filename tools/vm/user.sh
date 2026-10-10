#!/usr/bin/env bash
# Add or remove a login user in the test VM ($MODALITYOS_VM), to try the Greeter with one
# user or several (Other users shows only with more than one).
#
#   tools/vm/user.sh add NAME [--real-name "Full Name"] [--password PASSWORD] [--avatar FILE]
#   tools/vm/user.sh remove NAME
#
# The password defaults to "modality". --avatar sets the user's AccountsService picture (a
# PNG or JPEG; the four samples in data/avatars/ work); without it the Greeter shows its
# built-in avatar. greetd restarts afterwards so the Greeter reads the new user list.
set -euo pipefail

usage() {
    sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}
die() {
    echo "user.sh: $*" >&2
    exit 1
}

[[ $# -ge 2 ]] || usage 2
action=$1 name=$2
shift 2
[[ $name =~ ^[a-z_][a-z0-9_-]{0,31}$ ]] || die "not a valid user name: $name"
target=${MODALITYOS_VM:?set MODALITYOS_VM, e.g. export MODALITYOS_VM=dev@192.168.122.50}

real_name="" password=modality avatar=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --real-name) [[ $# -ge 2 ]] || usage 2; real_name=$2; shift 2 ;;
        --password) [[ $# -ge 2 ]] || usage 2; password=$2; shift 2 ;;
        --avatar) [[ $# -ge 2 ]] || usage 2; avatar=$2; shift 2 ;;
        -h | --help) usage ;;
        *) echo "user.sh: unknown argument: $1" >&2; usage 2 ;;
    esac
done

case $action in
    add)
        if [[ -n $avatar ]]; then
            [[ -r $avatar ]] || die "cannot read $avatar"
            scp -q "$avatar" "$target:/tmp/modalityos-avatar-$name"
        fi
        # ssh joins its arguments into one command line, so each is quoted for the remote shell.
        # shellcheck disable=SC2029 # expanding on this side is the point: the quoting is for the VM
        ssh "$target" "sudo bash -s -- $(printf '%q ' "$name" "$real_name" "$password" "${avatar:+yes}")" <<'REMOTE'
set -euo pipefail
name=$1 real_name=$2 password=$3 avatar=$4
id "$name" >/dev/null 2>&1 && { echo "user $name already exists" >&2; exit 1; }
useradd --create-home --comment "$real_name" "$name"
printf '%s:%s\n' "$name" "$password" | chpasswd
if [[ -n $avatar ]]; then
    install -D -m 644 "/tmp/modalityos-avatar-$name" "/var/lib/AccountsService/icons/$name"
    rm -f "/tmp/modalityos-avatar-$name"
    install -d -m 700 /var/lib/AccountsService/users
    printf '[User]\nIcon=/var/lib/AccountsService/icons/%s\nSystemAccount=false\n' "$name" \
        >"/var/lib/AccountsService/users/$name"
fi
systemctl try-restart accounts-daemon
systemctl restart greetd
REMOTE
        echo "Added $name (password: $password); the Greeter has restarted."
        ;;
    remove)
        # shellcheck disable=SC2029 # the name is quoted here for the VM
        ssh "$target" "sudo bash -s -- $(printf '%q' "$name")" <<'REMOTE'
set -euo pipefail
name=$1
[[ $name == dev ]] && { echo "dev is the VM's own user; keep it" >&2; exit 1; }
id "$name" >/dev/null 2>&1 || { echo "no user $name" >&2; exit 1; }
userdel --remove "$name" 2>/dev/null || userdel --remove --force "$name"
rm -f "/var/lib/AccountsService/icons/$name" "/var/lib/AccountsService/users/$name"
systemctl try-restart accounts-daemon
systemctl restart greetd
REMOTE
        echo "Removed $name; the Greeter has restarted."
        ;;
    *) usage 2 ;;
esac
