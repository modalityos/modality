import QtQuick

// What the Greeter is doing, driven by the Greeter backend's events and the screen's input.
// A login: submit asks greetd for a session, the password answers its prompt, and once
// greetd is ready the screen fades out (starting) and then calls launch().
QtObject {
    id: logic

    property GreeterBackend backend

    // ready, typing, checking or starting.
    readonly property string state: {
        if (phase !== "ready")
            return phase;
        return passwordLength > 0 ? "typing" : "ready";
    }

    // Set by the screen as the password field changes.
    property int passwordLength: 0

    readonly property var selectedUser: {
        const users = backend?.users ?? [];
        return users.find(user => user.name === backend.lastUser) ?? users[0] ?? null;
    }
    readonly property var selectedSession: {
        const sessions = backend?.sessions ?? [];
        return sessions.find(session => session.id === backend.defaultSession) ?? sessions[0] ?? null;
    }

    property string phase: "ready"
    property string pendingPassword: ""

    function submit(password) {
        if (phase !== "ready" || password.length === 0 || !selectedUser)
            return;
        pendingPassword = password;
        phase = "checking";
        backend.startAuthentication(selectedUser.name);
    }

    // The screen calls this when its fade-out ends.
    function launch() {
        if (phase === "starting")
            backend.launch(selectedSession);
    }

    property Connections backendConnections: Connections {
        target: logic.backend

        function onAuthPrompt(message, secret) {
            if (logic.phase !== "checking")
                return;
            logic.backend.answer(logic.pendingPassword);
            logic.pendingPassword = "";
        }

        function onReadyToLaunch() {
            if (logic.phase === "checking")
                logic.phase = "starting";
        }
    }
}
