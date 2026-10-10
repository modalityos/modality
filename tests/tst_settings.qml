pragma ComponentBehavior: Bound
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
        const greeter = createTemporaryObject(greeterComponent, testCase, {
            backend: backend
        });
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
            {
                tag: "morning",
                hours: 9,
                minutes: 41,
                time: "09:41"
            },
            {
                tag: "evening",
                hours: 21,
                minutes: 5,
                time: "21:05"
            }
        ];
    }

    function test_24_hour_clock(data) {
        const greeter = createGreeter({
            clock24Hour: true
        });
        compare(clockTimeAt(greeter, data.hours, data.minutes), data.time);
    }

    function test_12_hour_clock_data() {
        return [
            {
                tag: "morning",
                hours: 9,
                minutes: 41,
                time: "9:41 AM"
            },
            {
                tag: "evening",
                hours: 21,
                minutes: 5,
                time: "9:05 PM"
            },
            {
                tag: "midnight",
                hours: 0,
                minutes: 30,
                time: "12:30 AM"
            }
        ];
    }

    function test_12_hour_clock(data) {
        const greeter = createGreeter({
            clock24Hour: false
        });
        compare(clockTimeAt(greeter, data.hours, data.minutes), data.time);
    }

    // Every frosted wallpaper behind a Glass element, shown or not.
    function frosts(item) {
        let found = item.blurRadius !== undefined && item.region !== undefined ? [item] : [];
        for (const child of item.children)
            found = found.concat(frosts(child));
        return found;
    }

    function test_glass_is_frosted_by_default() {
        const greeter = createGreeter({
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
            ]
        });
        compare(Theme.reduceTransparency, false);
        compare(findChild(greeter, "passwordField").fillColor, Qt.rgba(32 / 255, 32 / 255, 34 / 255, 0.9));
        verify(findChild(greeter, "passwordFrost").visible);
    }

    function test_reduce_transparency_draws_glass_solid_without_frost_data() {
        return [
            {
                tag: "dark",
                theme: "dark",
                fallback: "#2f2e2c"
            },
            {
                tag: "light",
                theme: "light",
                fallback: "#fbfbfa"
            }
        ];
    }

    function test_reduce_transparency_draws_glass_solid_without_frost(data) {
        const greeter = createGreeter({
            theme: data.theme,
            reduceTransparency: true,
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
            ]
        });
        compare(Theme.reduceTransparency, true);
        verify(Qt.colorEqual(findChild(greeter, "passwordField").fillColor, data.fallback));
        const all = frosts(greeter);
        verify(all.length >= 5, `found ${all.length} Frosts`);
        for (const frost of all)
            verify(!frost.visible, `a Frost still shows under ${frost.parent}`);
    }

    function test_light_theme_turns_the_text_dark() {
        const greeter = createGreeter({
            theme: "light"
        });
        // textPrimary in light: rgba(0, 0, 0, 0.86).
        verify(Qt.colorEqual(findChild(greeter, "clockTime").color, "#db000000"));
        verify(Qt.colorEqual(findChild(greeter, "userName").color, "#db000000"));
    }
}
