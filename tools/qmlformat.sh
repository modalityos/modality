#!/usr/bin/env bash
# Formats or checks every QML file with the qmlformat CI uses. qmlformat's output changes between
# Qt releases, so outside CI it runs in the same archlinux:latest image as the CI jobs; a local Qt
# that lags or leads CI's would format differently.
#
#   tools/qmlformat.sh format   rewrite files in place
#   tools/qmlformat.sh check    list files that aren't formatted; exit 1 if any
set -euo pipefail

mode="${1:?usage: tools/qmlformat.sh format|check}"
[[ $mode == format || $mode == check ]] || { echo "usage: tools/qmlformat.sh format|check" >&2; exit 2; }
shift
# The file list comes from git on the host; a worktree's .git doesn't resolve inside the container.
if (($#)); then
    files=("$@")
else
    mapfile -t files < <(git ls-files --cached --others --exclude-standard '*.qml')
fi

if [[ -z ${CI:-} ]]; then
    command -v docker >/dev/null || { echo "qmlformat.sh: docker is needed to match CI's Qt" >&2; exit 1; }
    # A named volume caches pacman's downloads, so only the first run pays for them.
    exec docker run --rm --pull always \
        --volume "$PWD:/w" --workdir /w \
        --volume modalityos-pacman-cache:/var/cache/pacman/pkg \
        --env CI=1 --env HOST_UID="$(id -u)" --env HOST_GID="$(id -g)" \
        archlinux:latest sh -c '
            pacman -Syu --noconfirm --needed qt6-declarative diffutils >/dev/null &&
            tools/qmlformat.sh "$@"; status=$?
            chown "$HOST_UID:$HOST_GID" "$@" 2>/dev/null
            exit $status' sh "$mode" "${files[@]}"
fi

qmlformat=/usr/lib/qt6/bin/qmlformat

if [[ $mode == format ]]; then
    "$qmlformat" --inplace "${files[@]}"
    echo "qmlformat $("$qmlformat" --version | awk '{print $2}'): formatted ${#files[@]} files"
    exit 0
fi

unformatted=0
for file in "${files[@]}"; do
    if ! "$qmlformat" "$file" | cmp --silent - "$file"; then
        echo "not formatted: $file"
        unformatted=1
    fi
done
if ((unformatted)); then
    echo "Run: just format"
else
    echo "qmlformat $("$qmlformat" --version | awk '{print $2}') OK"
fi
exit "$unformatted"
