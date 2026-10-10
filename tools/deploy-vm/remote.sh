#!/usr/bin/env bash
# The VM side of tools/deploy-vm.sh, run as root. Run it by hand from a text console to
# roll back: sudo /var/lib/modalityos-dev-deploy/remote.sh rollback [--purge] [--reboot]
# Actions: deploy, sync (the dev root only, after a deploy) and rollback.
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

# Copy the staged tree into the dev root, printing each path whose content changed or that
# went away. Execute bits come from the stage (X), so an unchanged launcher stays unchanged.
# Files are rewritten in place: Quickshell watches the Greeter's files by inode, and a file
# replaced by a new one would drop out of its watch.
install_root() {
    rsync -a --checksum --inplace --delete --omit-dir-times --chown=root:root \
        --chmod=Du=rwx,Dgo=rx,Fu=rwX,Fgo=rX --out-format='%i %n' "$from/root/" "$prefix/" |
        awk '$1 ~ /^([<>ch]|\*deleting)/ && $2 !~ /\/$/ {print $2}'
}

# A dev prefix is outside systemd's tmpfiles.d search path, so apply its rules by name.
apply_tmpfiles() {
    systemd-tmpfiles --create "$prefix/lib/tmpfiles.d/modalityos-greeter.conf"
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
    # Where this deploy went, so a later rollback --purge removes it whatever --prefix it gets.
    echo "$prefix" > "$state/prefix"

    install -d -m 0755 "$prefix"
    install_root >/dev/null
    apply_tmpfiles

    install -d -m 0755 /etc/greetd
    sed "s|@PREFIX@|$prefix|g" "$from/config.toml.in" > /etc/greetd/config.toml
    install -D -m 0644 "$from/50-modalityos-greeter.rules" "$polkit_rule"

    local previous
    previous=$(cat "$state/previous-display-manager")
    if [[ $previous != none && $previous != greetd.service ]]; then
        systemctl disable "$previous"
    fi
    # Never leave the VM with no display manager: put the previous one back first.
    if ! systemctl enable greetd.service; then
        if [[ $previous != none && $previous != greetd.service ]]; then
            systemctl enable "$previous"
        fi
        echo "remote.sh: could not enable greetd; $previous stays the display manager" >&2
        exit 1
    fi

    echo "Deployed into $prefix; greetd is the display manager (was: $previous)."
    echo "Text console: Ctrl+Alt+F2. Roll back: tools/deploy-vm.sh rollback"
}

# The quick path: the dev root only. The running Quickshell watches the Greeter's own files
# (share/modalityos/greeter) and reloads them by itself. It does not watch the shared modules
# or the data, and the files from session/ (launchers, Session entries, tmpfiles rules) apply
# only at launch, so any other change restarts greetd to relaunch the Greeter.
quick_sync() {
    [[ -n $from && -d $from/root ]] || { echo "remote.sh: nothing staged; run tools/deploy-vm.sh sync" >&2; exit 1; }
    if [[ ! -f $state/previous-display-manager || $(cat "$state/prefix" 2>/dev/null) != "$prefix" ]]; then
        echo "remote.sh: no full deploy into $prefix yet; run tools/deploy-vm.sh deploy first" >&2
        exit 1
    fi

    local changed
    changed=$(install_root)
    if [[ -z $changed ]]; then
        echo "Nothing changed in $prefix."
    else
        while read -r path; do echo "updated $path"; done <<<"$changed"
        if grep -qv '^share/modalityos/greeter/' <<<"$changed"; then
            apply_tmpfiles
            systemctl restart greetd.service
            echo "Restarted greetd: the Greeter relaunches with the change."
        else
            echo "Quickshell reloads the Greeter by itself."
        fi
    fi

    # These live outside the dev root, so only a full deploy writes them.
    if ! sed "s|@PREFIX@|$prefix|g" "$from/config.toml.in" | cmp -s - /etc/greetd/config.toml ||
        ! cmp -s "$from/50-modalityos-greeter.rules" "$polkit_rule"; then
        echo "The greetd config or polkit rule changed; run just deploy to apply it."
    fi
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
        local deployed=$prefix
        [[ -f $state/prefix ]] && deployed=$(cat "$state/prefix")
        if [[ $deployed != /opt/?* ]]; then
            echo "remote.sh: stored prefix $deployed is not under /opt; not purging it" >&2
            exit 1
        fi
        rm -rf "$deployed" /var/lib/modalityos/greeter
        rmdir --ignore-fail-on-non-empty /var/lib/modalityos 2>/dev/null || true
    fi
    rm -f "$state/previous-display-manager" "$state/greetd-config.toml" "$state/prefix"

    echo "Rolled back: the display manager is $previous again."
}

case $action in
    deploy) deploy ;;
    sync) quick_sync; exit 0 ;;
    rollback) rollback ;;
    *) echo "remote.sh: action must be deploy, sync or rollback" >&2; exit 2 ;;
esac

if $reboot; then
    systemctl reboot
else
    echo "Reboot the VM to see the change."
fi
