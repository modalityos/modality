import QtQuick
import QtTest
import Modality.Theme
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

    // count human users, in AccountsService order; ian is the third.
    function someUsers(count) {
        const names = [
            ["ada", "Ada Lovelace"], ["grace", "Grace Hopper"], ["ian", "Ian Gregson"],
            ["alan", "Alan Turing"], ["edsger", "Edsger Dijkstra"], ["barbara", "Barbara Liskov"],
            ["ken", "Ken Thompson"], ["margaret", "Margaret Hamilton"]
        ];
        return names.slice(0, count).map(([name, realName]) => ({
                    name: name,
                    realName: realName,
                    avatar: "",
                    systemAccount: false
                }));
    }

    function test_without_a_last_user_the_first_user_shows() {
        const greeter = createGreeter({ users: someUsers(3), lastUser: "" });
        compare(findChild(greeter, "userName").text, "Ada Lovelace");
    }

    function test_last_user_who_is_gone_gives_the_first_user() {
        const greeter = createGreeter({ users: someUsers(3), lastUser: "removed" });
        compare(findChild(greeter, "userName").text, "Ada Lovelace");
    }

    function test_one_account_has_no_other_users_pill() {
        const greeter = createGreeter();
        const pill = findChild(greeter, "otherUsersPill");
        verify(!pill || !pill.visible);
    }

    function test_several_accounts_show_the_other_users_pill_data() {
        return [
            { tag: "three users", count: 3 },
            { tag: "eight users", count: 8 }
        ];
    }

    function test_several_accounts_show_the_other_users_pill(data) {
        const greeter = createGreeter({ users: someUsers(data.count), lastUser: "ian" });
        const pill = findChild(greeter, "otherUsersPill");
        verify(pill);
        verify(pill.visible);
        compare(pill.text, "Other users");
        compare(findChild(greeter, "userName").text, "Ian Gregson");
    }

    readonly property url ballAvatar: Qt.resolvedUrl("../data/avatars/avatar-ball.png")
    readonly property url catAvatar: Qt.resolvedUrl("../data/avatars/avatar-cat.png")

    function test_user_with_a_picture_shows_it() {
        const greeter = createGreeter({
            users: [{ name: "ian", realName: "Ian Gregson", avatar: testCase.ballAvatar, systemAccount: false }]
        });
        const avatar = findChild(greeter, "userAvatar");
        compare(avatar.source, testCase.ballAvatar);
        tryCompare(avatar, "status", Image.Ready);
    }

    function test_user_without_a_picture_shows_the_default_avatar() {
        const greeter = createGreeter();
        const avatar = findChild(greeter, "userAvatar");
        compare(avatar.source, testCase.catAvatar);
        tryCompare(avatar, "status", Image.Ready);
    }

    function test_user_whose_picture_cannot_be_read_shows_the_default_avatar() {
        const greeter = createGreeter({
            users: [{ name: "ian", realName: "Ian Gregson", avatar: "file:///nonexistent/ian", systemAccount: false }]
        });
        const avatar = findChild(greeter, "userAvatar");
        tryCompare(avatar, "source", testCase.catAvatar);
        tryCompare(avatar, "status", Image.Ready);
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

    function test_logging_in_remembers_the_user_and_their_session() {
        const greeter = createGreeter();
        logIn(greeter, "secret");
        greeter.backend.readyToLaunch();
        tryVerify(() => greeter.backend.lastCall()[0] === "launch");
        const calls = greeter.backend.calls;
        compare(calls[calls.length - 2], ["remember", "ian", "org.modalityos.kwin"]);
    }

    function test_wrong_password_remembers_nothing() {
        const greeter = createGreeter();
        logIn(greeter, "wrong");
        greeter.backend.authFailure("Authentication failed");
        verify(!greeter.backend.calls.some(call => call[0] === "remember"));
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

    function test_session_that_fails_to_start_brings_the_greeter_back() {
        const greeter = createGreeter();
        logIn(greeter, "secret");
        greeter.backend.readyToLaunch();
        tryVerify(() => greeter.backend.lastCall()[0] === "launch");
        greeter.backend.error("Session failed to start");
        compare(greeter.loginState, "sessionFailed");
        tryCompare(findChild(greeter, "content"), "opacity", 1);
    }
}
