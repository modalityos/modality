import QtQuick
import QtTest
import Quickshell.Services.Greetd
import QuickshellStubs
import "../greeter"

// Seam 2: the real Greeter backend against stubbed Quickshell.
TestCase {
    id: testCase

    name: "RealBackend"

    readonly property var kwinSession: ({
            id: "org.modalityos.kwin",
            name: "ModalityOS (KWin)",
            command: ["/opt/modalityos-dev/bin/modalityos-session-kwin"],
            desktopNames: ["ModalityOS"]
        })

    Component {
        id: backendComponent

        RealBackend {
            prefix: "/opt/modalityos-dev"
        }
    }

    Component {
        id: spyComponent

        SignalSpy {}
    }

    SignalSpy {
        id: authPromptSpy

        signalName: "authPrompt"
    }

    SignalSpy {
        id: authFailureSpy

        signalName: "authFailure"
    }

    SignalSpy {
        id: readyToLaunchSpy

        signalName: "readyToLaunch"
    }

    SignalSpy {
        id: launchedSpy

        signalName: "launched"
    }

    function init() {
        Greetd.reset();
    }

    function createBackend() {
        const backend = createTemporaryObject(backendComponent, testCase);
        verify(backend);
        for (const spy of [authPromptSpy, authFailureSpy, readyToLaunchSpy, launchedSpy]) {
            spy.clear();
            spy.target = backend;
        }
        return backend;
    }

    function test_starting_authentication_creates_a_greetd_session_for_the_user() {
        const backend = createBackend();
        backend.startAuthentication("ian");
        compare(Greetd.lastCall(), ["createSession", "ian"]);
    }

    function test_greetd_password_prompt_is_a_secret_auth_prompt() {
        createBackend();
        Greetd.authMessage("Password: ", false, true, false);
        compare(authPromptSpy.count, 1);
        compare(authPromptSpy.signalArguments[0][0], "Password: ");
        compare(authPromptSpy.signalArguments[0][1], true);
    }

    function test_greetd_info_message_is_not_an_auth_prompt() {
        createBackend();
        Greetd.authMessage("Welcome", false, false, false);
        compare(authPromptSpy.count, 0);
    }

    function test_answer_responds_to_greetd() {
        const backend = createBackend();
        backend.answer("secret");
        compare(Greetd.lastCall(), ["respond", "secret"]);
    }

    function test_cancel_cancels_the_greetd_session() {
        const backend = createBackend();
        backend.cancel();
        compare(Greetd.lastCall(), ["cancelSession"]);
    }

    function test_greetd_auth_failure_is_an_auth_failure() {
        createBackend();
        Greetd.authFailure("Authentication failed");
        compare(authFailureSpy.count, 1);
        compare(authFailureSpy.signalArguments[0][0], "Authentication failed");
    }

    function test_greetd_success_is_ready_to_launch() {
        createBackend();
        Greetd.readyToLaunch();
        compare(readyToLaunchSpy.count, 1);
    }

    function test_launch_starts_the_session_command_as_a_wayland_session() {
        const backend = createBackend();
        backend.launch(testCase.kwinSession);
        compare(Greetd.lastCall(), ["launch", ["/opt/modalityos-dev/bin/modalityos-session-kwin"], [
                    "XDG_SESSION_TYPE=wayland",
                    "XDG_CURRENT_DESKTOP=ModalityOS",
                    "XDG_SESSION_DESKTOP=ModalityOS"
                ], true]);
    }

    function test_greetd_error_is_an_error() {
        const backend = createBackend();
        const spy = createTemporaryObject(spyComponent, testCase, { target: backend, signalName: "error" });
        Greetd.error("Session failed to start");
        compare(spy.count, 1);
        compare(spy.signalArguments[0][0], "Session failed to start");
    }

    function test_unreachable_greetd_at_start_is_login_unavailable() {
        Greetd.available = false;
        const backend = createBackend();
        const spy = createTemporaryObject(spyComponent, testCase, { target: backend, signalName: "loginUnavailable" });
        tryCompare(spy, "count", 1);
    }

    function test_reachable_greetd_is_not_login_unavailable() {
        const backend = createBackend();
        const spy = createTemporaryObject(spyComponent, testCase, { target: backend, signalName: "loginUnavailable" });
        wait(50);
        compare(spy.count, 0);
    }

    function test_losing_greetd_is_login_unavailable() {
        const backend = createBackend();
        const spy = createTemporaryObject(spyComponent, testCase, { target: backend, signalName: "loginUnavailable" });
        wait(50);
        Greetd.available = false;
        tryCompare(spy, "count", 1, 2000);
    }

    function test_starting_authentication_without_greetd_is_login_unavailable() {
        const backend = createBackend();
        const spy = createTemporaryObject(spyComponent, testCase, { target: backend, signalName: "loginUnavailable" });
        Greetd.available = false;
        backend.startAuthentication("ian");
        compare(spy.count, 1);
        compare(Greetd.calls, []);
    }

    function test_greetd_launched_is_launched() {
        createBackend();
        Greetd.launched();
        compare(launchedSpy.count, 1);
    }

    // busctl GetAll output for org.freedesktop.Accounts.User, one line per user.
    readonly property string accountsOutput: [
        '{"type":"a{sv}","data":[{"Uid":{"type":"t","data":1000},"UserName":{"type":"s","data":"ian"},"RealName":{"type":"s","data":"Ian Gregson"},"IconFile":{"type":"s","data":"/var/lib/AccountsService/icons/ian"},"SystemAccount":{"type":"b","data":false}}]}',
        '{"type":"a{sv}","data":[{"Uid":{"type":"t","data":1001},"UserName":{"type":"s","data":"ada"},"RealName":{"type":"s","data":""},"IconFile":{"type":"s","data":""},"SystemAccount":{"type":"b","data":false}}]}',
        ''
    ].join("\n")

    // Desktop entries as the sessions process prints them: a record separator and the
    // path, then the file. The first folder wins for an id found twice.
    readonly property string sessionsOutput: [
        "\u001e/opt/modalityos-dev/share/wayland-sessions/org.modalityos.kwin.desktop",
        "[Desktop Entry]",
        "Name=ModalityOS (KWin)",
        "Name[de]=ModalityOS (KWin) DE",
        "Comment=KWin standalone",
        "Exec=/opt/modalityos-dev/bin/modalityos-session-kwin --flag \"two words\" %U",
        "DesktopNames=ModalityOS;",
        "",
        "[Desktop Action other]",
        "Exec=/bin/false",
        "\u001e/usr/share/wayland-sessions/plasma.desktop",
        "[Desktop Entry]",
        "Exec=/usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland",
        "DesktopNames=KDE",
        "Name=Plasma (Wayland)",
        "\u001e/usr/share/wayland-sessions/org.modalityos.kwin.desktop",
        "[Desktop Entry]",
        "Name=Shadowed",
        "Exec=/bin/false",
        ""
    ].join("\n")

    function test_users_come_from_accountsservice() {
        const backend = createBackend();
        const process = Processes.find("org.freedesktop.Accounts");
        verify(process);
        verify(process.running);
        Processes.finish(process, testCase.accountsOutput);
        compare(backend.users.length, 2);
        compare(backend.users[0].name, "ian");
        compare(backend.users[0].realName, "Ian Gregson");
        compare(backend.users[0].avatar, "file:///var/lib/AccountsService/icons/ian");
        compare(backend.users[0].systemAccount, false);
        compare(backend.users[1].name, "ada");
        compare(backend.users[1].avatar, "");
    }

    function test_unreadable_accountsservice_output_gives_no_users() {
        const backend = createBackend();
        Processes.finish(Processes.find("org.freedesktop.Accounts"), "Failed to connect\n", 1);
        compare(backend.users.length, 0);
    }

    function test_sessions_come_from_wayland_sessions_in_the_prefix_and_the_system() {
        const backend = createBackend();
        const process = Processes.find("wayland-sessions");
        verify(process);
        verify(process.running);
        verify(process.command.includes("/opt/modalityos-dev/share/wayland-sessions"));
        verify(process.command.includes("/usr/share/wayland-sessions"));
        Processes.finish(process, testCase.sessionsOutput);
        compare(backend.sessions.length, 2);
        compare(backend.sessions[0].id, "org.modalityos.kwin");
        compare(backend.sessions[0].name, "ModalityOS (KWin)");
        compare(backend.sessions[0].command,
                ["/opt/modalityos-dev/bin/modalityos-session-kwin", "--flag", "two words"]);
        compare(backend.sessions[0].desktopNames, ["ModalityOS"]);
        compare(backend.sessions[1].id, "plasma");
        compare(backend.sessions[1].command,
                ["/usr/lib/plasma-dbus-run-session-if-needed", "/usr/bin/startplasma-wayland"]);
    }

    function test_default_session_is_modalityos_kwin() {
        const backend = createBackend();
        compare(backend.defaultSession, "org.modalityos.kwin");
    }

    function test_wallpapers_come_from_the_prefix() {
        const backend = createBackend();
        compare(backend.wallpaperFolder, "file:///opt/modalityos-dev/share/modalityos/wallpapers");
    }
}
