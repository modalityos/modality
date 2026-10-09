pragma ComponentBehavior: Bound
import QtQuick
import QtTest
import Modality.Theme
import "../greeter/lib"
import "helpers"

// Seam 1: Ready at 1366 x 768. The short-screen layout keeps every part on screen and apart.
TestCase {
    id: testCase

    name: "GreeterLayout"
    width: 1366
    height: 768
    visible: true
    when: windowShown

    Component {
        id: backendComponent

        FakeBackend {}
    }

    Component {
        id: greeterComponent

        Greeter {
            width: 1366
            height: 768
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
    }

    function box(greeter, name) {
        const item = findChild(greeter, name);
        verify(item, `${name} exists`);
        return item.mapToItem(greeter, 0, 0, item.width, item.height);
    }

    function verifyOnScreen(greeter, name) {
        const b = box(greeter, name);
        verify(b.x >= 0 && b.y >= 0 && b.x + b.width <= greeter.width && b.y + b.height <= greeter.height,
               `${name} at ${b.x},${b.y} ${b.width}x${b.height} is on screen`);
    }

    function test_ready_at_1366x768_fits_with_nothing_cut_off() {
        // A tall user column: a two-line name, the Wrong password Notice and the Other users pill.
        const greeter = createGreeter({
            users: [
                { name: "alex", realName: "Alexandria Montgomery-Fitzwilliam", avatar: "", systemAccount: false },
                { name: "katherine", realName: "Katherine Johnson", avatar: "", systemAccount: false }
            ],
            lastUser: "alex"
        });
        keyClick("x");
        keyClick(Qt.Key_Return);
        greeter.backend.authPrompt("Password:", true);
        greeter.backend.authFailure("Authentication failed");
        tryVerify(() => findChild(greeter, "passwordField").text === "", 2000);
        tryVerify(() => findChild(greeter, "wrongPasswordNotice").opacity === 1, 2000);

        compare(greeter.shortScreen, true);
        for (const name of ["clock", "userAvatar", "userName", "passwordField", "wrongPasswordNotice",
                            "otherUsersPill", "powerRow"])
            verifyOnScreen(greeter, name);

        const clock = box(greeter, "clock");
        const avatar = box(greeter, "userAvatar");
        const pill = box(greeter, "otherUsersPill");
        const power = box(greeter, "powerRow");
        verify(clock.y + clock.height <= avatar.y, `the Clock (bottom ${clock.y + clock.height}) stays above the Avatar (top ${avatar.y})`);
        verify(pill.y + pill.height <= power.y, `the user column (bottom ${pill.y + pill.height}) stays above the power row (top ${power.y})`);
        compare(clock.y, 56);
        compare(power.y + power.height, 768 - 28);
    }

    function test_options_fits_at_1366x768() {
        const greeter = createGreeter({
            sessions: [
                { id: "org.modalityos.kwin", name: "ModalityOS (KWin)", command: ["kwin"], desktopNames: ["ModalityOS"] },
                { id: "org.modalityos.hyprland", name: "ModalityOS (Hyprland)", command: ["hyprland"], desktopNames: ["ModalityOS"] }
            ]
        });
        verifyOnScreen(greeter, "optionsButton");
        const options = box(greeter, "optionsButton");
        compare(options.x + options.width, 1366 - Theme.space10);
        compare(options.y + options.height, 768 - 28);
    }
}
