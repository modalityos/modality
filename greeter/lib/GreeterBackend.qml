import QtQuick

// The Greeter backend: the seam between the Greeter logic and the system (greetd,
// AccountsService, Sessions, power, machine settings). The real backend and the tests'
// fake backend both extend this type and override its operations.
QtObject {
    // Users: [{ name, realName, avatar (url string, "" for none), systemAccount }].
    property var users: []
    // The built-in avatar for a user without a picture, or whose picture cannot be read.
    property url defaultAvatar
    property string lastUser: ""
    // Sessions: [{ id, name, command (argv list), desktopNames (list) }].
    property var sessions: []
    property string defaultSession: ""
    // A user's remembered Session id by user name: { "katherine": "org.modalityos.kwin" }.
    property var rememberedSessions: ({})

    // Machine settings: Defaults plus Admin overrides, never a user's own settings.
    property string theme: "dark"
    property bool clock24Hour: true
    property string wallpaper: "silk"
    // The folder holding the packaged wallpaper renders.
    property url wallpaperFolder
    property bool reduceTransparency: false

    // greetd asks for an answer; secret means hide what is typed (a password).
    signal authPrompt(string message, bool secret)
    signal authFailure(string message)
    signal readyToLaunch
    signal launched
    signal error(string message)
    signal loginUnavailable

    function startAuthentication(user) {
    }

    function answer(response) {
    }

    function cancel() {
    }

    // session is one entry of sessions.
    function launch(session) {
    }

    // Remember the last user, and the Session that user picked ("" when they picked none).
    function remember(user, sessionId) {
    }

    function suspend() {
    }

    function reboot() {
    }

    function powerOff() {
    }
}
