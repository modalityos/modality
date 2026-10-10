import QtQuick
import QtTest
import Quickshell

// The Greeter's Quickshell config, loaded against stubbed Quickshell.
TestCase {
    id: testCase

    name: "Shell"

    function cleanup() {
        Quickshell.environment = {};
    }

    function loadShell() {
        const component = Qt.createComponent(Qt.resolvedUrl("../greeter/shell.qml"));
        compare(component.status, Component.Ready, component.errorString());
        const shell = createTemporaryObject(component, testCase);
        verify(shell);
        const greeter = findChild(shell, "greeter");
        verify(greeter);
        return greeter;
    }

    function test_greeter_finds_its_files_through_modalityos_prefix() {
        Quickshell.environment = {
            MODALITYOS_PREFIX: "/opt/modalityos-dev"
        };
        compare(loadShell().backend.prefix, "/opt/modalityos-dev");
    }

    function test_greeter_prefix_defaults_to_usr() {
        compare(loadShell().backend.prefix, "/usr");
    }
}
