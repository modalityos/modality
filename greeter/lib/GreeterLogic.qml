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

    readonly property var selectedUser: {
        const users = backend?.users ?? [];
        return users.find(user => user.name === backend.lastUser) ?? users[0] ?? null;
    }
    readonly property var selectedSession: {
        const sessions = backend?.sessions ?? [];
        return sessions.find(session => session.id === backend.defaultSession) ?? sessions[0] ?? null;
    }

    // Caps Lock, inferred from typed letters: Qt reports no lock state, but an upper-case
    // letter without Shift (or lower-case with it) means it is on.
    property bool capsLock: false
    readonly property bool capsLockShown: capsLock && (state === "ready" || state === "typing" || state === "wrongPassword")

    // The Wrong password Notice: shown for three seconds, or until typing starts again.
    property bool wrongPasswordShown: false

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

    // Try again after a Session failed to start: back to ready for a fresh login with the
    // same user and Session, after greetd drops what is left of the failed one.
    function retry() {
        if (phase !== "sessionFailed")
            return;
        backend.cancel();
        phase = "ready";
    }

    // The screen calls this when its fade-out ends.
    function launch() {
        if (phase === "starting")
            backend.launch(selectedSession);
    }

    // The screen calls this for each character typed into the password field.
    function typed(text, modifiers) {
        wrongPasswordShown = false;
        const upper = text.toUpperCase();
        const lower = text.toLowerCase();
        if (upper !== lower)
            capsLock = (text === upper) !== Boolean(modifiers & Qt.ShiftModifier);
    }

    property Timer wrongPasswordTimer: Timer {
        interval: 3000
        onTriggered: logic.wrongPasswordShown = false
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
            logic.wrongPasswordShown = true;
            logic.wrongPasswordTimer.restart();
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
