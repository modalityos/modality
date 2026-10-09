import QtQuick
import QtTest
import QuickshellStubs
import "../greeter"

// Seam 2: the real Greeter backend's power operations against a stubbed Process.
TestCase {
    id: testCase

    name: "RealBackendPower"

    Component {
        id: backendComponent

        RealBackend {
            prefix: "/opt/modalityos-dev"
        }
    }

    function test_power_operation_runs_systemctl_data() {
        return [
            { tag: "suspend", operation: "suspend", command: ["systemctl", "suspend"] },
            { tag: "reboot", operation: "reboot", command: ["systemctl", "reboot"] },
            { tag: "powerOff", operation: "powerOff", command: ["systemctl", "poweroff"] }
        ];
    }

    function test_power_operation_runs_systemctl(data) {
        const backend = createTemporaryObject(backendComponent, testCase);
        verify(backend);
        backend[data.operation]();
        const process = Processes.find("systemctl");
        verify(process);
        compare(process.command, data.command);
        verify(process.running);
    }
}
