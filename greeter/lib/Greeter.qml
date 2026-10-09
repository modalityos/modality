import QtQuick
import Modality.Theme

// The Greeter screen: fills the one output Cage gives it. Plain QML over a Greeter backend,
// so it runs the same under Quickshell and under qmltestrunner.
FocusScope {
    id: greeter

    property GreeterBackend backend
    readonly property string loginState: logic.state
    // What covers the screen: "" or "otherUsers" (the Choose a user panel).
    readonly property string overlay: logic.overlay
    // Screens under 900px tall (1366 x 768) pull the Clock and the user column in.
    readonly property bool shortScreen: height < 900

    focus: true

    // Typing goes into the password field wherever focus is, except inside an overlay. Keys
    // reach here only when the focused Control left them, so Space and Enter still act on it.
    Keys.onPressed: event => {
        const field = userColumn.passwordField;
        const printable = event.text.length > 0 && event.text.charCodeAt(0) >= 0x20 && event.text.charCodeAt(0) !== 0x7f;
        const chord = event.modifiers & (Qt.ControlModifier | Qt.AltModifier | Qt.MetaModifier);
        if (!printable || chord || logic.overlay !== "" || !field.visible || !field.interactive)
            return;
        field.forceActiveFocus();
        field.text += event.text;
        logic.typed(event.text, event.modifiers);
        event.accepted = true;
    }

    GreeterLogic {
        id: logic

        backend: greeter.backend
        // A rejected password stays in the field while it shakes, but it no longer counts.
        passwordLength: userColumn.passwordField.shaking ? 0 : userColumn.passwordField.text.length
    }

    // The Greeter follows the machine's settings, never a user's.
    Binding {
        target: Theme
        property: "theme"
        value: greeter.backend?.theme ?? "dark"
    }

    Binding {
        target: Theme
        property: "reduceTransparency"
        value: greeter.backend?.reduceTransparency ?? false
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
        name: greeter.backend?.wallpaper ?? "silk"
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
            clock24Hour: greeter.backend?.clock24Hour ?? true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: greeter.shortScreen ? 56 : 112
        }

        UserColumn {
            id: userColumn

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: greeter.shortScreen ? 96 : 176
            width: 280
            user: logic.selectedUser
            defaultAvatar: greeter.backend?.defaultAvatar ?? ""
            otherUsersShown: (greeter.backend?.users.length ?? 0) > 1
            backdrop: wallpaper
            passwordField.busy: logic.state === "checking" || logic.state === "starting"
            wrongPasswordShown: logic.wrongPasswordShown
            capsLockShown: logic.capsLockShown
            sessionFailed: logic.state === "sessionFailed"
            unavailable: logic.state === "unavailable"
            onRetryRequested: logic.retry()
        }

        PowerRow {
            objectName: "powerRow"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: greeter.shortScreen ? 28 : Theme.space10
            backend: greeter.backend
            backdrop: wallpaper
        }

        Connections {
            target: logic

            function onPasswordRejected() {
                userColumn.passwordField.shake();
            }

            // A Session that failed to start brings the faded screen back, with focus on
            // Try again; Try again hands focus back to the field.
            function onStateChanged() {
                if (logic.state !== "starting")
                    content.opacity = 1;
                if (logic.state === "sessionFailed") {
                    userColumn.passwordField.text = "";
                    userColumn.tryAgainButton.forceActiveFocus();
                } else if (logic.state === "ready" && !userColumn.passwordField.activeFocus) {
                    userColumn.passwordField.forceActiveFocus();
                }
            }
        }

        Connections {
            target: userColumn.passwordField

            function onSubmitted(password) {
                logic.submit(password);
            }

            function onTyped(text, modifiers) {
                logic.typed(text, modifiers);
            }

            function onShakingChanged() {
                if (!userColumn.passwordField.shaking)
                    userColumn.passwordField.text = "";
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
            userColumn.passwordField.text = "";
            userColumn.passwordField.forceActiveFocus();
        }
        onCancelled: {
            logic.closeOverlay();
            userColumn.otherUsersPill.forceActiveFocus();
        }
    }

    Connections {
        target: userColumn.otherUsersPill

        function onClicked() {
            logic.openOtherUsers();
        }
    }
}
