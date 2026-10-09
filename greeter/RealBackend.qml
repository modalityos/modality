import QtQuick
import Quickshell.Io
import Quickshell.Services.Greetd
import "lib"
import "lib/accounts.js" as Accounts
import "lib/desktopEntries.js" as DesktopEntries

// The Greeter backend on a real machine: the thin Quickshell layer. Login goes through
// greetd; everything here maps Quickshell's API onto the Greeter backend interface.
GreeterBackend {
    id: backend

    // The install prefix (MODALITYOS_PREFIX, ADR 0002): where the Greeter's files live.
    property string prefix: "/usr"

    // Machine settings stay at their Defaults until they are read from files.
    defaultSession: "org.modalityos.kwin"
    wallpaperFolder: `file://${prefix}/share/modalityos/wallpapers`

    // Every cached AccountsService user's properties, one JSON line each.
    property Process usersProcess: Process {
        command: ["sh", "-c", `
            busctl --system call org.freedesktop.Accounts /org/freedesktop/Accounts \\
                org.freedesktop.Accounts ListCachedUsers |
            grep -o '"[^"]*"' | tr -d '"' |
            while read -r path; do
                busctl --system --json=short call org.freedesktop.Accounts "$path" \\
                    org.freedesktop.DBus.Properties GetAll s org.freedesktop.Accounts.User
            done`]
        running: true
        stdout: StdioCollector {
            onStreamFinished: backend.users = Accounts.parseUsers(text)
        }
    }

    // Every wayland-sessions desktop entry, the prefix's before the system's.
    property Process sessionsProcess: Process {
        command: ["sh", "-c", `
            for dir in "$@"; do
                for file in "$dir"/*.desktop; do
                    [ -f "$file" ] && printf '\\036%s\\n' "$file" && cat "$file"
                done
            done`, "sh", `${backend.prefix}/share/wayland-sessions`, "/usr/share/wayland-sessions"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: backend.sessions = DesktopEntries.parseSessions(text)
        }
    }

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

        function onError(error) {
            backend.error(error);
        }
    }
}
