import QtQuick
import Quickshell.Io
import Quickshell.Services.Greetd
import "lib"
import "lib/accounts.js" as Accounts
import "lib/desktopEntries.js" as DesktopEntries
import "lib/greeterState.js" as GreeterState
import "lib/machineSettings.js" as MachineSettings

// The Greeter backend on a real machine: the thin Quickshell layer. Login goes through
// greetd; everything here maps Quickshell's API onto the Greeter backend interface.
GreeterBackend {
    id: backend

    // The install prefix (MODALITYOS_PREFIX, ADR 0002): where the Greeter's files live.
    property string prefix: "/usr"

    // Machine settings: the Defaults shipped in the prefix, Admin overrides winning.
    readonly property var machineSettings: MachineSettings.resolveSettings([defaultsFile.text(), adminOverridesFile.text()])

    theme: machineSettings.theme
    clock24Hour: machineSettings.clock24Hour
    defaultSession: machineSettings.defaultSession
    wallpaper: machineSettings.wallpaper
    reduceTransparency: machineSettings.reduceTransparency
    wallpaperFolder: `file://${prefix}/share/modalityos/wallpapers`

    property FileView defaultsFile: FileView {
        path: `${backend.prefix}/share/modalityos/settings.json`
        blockLoading: true
    }

    property FileView adminOverridesFile: FileView {
        path: "/etc/modalityos/settings.json"
        blockLoading: true
        // Most machines have no Admin overrides; a missing file is not an error.
        printErrors: false
    }
    defaultAvatar: `file://${prefix}/share/modalityos/avatars/avatar-cat.png`

    // The last user to log in and each user's Session; the greeter user owns the folder.
    property string statePath: "/var/lib/modalityos/greeter/state.json"
    readonly property var storedState: GreeterState.parseState(stateFile.text())

    lastUser: storedState.lastUser
    rememberedSessions: storedState.sessions

    // Writes block: Quickshell quits as soon as greetd takes the Session.
    property FileView stateFile: FileView {
        path: backend.statePath
        blockLoading: true
        blockWrites: true
    }

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

    // Greetd.available is read fresh each time: Quickshell clears it when the socket fails,
    // but declares it constant and emits nothing, so a lost greetd is found by checking.
    property bool unavailableReported: false

    function checkAvailable() {
        if (Greetd.available || unavailableReported)
            return Greetd.available;
        unavailableReported = true;
        loginUnavailable();
        return false;
    }

    // After the whole Greeter exists, so the logic hears it.
    Component.onCompleted: Qt.callLater(checkAvailable)

    property Timer availabilityTimer: Timer {
        interval: 1000
        repeat: true
        running: !backend.unavailableReported
        onTriggered: backend.checkAvailable()
    }

    function startAuthentication(user) {
        if (checkAvailable())
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
        if (!session) {
            backend.error("No session to start");
            return;
        }
        const environment = ["XDG_SESSION_TYPE=wayland"];
        if (session.desktopNames.length > 0) {
            environment.push(`XDG_CURRENT_DESKTOP=${session.desktopNames.join(":")}`);
            environment.push(`XDG_SESSION_DESKTOP=${session.desktopNames[0]}`);
        }
        Greetd.launch(session.command, environment, true);
    }

    function remember(user, sessionId) {
        stateFile.setText(GreeterState.formatState(GreeterState.withLogin(storedState, user, sessionId)));
    }

    // Power goes through logind; a polkit rule lets the greeter user do it.
    property Process powerProcess: Process {}

    function runPower(verb) {
        powerProcess.command = ["systemctl", verb];
        powerProcess.running = true;
    }

    function suspend() {
        runPower("suspend");
    }

    function reboot() {
        runPower("reboot");
    }

    function powerOff() {
        runPower("poweroff");
    }

    property Connections greetdConnections: Connections {
        target: Greetd

        // Messages that need no answer are acknowledged by Quickshell itself; only errors
        // reach the user, since info messages are noise on a login screen.
        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (responseRequired)
                backend.authPrompt(message, !echoResponse);
            else if (error)
                backend.authError(message);
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
