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
        const greeter = createTemporaryObject(greeterComponent, testCase, {
            backend: backend
        });
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
            lastUser: "katherine"
        });
        compare(findChild(greeter, "userName").text, "Katherine Johnson");
    }

    function test_user_without_a_real_name_shows_the_user_name() {
        const greeter = createGreeter({
            users: [
                {
                    name: "katherine",
                    realName: "",
                    avatar: "",
                    systemAccount: false
                }
            ]
        });
        compare(findChild(greeter, "userName").text, "katherine");
    }

    // count human users, in AccountsService order; katherine is the third.
    function someUsers(count) {
        const names = [["ada", "Ada Lovelace"], ["grace", "Grace Hopper"], ["katherine", "Katherine Johnson"], ["alan", "Alan Turing"], ["edsger", "Edsger Dijkstra"], ["barbara", "Barbara Liskov"], ["ken", "Ken Thompson"], ["margaret", "Margaret Hamilton"]];
        return names.slice(0, count).map(([name, realName]) => ({
                    name: name,
                    realName: realName,
                    avatar: "",
                    systemAccount: false
                }));
    }

    function test_without_a_last_user_the_first_user_shows() {
        const greeter = createGreeter({
            users: someUsers(3),
            lastUser: ""
        });
        compare(findChild(greeter, "userName").text, "Ada Lovelace");
    }

    function test_last_user_who_is_gone_gives_the_first_user() {
        const greeter = createGreeter({
            users: someUsers(3),
            lastUser: "removed"
        });
        compare(findChild(greeter, "userName").text, "Ada Lovelace");
    }

    function test_one_account_has_no_other_users_pill() {
        const greeter = createGreeter();
        const pill = findChild(greeter, "otherUsersPill");
        verify(!pill || !pill.visible);
    }

    function test_several_accounts_show_the_other_users_pill_data() {
        return [
            {
                tag: "three users",
                count: 3
            },
            {
                tag: "eight users",
                count: 8
            }
        ];
    }

    function test_several_accounts_show_the_other_users_pill(data) {
        const greeter = createGreeter({
            users: someUsers(data.count),
            lastUser: "katherine"
        });
        const pill = findChild(greeter, "otherUsersPill");
        verify(pill);
        verify(pill.visible);
        compare(pill.text, "Other users");
        compare(findChild(greeter, "userName").text, "Katherine Johnson");
    }

    function openOtherUsers(greeter) {
        mouseClick(findChild(greeter, "otherUsersPill"));
        const panel = findChild(greeter, "userPanel");
        verify(panel);
        tryCompare(panel, "opacity", 1);
        return panel;
    }

    function userCells(greeter) {
        const cells = [];
        for (let index = 0; ; index++) {
            const cell = findChild(greeter, `userCell${index}`);
            if (!cell)
                return cells;
            cells.push(cell);
        }
    }

    function test_other_users_pill_opens_the_choose_a_user_panel_data() {
        return [
            {
                tag: "three users in one row of three",
                count: 3,
                columns: 3
            },
            {
                tag: "eight users in two rows of four",
                count: 8,
                columns: 4
            }
        ];
    }

    function test_other_users_pill_opens_the_choose_a_user_panel(data) {
        const greeter = createGreeter({
            users: someUsers(data.count),
            lastUser: "katherine"
        });
        verify(!findChild(greeter, "userPanel").visible);
        const panel = openOtherUsers(greeter);
        compare(greeter.overlay, "otherUsers");
        verify(panel.visible);
        compare(findChild(panel, "userPanelTitle").text, "Choose a user");
        compare(findChild(panel, "userGrid").columns, data.columns);
        const cells = userCells(greeter);
        compare(cells.map(cell => cell.text), someUsers(data.count).map(user => user.realName));
        // The shown user's cell starts highlighted.
        verify(cells[2].activeFocus);
    }

    function test_avatars_in_the_choose_a_user_panel_rest_on_the_raised_shadow() {
        const greeter = createGreeter({
            users: someUsers(3),
            lastUser: "katherine"
        });
        openOtherUsers(greeter);
        const avatar = findChild(userCells(greeter)[0], "userCellAvatar");
        verify(avatar);
        compare(avatar.size, 64);
        compare(avatar.shadow, Theme.shadowRaised);
    }

    function test_arrows_move_between_users_in_the_choose_a_user_panel() {
        const greeter = createGreeter({
            users: someUsers(8),
            lastUser: "katherine"
        });
        openOtherUsers(greeter);
        const cells = userCells(greeter);
        tryVerify(() => cells[2].activeFocus);
        keyClick(Qt.Key_Right);
        verify(cells[3].activeFocus);
        keyClick(Qt.Key_Right);
        verify(cells[4].activeFocus);
        keyClick(Qt.Key_Left);
        verify(cells[3].activeFocus);
        keyClick(Qt.Key_Down);
        verify(cells[7].activeFocus);
        keyClick(Qt.Key_Down);
        verify(cells[7].activeFocus);
        keyClick(Qt.Key_Up);
        verify(cells[3].activeFocus);
        keyClick(Qt.Key_Up);
        verify(cells[3].activeFocus);
    }

    function test_enter_picks_the_highlighted_user_and_closes_the_panel() {
        const greeter = createGreeter({
            users: someUsers(3),
            lastUser: "katherine"
        });
        typeText("half");
        const panel = openOtherUsers(greeter);
        tryVerify(() => userCells(greeter)[2].activeFocus);
        keyClick(Qt.Key_Left);
        keyClick(Qt.Key_Return);
        compare(greeter.overlay, "");
        tryCompare(panel, "visible", false);
        compare(findChild(greeter, "userName").text, "Grace Hopper");
        const field = findChild(greeter, "passwordField");
        compare(field.text, "");
        verify(field.activeFocus);

        typeText("secret");
        keyClick(Qt.Key_Return);
        compare(greeter.backend.lastCall(), ["startAuthentication", "grace"]);
    }

    function test_clicking_a_user_picks_them() {
        const greeter = createGreeter({
            users: someUsers(3),
            lastUser: "katherine"
        });
        openOtherUsers(greeter);
        mouseClick(userCells(greeter)[0]);
        compare(greeter.overlay, "");
        compare(findChild(greeter, "userName").text, "Ada Lovelace");
    }

    function test_esc_closes_the_choose_a_user_panel_with_no_change() {
        const greeter = createGreeter({
            users: someUsers(3),
            lastUser: "katherine"
        });
        const panel = openOtherUsers(greeter);
        tryVerify(() => userCells(greeter)[2].activeFocus);
        keyClick(Qt.Key_Left);
        keyClick(Qt.Key_Escape);
        compare(greeter.overlay, "");
        tryCompare(panel, "visible", false);
        compare(findChild(greeter, "userName").text, "Katherine Johnson");
        verify(findChild(greeter, "otherUsersPill").activeFocus);
    }

    function test_cancel_closes_the_choose_a_user_panel_with_no_change() {
        const greeter = createGreeter({
            users: someUsers(3),
            lastUser: "katherine"
        });
        openOtherUsers(greeter);
        mouseClick(findChild(greeter, "userPanelCancel"));
        compare(greeter.overlay, "");
        compare(findChild(greeter, "userName").text, "Katherine Johnson");
    }

    function test_clicking_outside_the_panel_closes_it() {
        const greeter = createGreeter({
            users: someUsers(3),
            lastUser: "katherine"
        });
        openOtherUsers(greeter);
        mouseClick(greeter, 10, 10);
        compare(greeter.overlay, "");
    }

    function test_enter_on_the_other_users_pill_opens_the_panel() {
        const greeter = createGreeter({
            users: someUsers(3),
            lastUser: "katherine"
        });
        findChild(greeter, "otherUsersPill").forceActiveFocus();
        keyClick(Qt.Key_Return);
        compare(greeter.overlay, "otherUsers");
    }

    function test_choose_a_user_panel_stays_shut_while_checking() {
        const greeter = createGreeter({
            users: someUsers(3),
            lastUser: "katherine"
        });
        typeText("secret");
        keyClick(Qt.Key_Return);
        mouseClick(findChild(greeter, "otherUsersPill"));
        compare(greeter.overlay, "");
    }

    function test_long_name_wraps_within_the_user_column_on_a_short_screen() {
        const users = someUsers(3);
        users[2].realName = "Alexandria Montgomery-Fitzwilliam";
        const greeter = createGreeter({
            users: users,
            lastUser: "katherine"
        });
        greeter.width = 1366;
        greeter.height = 768;
        const name = findChild(greeter, "userName");
        compare(name.text, "Alexandria Montgomery-Fitzwilliam");
        // Two lines in Inter; the line count varies with the font installed.
        verify(name.lineCount <= 2);
        verify(name.contentWidth <= 280);
        compare(name.wrapMode, Text.Wrap);
        const column = name.parent;
        compare(column.width, 280);
        const clock = findChild(greeter, "clock");
        const clockBottom = clock.mapToItem(greeter, 0, clock.height).y;
        const columnTop = column.mapToItem(greeter, 0, 0).y;
        verify(columnTop > clockBottom, `column top ${columnTop} under clock bottom ${clockBottom}`);
        const pill = findChild(greeter, "otherUsersPill");
        verify(pill.mapToItem(greeter, 0, pill.height).y <= greeter.height - 96);
    }

    function test_long_name_wraps_within_its_cell_in_the_choose_a_user_panel() {
        const users = someUsers(8);
        users[2].realName = "Alexandria Montgomery-Fitzwilliam";
        const greeter = createGreeter({
            users: users,
            lastUser: "katherine"
        });
        openOtherUsers(greeter);
        const cell = userCells(greeter)[2];
        const label = cell.contentItem.children[1];
        compare(label.text, "Alexandria Montgomery-Fitzwilliam");
        verify(label.lineCount >= 2);
        verify(label.contentWidth <= cell.availableWidth);
        compare(cell.width, userCells(greeter)[3].width);
    }

    readonly property url ballAvatar: Qt.resolvedUrl("../data/avatars/avatar-ball.png")
    readonly property url catAvatar: Qt.resolvedUrl("../data/avatars/avatar-cat.png")

    function test_user_with_a_picture_shows_it() {
        const greeter = createGreeter({
            users: [
                {
                    name: "katherine",
                    realName: "Katherine Johnson",
                    avatar: testCase.ballAvatar,
                    systemAccount: false
                }
            ]
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
            users: [
                {
                    name: "katherine",
                    realName: "Katherine Johnson",
                    avatar: "file:///nonexistent/katherine",
                    systemAccount: false
                }
            ]
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

    function test_clock_keeps_turning_over_minute_after_minute() {
        const greeter = createGreeter();
        const clock = findChild(greeter, "clock");
        // 200 ms before a minute boundary, so the clock's next turn comes quickly; twice,
        // because a clock that turns over only once looks right for its first minute.
        for (let turn = 1; turn <= 2; turn++) {
            const nearBoundary = new Date(2026, 9, 9, 9, 41, 59, 800);
            clock.now = nearBoundary;
            tryVerify(() => clock.now.getTime() !== nearBoundary.getTime(), 2000, `turn ${turn}: the clock turned over`);
        }
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
        compare(findChild(greeter, "wallpaper").source, Qt.resolvedUrl("fixtures/wallpapers/wallpaper-silk-dark-3840x2160.png"));
    }

    function test_greeter_shows_silk_light_in_the_light_theme() {
        const greeter = createGreeter({
            theme: "light"
        });
        greeter.width = 1920;
        greeter.height = 1080;
        compare(Theme.theme, "light");
        compare(findChild(greeter, "wallpaper").source, Qt.resolvedUrl("fixtures/wallpapers/wallpaper-silk-light-3840x2160.png"));
    }

    function test_sixteen_by_ten_screen_shows_the_3840x2400_render() {
        const greeter = createGreeter();
        greeter.width = 1680;
        greeter.height = 1050;
        compare(findChild(greeter, "wallpaper").source, Qt.resolvedUrl("fixtures/wallpapers/wallpaper-silk-dark-3840x2400.png"));
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
            return frost.region.x === behind.x && frost.region.y === behind.y && frost.region.width === 240 && frost.region.height === Theme.controlHeightLarge;
        });
    }

    function test_correct_password_launches_the_session() {
        const greeter = createGreeter();
        const backend = greeter.backend;
        compare(greeter.loginState, "ready");

        typeText("secret");
        keyClick(Qt.Key_Return);
        compare(greeter.loginState, "checking");
        compare(backend.lastCall(), ["startAuthentication", "katherine"]);

        backend.authPrompt("Password:", true);
        compare(backend.lastCall(), ["answer", "secret"]);

        backend.readyToLaunch();
        compare(greeter.loginState, "starting");
        tryVerify(() => backend.lastCall()[0] === "launch");
        compare(backend.lastCall(), ["launch", "org.modalityos.kwin"]);
    }

    // No Session is saved without a pick, so a later change to the default Session reaches the user.
    function test_logging_in_without_picking_a_session_remembers_only_the_user() {
        const greeter = createGreeter();
        logIn(greeter, "secret");
        greeter.backend.readyToLaunch();
        tryVerify(() => greeter.backend.lastCall()[0] === "launch");
        const calls = greeter.backend.calls;
        compare(calls[calls.length - 2], ["remember", "katherine", ""]);
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

    function test_greetd_error_while_checking_shows_in_a_danger_notice_not_wrong_password() {
        const greeter = createGreeter();
        logIn(greeter, "secret");
        greeter.backend.authError("Your account has expired");
        greeter.backend.authFailure("Authentication failed");
        const notice = findChild(greeter, "authErrorNotice");
        verify(notice);
        tryCompare(notice, "visible", true);
        compare(notice.text, "Your account has expired");
        compare(notice.tone, Notice.Danger);
        verify(!findChild(greeter, "wrongPasswordNotice").visible);
        tryCompare(findChild(greeter, "passwordField"), "text", "");
    }

    function test_greetd_failing_while_checking_is_not_a_failed_session() {
        const greeter = createGreeter();
        logIn(greeter, "secret");
        greeter.backend.authError("Your account has expired");
        greeter.backend.error("Account check failed");
        verify(greeter.loginState !== "sessionFailed");
        verify(!findChild(greeter, "sessionFailedNotice").visible);
        const notice = findChild(greeter, "authErrorNotice");
        tryCompare(notice, "visible", true);
        compare(notice.text, "Your account has expired");
        const field = findChild(greeter, "passwordField");
        compare(field.text, "");
        verify(field.activeFocus);

        logIn(greeter, "secret");
        compare(greeter.backend.lastCall(), ["answer", "secret"]);
    }

    function test_greetd_failing_while_checking_without_a_message_shows_its_error() {
        const greeter = createGreeter();
        logIn(greeter, "secret");
        greeter.backend.error("Account check failed");
        const notice = findChild(greeter, "authErrorNotice");
        tryCompare(notice, "visible", true);
        compare(notice.text, "Account check failed");
    }

    function test_typing_again_hides_the_greetd_error_notice() {
        const greeter = createGreeter();
        logIn(greeter, "secret");
        greeter.backend.error("Account check failed");
        tryCompare(findChild(greeter, "authErrorNotice"), "visible", true);
        typeText("s");
        tryCompare(findChild(greeter, "authErrorNotice"), "visible", false, 1000);
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

    function test_login_unavailable_removes_the_other_users_pill() {
        const greeter = createGreeter({
            users: someUsers(3),
            lastUser: "katherine"
        });
        greeter.backend.loginUnavailable();
        verify(!findChild(greeter, "otherUsersPill").visible);
    }

    function test_picking_a_user_after_a_failed_session_starts_a_fresh_login() {
        const greeter = createGreeter({
            users: someUsers(3),
            lastUser: "katherine"
        });
        failSession(greeter);
        openOtherUsers(greeter);
        mouseClick(userCells(greeter)[0]);
        compare(greeter.backend.lastCall(), ["cancel"]);
        compare(greeter.loginState, "ready");
        tryCompare(findChild(greeter, "sessionFailedNotice"), "visible", false);
        verify(findChild(greeter, "passwordField").activeFocus);
        logIn(greeter, "secret");
        compare(greeter.backend.calls.find(call => call[0] === "startAuthentication" && call[1] === "ada"), ["startAuthentication", "ada"]);
    }

    function test_login_unavailable_while_checking_ends_the_attempt() {
        const greeter = createGreeter();
        typeText("SECRET");
        keyClick(Qt.Key_Return);
        greeter.backend.loginUnavailable();
        compare(greeter.loginState, "unavailable");
        greeter.backend.authPrompt("Password:", true);
        compare(greeter.backend.lastCall(), ["startAuthentication", "katherine"]);
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
