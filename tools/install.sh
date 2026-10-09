#!/usr/bin/env bash
# Install ModalityOS's files under a prefix laid out like /usr (ADR 0002). The one install
# step for both a package build and the dev root: install.sh --prefix /usr --destdir "$pkgdir".
#
#   tools/install.sh [--prefix DIR] [--destdir DIR]
#
# Wallpapers are rendered from their SVG masters in data/wallpapers with rsvg-convert (Silk
# needs its blend modes) and cached in build/wallpapers.
set -euo pipefail

usage() {
    sed -n '2,6p' "$0" | sed 's/^# \{0,1\}//'
    exit "${1:-0}"
}

prefix=/usr
destdir=""
while [[ $# -gt 0 ]]; do
    case $1 in
        --prefix) prefix=$2; shift 2 ;;
        --destdir) destdir=$2; shift 2 ;;
        -h | --help) usage ;;
        *) echo "install.sh: unknown argument: $1" >&2; usage 2 ;;
    esac
done
[[ $prefix == /* ]] || { echo "install.sh: --prefix must be absolute" >&2; exit 2; }

repo=$(cd "$(dirname "$0")/.." && pwd)
root="$destdir$prefix"

render_wallpapers() {
    local out="$repo/build/wallpapers" svg name png
    command -v rsvg-convert >/dev/null || { echo "install.sh: rsvg-convert (librsvg) is required" >&2; exit 1; }
    command -v magick >/dev/null || { echo "install.sh: magick (imagemagick) is required" >&2; exit 1; }
    mkdir -p "$out"
    for svg in "$repo"/data/wallpapers/wallpaper-*.svg; do
        name=$(basename "$svg" .svg)
        png="$out/$name-3840x2160.png"
        if [[ ! $png -nt $svg ]]; then
            echo "Rendering $name"
            rsvg-convert -w 3840 -h 2160 -o "$png" "$svg"
        fi
        # 16:10: cover 3840 x 2400 with the 16:9 render, centred.
        if [[ ! $out/$name-3840x2400.png -nt $png ]]; then
            magick "$png" -resize 4267x2400 -gravity center -crop 3840x2400+0+0 +repage \
                "$out/$name-3840x2400.png"
        fi
    done
}

render_wallpapers

install -d "$root/bin" "$root/lib/qt6/qml" "$root/lib/tmpfiles.d" \
    "$root/share/modalityos/avatars" "$root/share/modalityos/wallpapers" "$root/share/wayland-sessions"

# Shared QML modules, where Qt looks for them under the prefix.
rm -rf "$root/lib/qt6/qml/Modality"
cp -r "$repo/qml/Modality" "$root/lib/qt6/qml/Modality"

# The Greeter's Quickshell config.
rm -rf "$root/share/modalityos/greeter"
install -d "$root/share/modalityos/greeter"
cp -r "$repo/greeter/shell.qml" "$repo/greeter/RealBackend.qml" "$repo/greeter/lib" \
    "$root/share/modalityos/greeter/"

install -m 0644 "$repo"/build/wallpapers/*.png "$root/share/modalityos/wallpapers/"
install -m 0644 "$repo/data/wallpapers/LICENSE" "$root/share/modalityos/wallpapers/LICENSE"

install -m 0644 "$repo"/data/avatars/*.png "$root/share/modalityos/avatars/"

# The machine-setting Defaults; Admin overrides go in /etc/modalityos/settings.json.
install -m 0644 "$repo/data/settings.json" "$root/share/modalityos/settings.json"

install -m 0755 "$repo/session/modalityos-greeter" "$repo/session/modalityos-session-kwin" "$root/bin/"
install -m 0644 "$repo/session/tmpfiles.d/modalityos-greeter.conf" "$root/lib/tmpfiles.d/"
sed "s|@PREFIX@|$prefix|g" "$repo/session/org.modalityos.kwin.desktop.in" \
    > "$root/share/wayland-sessions/org.modalityos.kwin.desktop"

echo "Installed into $root"
