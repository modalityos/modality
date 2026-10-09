pragma ComponentBehavior: Bound
import QtQuick
import QtTest
import Modality.Theme
import "../greeter/lib"
import "helpers"

// Seam 1: the Greeter's keyboard path. Tab walks password, Other users, Options, Sleep,
// Restart, Shut Down and back, each with the focus ring; Shift+Tab walks it backwards.
TestCase {
    id: testCase

    name: "GreeterKeyboard"
    width: 1280
    height: 800
    visible: true
    when: windowShown

    readonly property var twoUsers: [
        { name: "ada", realName: "Ada Lovelace", avatar: "", systemAccount: false },
        { name: "ian", realName: "Ian Gregson", avatar: "", systemAccount: false }
    ]
    readonly property var twoSessions: [
        { id: "org.modalityos.kwin", name: "ModalityOS (KWin)", command: ["kwin"], desktopNames: ["ModalityOS"] },
        { id: "org.modalityos.hyprland", name: "ModalityOS (Hyprland)", command: ["hyprland"], desktopNames: ["ModalityOS"] }
    ]

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
        tryVerify(() => findChild(greeter, "passwordField").activeFocus);
        return greeter;
    }

    function cleanup() {
        Theme.theme = "dark";
    }

    // The focus ring drawn for item: shown, and the two-tone ring.
    function ringOf(item) {
        const search = node => {
            if (node.ringWidth !== undefined && node.haloWidth !== undefined)
                return node;
            for (const child of node.children) {
                const found = search(child);
                if (found)
                    return found;
            }
            return null;
        };
        return search(item);
    }

    function walk(greeter, key, order) {
        for (const name of order) {
            keyClick(key);
            const item = findChild(greeter, name);
            verify(item, `${name} exists`);
            verify(item.activeFocus, `${key === Qt.Key_Tab ? "Tab" : "Shift+Tab"} reaches ${name}`);
            const ring = ringOf(item);
            verify(ring, `${name} has a focus ring`);
            verify(ring.visible, `${name} shows its focus ring`);
        }
    }

    function test_tab_order_data() {
        return [
            {
                tag: "one user, one Session",
                users: undefined,
                sessions: undefined,
                order: ["sleepButton", "restartButton", "shutDownButton", "passwordField"]
            },
            {
                tag: "several users",
                users: testCase.twoUsers,
                sessions: undefined,
                order: ["otherUsersPill", "sleepButton", "restartButton", "shutDownButton", "passwordField"]
            },
            {
                tag: "several users and Sessions",
                users: testCase.twoUsers,
                sessions: testCase.twoSessions,
                order: ["otherUsersPill", "optionsButton", "sleepButton", "restartButton", "shutDownButton", "passwordField"]
            }
        ];
    }

    function test_tab_order(data) {
        const properties = {};
        if (data.users)
            properties.users = data.users;
        if (data.sessions)
            properties.sessions = data.sessions;
        const greeter = createGreeter(properties);
        walk(greeter, Qt.Key_Tab, data.order);
    }

    function test_shift_tab_walks_the_order_backwards() {
        const greeter = createGreeter({ users: testCase.twoUsers, sessions: testCase.twoSessions });
        walk(greeter, Qt.Key_Backtab,
             ["shutDownButton", "restartButton", "sleepButton", "optionsButton", "otherUsersPill", "passwordField"]);
    }

    function test_password_field_shows_the_focus_ring_at_start() {
        const greeter = createGreeter();
        verify(ringOf(findChild(greeter, "passwordField")).visible);
    }

    function test_session_failed_puts_try_again_after_the_password_field() {
        const greeter = createGreeter({ users: testCase.twoUsers });
        keyClick("x");
        keyClick(Qt.Key_Return);
        greeter.backend.authPrompt("Password:", true);
        greeter.backend.readyToLaunch();
        greeter.backend.error("no session");
        tryCompare(greeter, "loginState", "sessionFailed");
        const tryAgain = findChild(greeter, "sessionFailedNotice").actionItem;
        tryVerify(() => tryAgain.activeFocus);
        keyClick(Qt.Key_Backtab);
        verify(findChild(greeter, "passwordField").activeFocus);
        keyClick(Qt.Key_Tab);
        verify(tryAgain.activeFocus);
        verify(ringOf(tryAgain).visible);
        keyClick(Qt.Key_Tab);
        verify(findChild(greeter, "otherUsersPill").activeFocus);
    }

    function test_typing_goes_into_the_password_field_from_anywhere() {
        const greeter = createGreeter({ users: testCase.twoUsers });
        findChild(greeter, "restartButton").forceActiveFocus();
        keyClick("s");
        keyClick("e");
        const field = findChild(greeter, "passwordField");
        verify(field.activeFocus);
        compare(field.text, "se");
        compare(greeter.backend.calls, []);
    }

    function test_typing_in_the_choose_a_user_panel_stays_out_of_the_password_field() {
        const greeter = createGreeter({ users: testCase.twoUsers });
        findChild(greeter, "otherUsersPill").forceActiveFocus();
        keyClick(Qt.Key_Return);
        compare(greeter.overlay, "otherUsers");
        keyClick("a");
        compare(greeter.overlay, "otherUsers");
        compare(findChild(greeter, "passwordField").text, "");
    }

    function test_typing_on_a_focused_button_shows_caps_lock_on() {
        const greeter = createGreeter();
        findChild(greeter, "sleepButton").forceActiveFocus();
        keyClick("A");
        tryVerify(() => findChild(greeter, "capsLockNotice").visible);
    }
}
