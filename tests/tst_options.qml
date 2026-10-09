pragma ComponentBehavior: Bound
import QtQuick
import QtTest
import Modality.Theme
import "../greeter/lib"
import "helpers"

// Seam 1: Options and the Session Menu, driven through a fake Greeter backend.
TestCase {
    id: testCase

    name: "Options"
    width: 1280
    height: 800
    visible: true
    when: windowShown

    readonly property var kwin: ({
            id: "org.modalityos.kwin",
            name: "ModalityOS (KWin)",
            command: ["/opt/modalityos/bin/modalityos-session-kwin"],
            desktopNames: ["ModalityOS"]
        })
    readonly property var hyprland: ({
            id: "hyprland",
            name: "Hyprland",
            command: ["Hyprland"],
            desktopNames: ["Hyprland"]
        })

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

    function createGreeter(backendProperties, height) {
        const backend = createTemporaryObject(backendComponent, testCase, backendProperties ?? {});
        const greeter = createTemporaryObject(greeterComponent, testCase, {
            backend: backend,
            height: height ?? testCase.height
        });
        verify(greeter);
        return greeter;
    }

    function twoSessions(extra) {
        return Object.assign({ sessions: [testCase.kwin, testCase.hyprland] }, extra ?? {});
    }

    function cleanup() {
        Theme.theme = "dark";
    }

    function test_one_session_has_no_options_button() {
        const greeter = createGreeter();
        const button = findChild(greeter, "optionsButton");
        verify(!button || !button.visible);
    }

    function test_two_sessions_show_the_options_button_bottom_right_data() {
        return [
            { tag: "1280 x 1080", height: 1080, bottom: 40 },
            { tag: "1366 x 768", height: 768, bottom: 28 }
        ];
    }

    function test_two_sessions_show_the_options_button_bottom_right(data) {
        const greeter = createGreeter(twoSessions(), data.height);
        const button = findChild(greeter, "optionsButton");
        verify(button);
        verify(button.visible);
        compare(button.text, "Options");
        const place = button.mapToItem(greeter, 0, 0, button.width, button.height);
        compare(greeter.width - (place.x + place.width), 40);
        compare(greeter.height - (place.y + place.height), data.bottom);
    }
}
