#!/usr/bin/env bash
# The VM side of tools/deploy-vm.sh, run as root. Run it by hand from a text console to
# roll back: sudo /var/lib/modalityos-dev-deploy/remote.sh rollback [--purge] [--reboot]
set -euo pipefail

state=/var/lib/modalityos-dev-deploy
polkit_rule=/etc/polkit-1/rules.d/50-modalityos-greeter.rules

action=${1:-}
[[ -n $action ]] && shift
prefix=/opt/modalityos-dev
from=""
reboot=false
purge=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --prefix) prefix=$2; shift 2 ;;
        --from) from=$2; shift 2 ;;
        --reboot) reboot=true; shift ;;
        --purge) purge=true; shift ;;
        *) echo "remote.sh: unknown argument: $1" >&2; exit 2 ;;
    esac
done

[[ $EUID -eq 0 ]] || { echo "remote.sh: run as root" >&2; exit 1; }
if [[ $prefix != /opt/?* ]]; then
    echo "remote.sh: --prefix must be a folder under /opt, not $prefix" >&2
    exit 2
fi

# The unit display-manager.service points at, or "none".
current_display_manager() {
    local link=/etc/systemd/system/display-manager.service
    if [[ -L $link ]]; then
        basename "$(readlink "$link")"
    else
        echo none
    fi
}

# Escape hatches first, so a broken Greeter never locks anyone out.
keep_escape_hatches() {
    # This deploy came over SSH, so sshd runs; make sure it also starts at boot.
    systemctl is-enabled -q sshd.service || systemctl is-enabled -q sshd.socket ||
        systemctl enable sshd.service
    systemctl enable getty@tty2.service
}

deploy() {
    [[ -n $from && -d $from/root ]] || { echo "remote.sh: nothing staged; run tools/deploy-vm.sh deploy" >&2; exit 1; }
    keep_escape_hatches

    grep -vE '^\s*(#|$)' "$from/packages.txt" | xargs pacman -Syu --needed --noconfirm

    install -d -m 0755 "$state"
    if [[ ! -f $state/previous-display-manager ]]; then
        current_display_manager > "$state/previous-display-manager"
        if [[ -f /etc/greetd/config.toml ]]; then
            cp -a /etc/greetd/config.toml "$state/greetd-config.toml"
        fi
    fi
    install -m 0755 "$0" "$state/remote.sh"

    install -d -m 0755 "$prefix"
    rsync -a --delete --chown=root:root --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r "$from/root/" "$prefix/"
    chmod 0755 "$prefix"/bin/*

    install -d -m 0755 /etc/greetd
    sed "s|@PREFIX@|$prefix|g" "$from/config.toml.in" > /etc/greetd/config.toml
    install -D -m 0644 "$from/50-modalityos-greeter.rules" "$polkit_rule"

    local previous
    previous=$(cat "$state/previous-display-manager")
    if [[ $previous != none && $previous != greetd.service ]]; then
        systemctl disable "$previous"
    fi
    systemctl enable greetd.service

    echo "Deployed into $prefix; greetd is the display manager (was: $previous)."
    echo "Text console: Ctrl+Alt+F2. Roll back: tools/deploy-vm.sh rollback"
}

rollback() {
    if [[ ! -f $state/previous-display-manager ]]; then
        echo "remote.sh: no deploy to roll back" >&2
        exit 1
    fi
    local previous
    previous=$(cat "$state/previous-display-manager")

    if [[ $previous != greetd.service ]]; then
        systemctl disable greetd.service
    fi
    if [[ -f $state/greetd-config.toml ]]; then
        cp -a "$state/greetd-config.toml" /etc/greetd/config.toml
    else
        rm -f /etc/greetd/config.toml
    fi
    rm -f "$polkit_rule"
    if [[ $previous != none && $previous != greetd.service ]]; then
        systemctl enable "$previous"
    fi
    if $purge; then
        rm -rf "$prefix"
    fi
    rm -f "$state/previous-display-manager" "$state/greetd-config.toml"

    echo "Rolled back: the display manager is $previous again."
}

case $action in
    deploy) deploy ;;
    rollback) rollback ;;
    *) echo "remote.sh: action must be deploy or rollback" >&2; exit 2 ;;
esac

if $reboot; then
    systemctl reboot
else
    echo "Reboot the VM to see the change."
fi
