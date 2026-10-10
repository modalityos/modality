# The one place the project's commands live: humans, agents and CI all call these recipes.

qt_bin := "/usr/lib/qt6/bin"

# List the recipes
[private]
default:
    @{{just_executable()}} --list

# Run the full QML test suite, offscreen
test:
    QT_QPA_PLATFORM=offscreen {{qt_bin}}/qmltestrunner -import qml -import tests/stubs -input tests

# Run one QML test file, e.g. just test-one tests/tst_button.qml
test-one file:
    QT_QPA_PLATFORM=offscreen {{qt_bin}}/qmltestrunner -import qml -import tests/stubs -input {{file}}

# qmllint reads only the qmldir in the working directory unless each one is named with -i.

# Check the shared modules' import rule and lint every QML file, failing on any warning
lint:
    tests/check-imports.sh
    {{qt_bin}}/qmllint --max-warnings 0 -I qml -I tests/stubs \
        $(git ls-files --cached --others --exclude-standard '*qmldir' | sed 's/^/-i /') \
        $(git ls-files --cached --others --exclude-standard '*.qml')
    @echo "qmllint OK"

# Format every QML file in place with CI's qmlformat (in Docker; settings in .qmlformat.ini)
format:
    tools/qmlformat.sh format

# Fail if any QML file isn't formatted the way CI's qmlformat does it; `just format` fixes them
format-check:
    tools/qmlformat.sh check

# List Greeter and shared-module files that no test loads, failing if any
coverage:
    python3 -I tests/check-coverage.py --self-test
    python3 -I tests/check-coverage.py

# Run lint, format-check, tests and coverage, all of them even if one fails, then summarise; run before pushing
check:
    #!/usr/bin/env bash
    set -uo pipefail
    summary=() failed=0
    for recipe in lint format-check test coverage; do
        echo "== just $recipe"
        if {{just_executable()}} "$recipe"; then summary+=("$recipe ✓"); else summary+=("$recipe ✗"); failed=1; fi
    done
    (IFS='·'; echo "== ${summary[*]}" | sed 's/·/ · /g')
    exit "$failed"

# Open the Control states sheet (T: light/dark, R: Reduce transparency)
preview:
    {{qt_bin}}/qml -I qml qml/preview/Controls.qml

# Install ModalityOS's files under a prefix, e.g. just install /opt/modalityos-dev
install prefix:
    tools/install.sh --prefix {{prefix}}

# Create the test VM "modality-dev" from a pinned Arch cloud image; args pass to tools/vm/create.sh
[positional-arguments]
vm-create *args:
    tools/vm/create.sh "$@"

# Add a login user to the test VM, e.g. just vm-user-add ada --real-name "Ada Lovelace" --avatar data/avatars/avatar-flower.png
[positional-arguments]
vm-user-add name *args:
    tools/vm/user.sh add "$@"

# Remove a login user from the test VM
vm-user-remove name:
    tools/vm/user.sh remove {{name}}

# Snapshot the test VM (shut down, snapshot, start again), e.g. just vm-snapshot deployed "after just deploy"
vm-snapshot name description:
    tools/vm/snapshot.sh take {{quote(name)}} {{quote(description)}}

# List the test VM's snapshots, with date and description
vm-snapshots:
    tools/vm/snapshot.sh list

# Put the test VM back to a snapshot and boot it, e.g. just vm-revert initial
vm-revert name:
    tools/vm/snapshot.sh revert {{quote(name)}}

# Delete one of the test VM's snapshots
vm-snapshot-delete name:
    tools/vm/snapshot.sh delete {{quote(name)}}

# Remove the test VM "modality-dev", its snapshots, its disk and its address reservation
vm-destroy:
    tools/vm/destroy.sh

# Deploy a development build into the test VM ($MODALITYOS_VM); args pass to tools/deploy-vm.sh
[positional-arguments]
deploy *args:
    tools/deploy-vm.sh deploy "$@"

# Roll the test VM back to its previous login; args pass to tools/deploy-vm.sh
[positional-arguments]
rollback *args:
    tools/deploy-vm.sh rollback "$@"

# Send only the changed files to the test VM, after one full deploy; args pass to tools/deploy-vm.sh
[positional-arguments]
sync *args:
    tools/deploy-vm.sh sync "$@"

# Sync to the test VM on every save under greeter/, qml/Modality/, data/ and session/
[positional-arguments]
deploy-watch *args:
    #!/usr/bin/env bash
    set -euo pipefail
    if ! command -v watchexec >/dev/null; then
        echo "deploy-watch: watchexec is missing; install it with: sudo pacman -S watchexec" >&2
        exit 1
    fi
    # Editor temp files are ignored; saves inside the debounce window make one sync.
    exec watchexec --project-origin . \
        --watch greeter --watch qml/Modality --watch data --watch session \
        --ignore '*~' --ignore '*.swp' --ignore '*.swx' --ignore '.#*' --ignore '#*#' \
        --ignore '*.tmp' --ignore '4913' --ignore '*.kate-swp' \
        --debounce 500ms --on-busy-update queue \
        -- tools/deploy-vm.sh sync "$@"
