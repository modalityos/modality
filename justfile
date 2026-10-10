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

# List Greeter and shared-module files that no test loads, failing if any
coverage:
    python3 -I tests/check-coverage.py --self-test
    python3 -I tests/check-coverage.py

# Run lint, tests and coverage, all three even if one fails, then summarise; run before pushing
check:
    #!/usr/bin/env bash
    set -uo pipefail
    summary=() failed=0
    for recipe in lint test coverage; do
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

# Deploy a development build into the test VM ($MODALITYOS_VM); args pass to tools/deploy-vm.sh
[positional-arguments]
deploy *args:
    tools/deploy-vm.sh deploy "$@"

# Roll the test VM back to its previous login; args pass to tools/deploy-vm.sh
[positional-arguments]
rollback *args:
    tools/deploy-vm.sh rollback "$@"
