import QtQuick
import Quickshell.Services.Greetd
import "lib"

// The Greeter backend on a real machine: the thin Quickshell layer. Login goes through
// greetd; everything here maps Quickshell's API onto the Greeter backend interface.
GreeterBackend {
    id: backend

    // The install prefix (MODALITYOS_PREFIX, ADR 0002): where the Greeter's files live.
    property string prefix: "/usr"

    function startAuthentication(user) {
        Greetd.createSession(user);
    }

    function answer(response) {
        Greetd.respond(response);
    }

    function cancel() {
        Greetd.cancelSession();
    }

    // Quickshell quits once greetd takes the Session; the screen has already faded out.
    function launch(session) {
        const environment = ["XDG_SESSION_TYPE=wayland"];
        if (session.desktopNames.length > 0) {
            environment.push(`XDG_CURRENT_DESKTOP=${session.desktopNames.join(":")}`);
            environment.push(`XDG_SESSION_DESKTOP=${session.desktopNames[0]}`);
        }
        Greetd.launch(session.command, environment, true);
    }

    property Connections greetdConnections: Connections {
        target: Greetd

        // greetd's info messages need no answer; Quickshell acknowledges them itself.
        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (responseRequired)
                backend.authPrompt(message, !echoResponse);
        }

        function onAuthFailure(message) {
            backend.authFailure(message);
        }

        function onReadyToLaunch() {
            backend.readyToLaunch();
        }

        function onLaunched() {
            backend.launched();
        }
    }
}
