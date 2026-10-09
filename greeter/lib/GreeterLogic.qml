import QtQuick

// What the Greeter is doing, driven by the Greeter backend's events and the screen's input.
// A login: submit asks greetd for a session, the password answers its prompt, and once
// greetd is ready the screen fades out (starting) and then calls launch().
QtObject {
    id: logic

    property GreeterBackend backend

    // ready, typing, checking, wrongPassword, starting, sessionFailed or unavailable.
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

    // What covers the screen: "" for nothing, "otherUsers" for the Choose a user panel,
    // "options" for the Session Menu.
    property string overlay: ""
    // The Session picked in the Session Menu, else the selected user's remembered one, else
    // the machine default, else the first. A pick is remembered only when its user logs in.
    readonly property var selectedSession: {
        const sessions = backend?.sessions ?? [];
        const remembered = backend?.rememberedSessions[selectedUser?.name ?? ""];
        return sessions.find(session => session.id === chosenSession)
            ?? sessions.find(session => session.id === remembered)
            ?? sessions.find(session => session.id === backend.defaultSession) ?? sessions[0] ?? null;
    }
    property string chosenSession: ""

    // Caps Lock, inferred from typed letters: Qt reports no lock state, but an upper-case
    // letter without Shift (or lower-case with it) means it is on.
    property bool capsLock: false
    readonly property bool capsLockShown: capsLock && (state === "ready" || state === "typing" || state === "wrongPassword")

    // The Wrong password Notice: shown for three seconds, or until typing starts again.
    property bool wrongPasswordShown: false

    property string phase: "ready"
    // Whether the screen takes a login or opens an overlay: not while a login is under way,
    // nor once login is unavailable.
    readonly property bool acceptsInput: phase !== "checking" && phase !== "starting" && phase !== "unavailable"
    property string pendingPassword: ""

    // greetd turned the password down: the screen clears the field.
    signal passwordRejected

    function submit(password) {
        if (!acceptsInput || password.length === 0 || !selectedUser)
            return;
        pendingPassword = password;
        phase = "checking";
        backend.startAuthentication(selectedUser.name);
    }

    function openOtherUsers() {
        if (acceptsInput && (backend?.users.length ?? 0) > 1)
            overlay = "otherUsers";
    }

    // Options toggles the Session Menu; there is nothing to choose with one Session.
    function toggleOptions() {
        if (overlay === "options")
            overlay = "";
        else if (acceptsInput && (backend?.sessions.length ?? 0) > 1)
            overlay = "options";
    }

    function chooseSession(id) {
        if (overlay !== "options")
            return;
        chosenSession = id;
        overlay = "";
    }

    function closeOverlay() {
        overlay = "";
    }

    // A newly picked user starts over with an empty field and their own Session, after
    // greetd drops what is left of a failed Session.
    function chooseUser(name) {
        if (overlay !== "otherUsers")
            return;
        if (phase === "sessionFailed")
            backend.cancel();
        chosenUser = name;
        chosenSession = "";
        overlay = "";
        wrongPasswordShown = false;
        if (phase !== "unavailable")
            phase = "ready";
    }

    // Try again after a Session failed to start: back to ready for a fresh login with the
    // same user and Session, after greetd drops what is left of the failed one.
    function retry() {
        if (phase !== "sessionFailed")
            return;
        backend.cancel();
        phase = "ready";
    }

    // The screen calls this when its fade-out ends. The login is remembered first, since
    // the Greeter quits once the Session launches; only a picked Session is saved, so users
    // who never pick follow the machine default.
    function launch() {
        if (phase !== "starting")
            return;
        backend.remember(selectedUser.name, chosenSession);
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

        // greetd cannot be reached: no login is possible until the machine restarts.
        function onLoginUnavailable() {
            logic.pendingPassword = "";
            logic.wrongPasswordShown = false;
            logic.phase = "unavailable";
        }

        function onError(message) {
            if (logic.phase === "checking" || logic.phase === "starting") {
                logic.pendingPassword = "";
                logic.phase = "sessionFailed";
            }
        }
    }
}
