import QtQuick
import QtTest
import Quickshell.Services.Greetd
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

    function test_greetd_launched_is_launched() {
        createBackend();
        Greetd.launched();
        compare(launchedSpy.count, 1);
    }
}
