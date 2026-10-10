pragma ComponentBehavior: Bound
import QtQuick
import QtTest
import Modality.Theme
import "../greeter/lib"
import "helpers"

// Seam 1: the power row, driven through a fake Greeter backend.
TestCase {
    id: testCase

    name: "PowerRow"
    width: 1280
    height: 800
    visible: true
    when: windowShown

    Component {
        id: backendComponent

        FakeBackend {}
    }

    Component {
        id: greeterComponent

        Greeter {
            width: testCase.width
            height: testCase.height
        }
    }

    function createGreeter(height) {
        const backend = createTemporaryObject(backendComponent, testCase);
        const greeter = createTemporaryObject(greeterComponent, testCase, {
            backend: backend,
            height: height ?? testCase.height
        });
        verify(greeter);
        return greeter;
    }

    function cleanup() {
        Theme.theme = "dark";
    }

    function test_power_button_calls_its_backend_operation_data() {
        return [
            {
                tag: "Sleep",
                button: "sleepButton",
                label: "Sleep",
                call: ["suspend"]
            },
            {
                tag: "Restart",
                button: "restartButton",
                label: "Restart",
                call: ["reboot"]
            },
            {
                tag: "Shut Down",
                button: "shutDownButton",
                label: "Shut Down",
                call: ["powerOff"]
            }
        ];
    }

    function test_power_button_calls_its_backend_operation(data) {
        const greeter = createGreeter();
        const button = findChild(greeter, data.button);
        verify(button);
        compare(button.text, data.label);
        mouseClick(button);
        compare(greeter.backend.calls, [data.call]);
    }

    function test_focused_power_button_acts_on_space() {
        const greeter = createGreeter();
        const button = findChild(greeter, "restartButton");
        button.forceActiveFocus();
        keyClick(Qt.Key_Space);
        compare(greeter.backend.lastCall(), ["reboot"]);
    }

    function test_power_buttons_do_nothing_under_an_open_overlay_data() {
        const rows = [];
        for (const overlay of ["otherUsers", "options"]) {
            for (const button of ["sleepButton", "restartButton", "shutDownButton"])
                rows.push({
                    tag: `${button} under ${overlay}`,
                    overlay: overlay,
                    button: button
                });
        }
        return rows;
    }

    function test_power_buttons_do_nothing_under_an_open_overlay(data) {
        const backend = createTemporaryObject(backendComponent, testCase, {
            users: [
                {
                    name: "ada",
                    realName: "Ada Lovelace",
                    avatar: "",
                    systemAccount: false
                },
                {
                    name: "katherine",
                    realName: "Katherine Johnson",
                    avatar: "",
                    systemAccount: false
                }
            ],
            sessions: [
                {
                    id: "org.modalityos.kwin",
                    name: "ModalityOS (KWin)",
                    command: ["kwin"],
                    desktopNames: ["ModalityOS"]
                },
                {
                    id: "hyprland",
                    name: "Hyprland",
                    command: ["Hyprland"],
                    desktopNames: ["Hyprland"]
                }
            ]
        });
        const greeter = createTemporaryObject(greeterComponent, testCase, {
            backend: backend
        });
        findChild(greeter, data.overlay === "otherUsers" ? "otherUsersPill" : "optionsButton").forceActiveFocus();
        keyClick(Qt.Key_Return);
        compare(greeter.overlay, data.overlay);
        findChild(greeter, data.button).forceActiveFocus();
        keyClick(Qt.Key_Space);
        keyClick(Qt.Key_Return);
        compare(backend.calls, []);
    }

    function test_power_row_sits_bottom_centre_data() {
        return [
            {
                tag: "tall screen",
                height: 800 + 200,
                bottom: 40
            },
            {
                tag: "short screen",
                height: 768,
                bottom: 28
            }
        ];
    }

    function test_power_row_sits_bottom_centre(data) {
        const greeter = createGreeter(data.height);
        const row = findChild(greeter, "powerRow");
        verify(row);
        const box = row.mapToItem(greeter, 0, 0, row.width, row.height);
        compare(box.y + box.height, greeter.height - data.bottom);
        fuzzyCompare(box.x + box.width / 2, greeter.width / 2, 0.5);
    }
}
