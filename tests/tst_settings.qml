import QtQuick
import QtTest
import Modality.Theme
import "../greeter/lib"
import "helpers"

// Seam 1: the Greeter follows the machine settings its backend gives it.
TestCase {
    id: testCase

    name: "GreeterSettings"
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

    function createGreeter(backendProperties) {
        const backend = createTemporaryObject(backendComponent, testCase, backendProperties ?? {});
        const greeter = createTemporaryObject(greeterComponent, testCase, { backend: backend });
        verify(greeter);
        return greeter;
    }

    function cleanup() {
        Theme.theme = "dark";
        Theme.reduceTransparency = false;
    }

    function clockTimeAt(greeter, hours, minutes) {
        findChild(greeter, "clock").now = new Date(2026, 9, 9, hours, minutes);
        return findChild(greeter, "clockTime").text;
    }

    function test_24_hour_clock_data() {
        return [
            { tag: "morning", hours: 9, minutes: 41, time: "09:41" },
            { tag: "evening", hours: 21, minutes: 5, time: "21:05" }
        ];
    }

    function test_24_hour_clock(data) {
        const greeter = createGreeter({ clock24Hour: true });
        compare(clockTimeAt(greeter, data.hours, data.minutes), data.time);
    }

    function test_12_hour_clock_data() {
        return [
            { tag: "morning", hours: 9, minutes: 41, time: "9:41 AM" },
            { tag: "evening", hours: 21, minutes: 5, time: "9:05 PM" },
            { tag: "midnight", hours: 0, minutes: 30, time: "12:30 AM" }
        ];
    }

    function test_12_hour_clock(data) {
        const greeter = createGreeter({ clock24Hour: false });
        compare(clockTimeAt(greeter, data.hours, data.minutes), data.time);
    }
}
