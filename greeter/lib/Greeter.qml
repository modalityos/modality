import QtQuick
import Modality.Theme
import "machineSettings.js" as MachineSettings

// The Greeter screen: fills the one output Cage gives it. Plain QML over a Greeter backend,
// so it runs the same under Quickshell and under qmltestrunner.
FocusScope {
    id: greeter

    property GreeterBackend backend
    readonly property string loginState: logic.state
    readonly property string overlay: logic.overlay
    // Screens under 900px tall (1366 x 768) pull the Clock and the user column in.
    readonly property bool shortScreen: height < 900
    // Screen layout from the design spec (greeter-login, Build notes): the Clock's top, the
    // user column's bottom and width, and the power row's bottom.
    readonly property int clockTop: shortScreen ? 56 : 112
    readonly property int userColumnBottom: shortScreen ? 96 : 176
    readonly property int userColumnWidth: 280
    readonly property int powerRowBottom: shortScreen ? 28 : Theme.space10

    focus: true

    // Typing goes into the password field wherever focus is, except inside an overlay. Keys
    // reach here only when the focused Control left them, so Space and Enter still act on it.
    Keys.onPressed: event => {
        const printable = event.text.length > 0 && event.text.charCodeAt(0) >= 0x20 && event.text.charCodeAt(0) !== 0x7f;
        const chord = event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier);
        if (!printable || chord || logic.overlay !== "" || !userColumn.acceptsTyping)
            return;
        userColumn.typeIntoField(event.text);
        logic.typed(event.text, event.modifiers);
        event.accepted = true;
    }

    GreeterLogic {
        id: logic

        backend: greeter.backend
        passwordLength: userColumn.passwordLength
    }

    // The Greeter follows the machine's settings, never a user's.
    Binding {
        target: Theme
        property: "theme"
        value: greeter.backend?.theme ?? MachineSettings.builtIn.theme
    }

    Binding {
        target: Theme
        property: "reduceTransparency"
        value: greeter.backend?.reduceTransparency ?? MachineSettings.builtIn.reduceTransparency
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
    }

    Wallpaper {
        id: wallpaper

        objectName: "wallpaper"
        anchors.fill: parent
        folder: greeter.backend?.wallpaperFolder ?? ""
        name: greeter.backend?.wallpaper ?? MachineSettings.builtIn.wallpaper
        dark: Theme.dark
    }

    Item {
        id: content

        objectName: "content"
        anchors.fill: parent
        // Fade as one layer, so overlapping Glass elements do not show through each other.
        layer.enabled: logic.state === "starting"

        Clock {
            objectName: "clock"
            clock24Hour: greeter.backend?.clock24Hour ?? MachineSettings.builtIn.clock24Hour
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: greeter.clockTop
        }

        UserColumn {
            id: userColumn

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: greeter.userColumnBottom
            width: greeter.userColumnWidth
            user: logic.selectedUser
            defaultAvatar: greeter.backend?.defaultAvatar ?? ""
            otherUsersShown: (greeter.backend?.users.length ?? 0) > 1
            backdrop: wallpaper
            busy: logic.state === "checking" || logic.state === "starting"
            wrongPasswordShown: logic.wrongPasswordShown
            authError: logic.authError
            capsLockShown: logic.capsLockShown
            sessionFailed: logic.state === "sessionFailed"
            unavailable: logic.state === "unavailable"
            overlay: logic.overlay
            onRetryRequested: logic.retry()
            onSubmitted: password => logic.submit(password)
            onTyped: (text, modifiers) => logic.typed(text, modifiers)
            onOtherUsersRequested: logic.openOtherUsers()
        }

        // Before the PowerRow in the tree, so Options comes before the power buttons in Tab
        // order, but drawn over it, so a click outside the open Menu reaches nothing else.
        SessionOptions {
            id: sessionOptions

            anchors.fill: parent
            z: 1
            sessions: greeter.backend?.sessions ?? []
            currentSession: logic.selectedSession?.id ?? ""
            open: logic.overlay === "options"
            overlay: logic.overlay
            backdrop: wallpaper
            shortScreen: greeter.shortScreen
            onToggled: logic.toggleOptions()
            // A picked Session is followed by the password.
            onPicked: id => {
                logic.chooseSession(id);
                userColumn.focusField();
            }
            onDismissed: {
                logic.closeOverlay();
                sessionOptions.button.forceActiveFocus();
            }
        }

        PowerRow {
            objectName: "powerRow"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: greeter.powerRowBottom
            backend: greeter.backend
            backdrop: wallpaper
            overlay: logic.overlay
        }

        Connections {
            target: logic

            function onPasswordRejected() {
                userColumn.rejectPassword();
            }

            function onAttemptEnded() {
                userColumn.clearField();
            }

            // A Session that failed to start brings the faded screen back, with focus on
            // Try again; Try again hands focus back to the field.
            function onStateChanged() {
                if (logic.state !== "starting")
                    content.opacity = 1;
                if (logic.state === "sessionFailed") {
                    userColumn.clearField();
                    userColumn.focusTryAgain();
                } else if (logic.state === "ready") {
                    userColumn.focusField();
                }
            }
        }
    }

    // Starting: everything above the wallpaper fades out, then the Session launches.
    OpacityAnimator {
        target: content
        from: 1
        to: 0
        duration: Theme.motionDurationSlow
        easing.type: Easing.Bezier
        easing.bezierCurve: Theme.motionEasingIn
        running: logic.state === "starting"
        onFinished: logic.launch()
    }

    // Over the Content, which stays at full opacity under the scrim.
    UserPanel {
        id: userPanel

        objectName: "userPanel"
        anchors.fill: parent
        open: logic.overlay === "otherUsers"
        users: greeter.backend?.users ?? []
        currentUser: logic.selectedUser?.name ?? ""
        defaultAvatar: greeter.backend?.defaultAvatar ?? ""
        backdrop: wallpaper

        // A picked user starts with an empty, focused field.
        onPicked: name => {
            logic.chooseUser(name);
            userColumn.clearField();
            userColumn.focusField();
        }
        onCancelled: {
            logic.closeOverlay();
            userColumn.focusOtherUsers();
        }
    }
}
