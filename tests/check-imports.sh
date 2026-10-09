#!/usr/bin/env bash
# Modality.Theme imports only Qt; Modality.Controls imports only Qt and Modality.Theme.
# Shared modules must not depend on a screen, so the Shell, the Greeter and Apps can all load them.
set -euo pipefail
cd "$(dirname "$0")/.."

status=0
check() {
    local dir=$1 allowed=$2
    local bad
    bad=$(grep -HnE '^\s*import\s' "$dir"/*.qml | grep -vE "import\s+($allowed)(\s|$)" || true)
    if [[ -n $bad ]]; then
        echo "Disallowed imports in $dir:"
        echo "$bad"
        status=1
    fi
}

check qml/Modality/Theme 'Qt[A-Za-z.]*'
check qml/Modality/Controls 'Qt[A-Za-z.]*|Modality\.Theme'

[[ $status -eq 0 ]] && echo "Imports OK"
exit $status
