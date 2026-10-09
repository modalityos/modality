import QtQuick
import QtTest
import Modality.Theme
import Modality.Controls
import "../greeter/lib"
import "helpers"

// Seam 1: the Greeter driven through a fake Greeter backend.
TestCase {
    id: testCase

    name: "Greeter"
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
    }

    function typeText(text) {
        for (const character of text)
            keyClick(character);
    }

    function test_typing_goes_into_the_password_field_from_ready() {
        const greeter = createGreeter();
        typeText("se");
        compare(greeter.loginState, "typing");
        compare(findChild(greeter, "passwordField").text, "se");
    }

    function test_greeter_shows_the_last_user_name() {
        const greeter = createGreeter({
            users: [
                { name: "ada", realName: "Ada Lovelace", avatar: "", systemAccount: false },
                { name: "ian", realName: "Ian Gregson", avatar: "", systemAccount: false }
            ],
            lastUser: "ian"
        });
        compare(findChild(greeter, "userName").text, "Ian Gregson");
    }

    function test_user_without_a_real_name_shows_the_user_name() {
        const greeter = createGreeter({
            users: [{ name: "ian", realName: "", avatar: "", systemAccount: false }]
        });
        compare(findChild(greeter, "userName").text, "ian");
    }

    function test_clock_shows_the_time_in_display_with_tabular_figures() {
        const greeter = createGreeter();
        const clock = findChild(greeter, "clock");
        clock.now = new Date(2026, 9, 9, 9, 41);
        const time = findChild(greeter, "clockTime");
        compare(time.text, "09:41");
        compare(time.font.pixelSize, 96);
        compare(time.font.weight, Font.DemiBold);
        compare(time.font.features.tnum, 1);
    }

    function test_clock_shows_the_date_in_title1() {
        const greeter = createGreeter();
        const clock = findChild(greeter, "clock");
        clock.now = new Date(2026, 9, 9, 9, 41);
        const date = findChild(greeter, "clockDate");
        compare(date.text, "Friday 9 October");
        compare(date.font.pixelSize, 22);
        compare(date.font.weight, Font.DemiBold);
    }

    function test_greeter_shows_silk_dark_in_the_dark_theme() {
        const greeter = createGreeter();
        greeter.width = 1920;
        greeter.height = 1080;
        compare(Theme.theme, "dark");
        compare(findChild(greeter, "wallpaper").source,
                Qt.resolvedUrl("fixtures/wallpapers/wallpaper-silk-dark-3840x2160.png"));
    }

    function test_greeter_shows_silk_light_in_the_light_theme() {
        const greeter = createGreeter({ theme: "light" });
        greeter.width = 1920;
        greeter.height = 1080;
        compare(Theme.theme, "light");
        compare(findChild(greeter, "wallpaper").source,
                Qt.resolvedUrl("fixtures/wallpapers/wallpaper-silk-light-3840x2160.png"));
    }

    function test_sixteen_by_ten_screen_shows_the_3840x2400_render() {
        const greeter = createGreeter();
        greeter.width = 1680;
        greeter.height = 1050;
        compare(findChild(greeter, "wallpaper").source,
                Qt.resolvedUrl("fixtures/wallpapers/wallpaper-silk-dark-3840x2400.png"));
    }

    function test_password_field_is_frosted_with_the_wallpaper_behind_it() {
        const greeter = createGreeter();
        greeter.width = 1920;
        greeter.height = 1080;
        const field = findChild(greeter, "passwordField");
        const frost = findChild(greeter, "passwordFrost");
        verify(frost);
        verify(frost.visible);
        compare(frost.blurRadius, Theme.materialPopoverBlur);
        fuzzyCompare(frost.saturation, 0.6, 0.001);
        tryVerify(() => {
            const behind = field.mapToItem(greeter, 0, 0, field.width, field.height);
            return frost.region.x === behind.x && frost.region.y === behind.y
                && frost.region.width === 240 && frost.region.height === Theme.controlHeightLarge;
        });
    }

    function test_correct_password_launches_the_session() {
        const greeter = createGreeter();
        const backend = greeter.backend;
        compare(greeter.loginState, "ready");

        typeText("secret");
        keyClick(Qt.Key_Return);
        compare(greeter.loginState, "checking");
        compare(backend.lastCall(), ["startAuthentication", "ian"]);

        backend.authPrompt("Password:", true);
        compare(backend.lastCall(), ["answer", "secret"]);

        backend.readyToLaunch();
        compare(greeter.loginState, "starting");
        tryVerify(() => backend.lastCall()[0] === "launch");
        compare(backend.lastCall(), ["launch", "org.modalityos.kwin"]);
    }

    function logIn(greeter, password) {
        typeText(password);
        keyClick(Qt.Key_Return);
        greeter.backend.authPrompt("Password:", true);
    }

    function test_wrong_password_clears_the_field_to_try_again() {
        const greeter = createGreeter();
        logIn(greeter, "wrong");
        greeter.backend.authFailure("Authentication failed");
        compare(greeter.loginState, "wrongPassword");
        const field = findChild(greeter, "passwordField");
        tryCompare(field, "text", "");
        verify(field.activeFocus);

        logIn(greeter, "secret");
        compare(greeter.backend.lastCall(), ["answer", "secret"]);
    }

    function test_wrong_password_shakes_the_field_then_clears_it() {
        const greeter = createGreeter();
        logIn(greeter, "wrong");
        greeter.backend.authFailure("Authentication failed");
        const field = findChild(greeter, "passwordField");
        verify(field.shaking);
        compare(field.text, "wrong");
        compare(greeter.loginState, "wrongPassword");
        tryCompare(field, "shaking", false);
        compare(field.text, "");
        compare(greeter.loginState, "wrongPassword");
    }

    function test_wrong_password_notice_shows_for_three_seconds() {
        const greeter = createGreeter();
        logIn(greeter, "wrong");
        greeter.backend.authFailure("Authentication failed");
        const notice = findChild(greeter, "wrongPasswordNotice");
        verify(notice);
        compare(notice.text, "Wrong password");
        compare(notice.tone, Notice.Danger);
        tryVerify(() => notice.visible && notice.opacity === 1);
        wait(2000);
        verify(notice.visible);
        tryCompare(notice, "visible", false, 2500);
        compare(findChild(greeter, "passwordField").text, "");
    }

    function test_typing_again_hides_the_wrong_password_notice() {
        const greeter = createGreeter();
        logIn(greeter, "wrong");
        greeter.backend.authFailure("Authentication failed");
        const field = findChild(greeter, "passwordField");
        tryCompare(field, "shaking", false);
        typeText("s");
        tryCompare(findChild(greeter, "wrongPasswordNotice"), "visible", false, 1000);
    }

    function test_upper_case_letter_without_shift_shows_caps_lock_on() {
        const greeter = createGreeter();
        const notice = findChild(greeter, "capsLockNotice");
        verify(notice);
        keyClick("a");
        verify(!notice.visible);
        keyClick("B");
        tryCompare(notice, "visible", true);
        compare(notice.text, "Caps Lock is on");
        compare(notice.tone, Notice.Warning);
        compare(greeter.loginState, "typing");
    }

    function test_lower_case_letter_hides_caps_lock_on() {
        const greeter = createGreeter();
        const notice = findChild(greeter, "capsLockNotice");
        keyClick("B");
        tryCompare(notice, "visible", true);
        keyClick("c");
        tryCompare(notice, "visible", false);
    }

    function test_upper_case_letter_with_shift_is_not_caps_lock() {
        const greeter = createGreeter();
        keyClick("B", Qt.ShiftModifier);
        keyClick("1");
        wait(Theme.motionDurationNormal);
        verify(!findChild(greeter, "capsLockNotice").visible);
    }

    function test_caps_lock_notice_hides_while_checking() {
        const greeter = createGreeter();
        typeText("SECRET");
        const notice = findChild(greeter, "capsLockNotice");
        tryCompare(notice, "visible", true);
        keyClick(Qt.Key_Return);
        compare(greeter.loginState, "checking");
        tryCompare(notice, "visible", false);
    }

    function test_escape_clears_the_password_field() {
        const greeter = createGreeter();
        typeText("secret");
        keyClick(Qt.Key_Escape);
        compare(findChild(greeter, "passwordField").text, "");
        compare(greeter.loginState, "ready");
    }

    function test_session_that_fails_to_start_brings_the_greeter_back() {
        const greeter = createGreeter();
        logIn(greeter, "secret");
        greeter.backend.readyToLaunch();
        tryVerify(() => greeter.backend.lastCall()[0] === "launch");
        greeter.backend.error("Session failed to start");
        compare(greeter.loginState, "sessionFailed");
        tryCompare(findChild(greeter, "content"), "opacity", 1);
    }

    function test_checking_shows_the_spinner_and_ignores_typing() {
        const greeter = createGreeter();
        typeText("secret");
        keyClick(Qt.Key_Return);
        compare(greeter.loginState, "checking");
        const field = findChild(greeter, "passwordField");
        verify(field.busy);
        verify(!field.interactive);
        keyClick("x");
        compare(field.text, "secret");
        greeter.backend.authPrompt("Password:", true);
        compare(greeter.loginState, "checking");
        verify(field.busy);
    }

    function failSession(greeter) {
        logIn(greeter, "secret");
        greeter.backend.readyToLaunch();
        tryVerify(() => greeter.backend.lastCall()[0] === "launch");
        greeter.backend.error("Session failed to start");
    }

    function test_session_failed_moves_focus_to_try_again() {
        const greeter = createGreeter();
        failSession(greeter);
        const notice = findChild(greeter, "sessionFailedNotice");
        verify(notice);
        tryCompare(notice, "visible", true);
        compare(notice.text, "Couldn't start the session.");
        compare(notice.tone, Notice.Danger);
        compare(notice.actionText, "Try again");
        verify(notice.actionItem.activeFocus);
        const field = findChild(greeter, "passwordField");
        compare(field.text, "");
        verify(!field.activeFocus);
    }

    function test_try_again_returns_to_ready() {
        const greeter = createGreeter();
        failSession(greeter);
        keyClick(Qt.Key_Return);
        compare(greeter.loginState, "ready");
        compare(greeter.backend.lastCall(), ["cancel"]);
        const field = findChild(greeter, "passwordField");
        verify(field.activeFocus);
        tryCompare(findChild(greeter, "sessionFailedNotice"), "visible", false);

        logIn(greeter, "secret");
        greeter.backend.readyToLaunch();
        tryVerify(() => greeter.backend.lastCall()[0] === "launch");
        compare(greeter.backend.lastCall(), ["launch", "org.modalityos.kwin"]);
    }

    function test_login_unavailable_replaces_the_password_field_with_a_message() {
        const greeter = createGreeter();
        greeter.backend.loginUnavailable();
        compare(greeter.loginState, "unavailable");
        verify(!findChild(greeter, "passwordField").visible);
        const message = findChild(greeter, "unavailableMessage");
        verify(message);
        verify(message.visible);
        compare(message.text, "Login is unavailable. Restart the computer or switch to a text console.");
        verify(findChild(greeter, "userName").visible);
        verify(findChild(greeter, "clock").visible);
    }

    function test_login_unavailable_while_checking_ends_the_attempt() {
        const greeter = createGreeter();
        typeText("SECRET");
        keyClick(Qt.Key_Return);
        greeter.backend.loginUnavailable();
        compare(greeter.loginState, "unavailable");
        greeter.backend.authPrompt("Password:", true);
        compare(greeter.backend.lastCall(), ["startAuthentication", "ian"]);
        verify(!findChild(greeter, "capsLockNotice").visible);
    }

    function test_starting_fades_everything_above_the_wallpaper() {
        const greeter = createGreeter();
        logIn(greeter, "secret");
        greeter.backend.readyToLaunch();
        const content = findChild(greeter, "content");
        tryCompare(content, "opacity", 0);
        verify(findChild(greeter, "wallpaper").visible);
        compare(greeter.backend.lastCall(), ["launch", "org.modalityos.kwin"]);
    }
}
