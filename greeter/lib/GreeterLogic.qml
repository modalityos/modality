import QtQuick

// What the Greeter is doing, driven by the Greeter backend's events and the screen's input.
// A login: submit asks greetd for a session, the password answers its prompt, and once
// greetd is ready the screen fades out (starting) and then calls launch().
QtObject {
    id: logic

    property GreeterBackend backend

    // ready, typing, checking, wrongPassword, starting or sessionFailed.
    readonly property string state: {
        if ((phase === "ready" || phase === "wrongPassword") && passwordLength > 0)
            return "typing";
        return phase;
    }

    // Set by the screen as the password field changes.
    property int passwordLength: 0

    // The user picked in the Choose a user panel, else the last user to log in, else the first.
    readonly property var selectedUser: {
        const users = backend?.users ?? [];
        return users.find(user => user.name === chosenUser)
            ?? users.find(user => user.name === backend.lastUser) ?? users[0] ?? null;
    }
    property string chosenUser: ""

    // What covers the screen: "" for nothing, "otherUsers" for the Choose a user panel.
    property string overlay: ""
    readonly property var selectedSession: {
        const sessions = backend?.sessions ?? [];
        return sessions.find(session => session.id === backend.defaultSession) ?? sessions[0] ?? null;
    }

    property string phase: "ready"
    property string pendingPassword: ""

    // greetd turned the password down: the screen clears the field.
    signal passwordRejected

    function submit(password) {
        if (phase === "checking" || phase === "starting" || password.length === 0 || !selectedUser)
            return;
        pendingPassword = password;
        phase = "checking";
        backend.startAuthentication(selectedUser.name);
    }

    function openOtherUsers() {
        if (phase !== "checking" && phase !== "starting" && (backend?.users.length ?? 0) > 1)
            overlay = "otherUsers";
    }

    function closeOverlay() {
        overlay = "";
    }

    // A newly picked user starts over with an empty field.
    function chooseUser(name) {
        if (overlay !== "otherUsers")
            return;
        chosenUser = name;
        overlay = "";
        phase = "ready";
    }

    // The screen calls this when its fade-out ends. The login is remembered first, since
    // the Greeter quits once the Session launches.
    function launch() {
        if (phase !== "starting")
            return;
        backend.remember(selectedUser.name, selectedSession.id);
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

        function onAuthFailure(message) {
            if (logic.phase !== "checking")
                return;
            logic.pendingPassword = "";
            logic.phase = "wrongPassword";
            logic.passwordRejected();
        }

        function onReadyToLaunch() {
            if (logic.phase === "checking")
                logic.phase = "starting";
        }

        function onError(message) {
            if (logic.phase === "checking" || logic.phase === "starting") {
                logic.pendingPassword = "";
                logic.phase = "sessionFailed";
            }
        }
    }
}
