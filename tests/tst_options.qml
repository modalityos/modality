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

    function openOptions(greeter) {
        mouseClick(findChild(greeter, "optionsButton"));
        const menu = findChild(greeter, "sessionMenu");
        verify(menu);
        tryCompare(menu, "opacity", 1);
        return menu;
    }

    function test_options_opens_the_session_menu_with_the_default_session_checked_data() {
        return [
            { tag: "1280 x 1080", height: 1080, bottom: 112 },
            { tag: "1366 x 768", height: 768, bottom: 100 }
        ];
    }

    function test_options_opens_the_session_menu_with_the_default_session_checked(data) {
        const greeter = createGreeter(twoSessions(), data.height);
        verify(!findChild(greeter, "sessionMenu").visible);
        const menu = openOptions(greeter);
        compare(greeter.overlay, "options");
        verify(menu.visible);
        verify(findChild(greeter, "optionsButton").checked);
        compare(menu.title, "Session");
        compare(menu.model.map(item => item.text), ["ModalityOS (KWin)", "Hyprland"]);
        compare(menu.model.map(item => item.checked), [true, false]);
        verify(menu.itemAt(0).activeFocus);
        const place = menu.mapToItem(greeter, 0, 0, menu.width, menu.height);
        compare(menu.width, 220);
        compare(greeter.width - (place.x + place.width), 40);
        compare(greeter.height - (place.y + place.height), data.bottom);
    }

    function logIn(greeter) {
        typeText("secret");
        keyClick(Qt.Key_Return);
        greeter.backend.authPrompt("Password:", true);
        greeter.backend.readyToLaunch();
        tryVerify(() => greeter.backend.lastCall()[0] === "launch");
    }

    function typeText(text) {
        for (const character of text)
            keyClick(character);
    }

    function test_picked_session_launches_and_is_remembered_for_the_user() {
        const greeter = createGreeter(twoSessions());
        const menu = openOptions(greeter);
        mouseClick(menu.itemAt(1));
        compare(greeter.overlay, "");
        tryCompare(menu, "visible", false);
        const field = findChild(greeter, "passwordField");
        verify(field.activeFocus);

        logIn(greeter);
        const calls = greeter.backend.calls;
        compare(calls[calls.length - 2], ["remember", "ian", "hyprland"]);
        compare(calls[calls.length - 1], ["launch", "hyprland"]);
    }

    readonly property var twoUsers: [
        { name: "ada", realName: "Ada Lovelace", avatar: "", systemAccount: false },
        { name: "ian", realName: "Ian Gregson", avatar: "", systemAccount: false }
    ]

    function rememberedHyprlandForIan() {
        return twoSessions({
            users: testCase.twoUsers,
            lastUser: "ian",
            rememberedSessions: { ian: "hyprland" }
        });
    }

    function test_remembered_session_is_checked_in_the_session_menu() {
        const greeter = createGreeter(rememberedHyprlandForIan());
        const menu = openOptions(greeter);
        compare(menu.model.map(item => item.checked), [false, true]);
    }

    function test_remembered_session_launches_for_its_user() {
        const greeter = createGreeter(rememberedHyprlandForIan());
        logIn(greeter);
        compare(greeter.backend.lastCall(), ["launch", "hyprland"]);
    }

    function test_another_user_gets_the_default_session() {
        const greeter = createGreeter(twoSessions({
            users: testCase.twoUsers,
            lastUser: "ada",
            rememberedSessions: { ian: "hyprland" }
        }));
        logIn(greeter);
        compare(greeter.backend.lastCall(), ["launch", "org.modalityos.kwin"]);
    }

    function test_a_session_picked_for_one_user_does_not_carry_to_the_next_user_picked() {
        const greeter = createGreeter(twoSessions({ users: testCase.twoUsers, lastUser: "ian" }));
        mouseClick(openOptions(greeter).itemAt(1));
        mouseClick(findChild(greeter, "otherUsersPill"));
        const panel = findChild(greeter, "userPanel");
        tryCompare(panel, "opacity", 1);
        mouseClick(findChild(greeter, "userCell0"));
        compare(findChild(greeter, "userName").text, "Ada Lovelace");
        logIn(greeter);
        compare(greeter.backend.lastCall(), ["launch", "org.modalityos.kwin"]);
    }

    function test_esc_closes_the_session_menu_and_returns_focus_to_options() {
        const greeter = createGreeter(twoSessions());
        const menu = openOptions(greeter);
        keyClick(Qt.Key_Down);
        keyClick(Qt.Key_Escape);
        compare(greeter.overlay, "");
        tryCompare(menu, "visible", false);
        verify(findChild(greeter, "optionsButton").activeFocus);
        // Nothing was picked: Enter on Options reopens the Menu with the same Session checked.
        keyClick(Qt.Key_Return);
        compare(greeter.overlay, "options");
        compare(menu.model.map(item => item.checked), [true, false]);
        tryVerify(() => menu.itemAt(0).activeFocus);
    }

    function test_remembered_session_that_is_gone_gives_the_default_session() {
        const greeter = createGreeter(twoSessions({ rememberedSessions: { ian: "sway" } }));
        logIn(greeter);
        compare(greeter.backend.lastCall(), ["launch", "org.modalityos.kwin"]);
    }
}
