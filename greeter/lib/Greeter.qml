import QtQuick
import Modality.Theme

// The Greeter screen: fills the one output Cage gives it. Plain QML over a Greeter backend,
// so it runs the same under Quickshell and under qmltestrunner.
FocusScope {
    id: greeter

    property GreeterBackend backend
    readonly property string loginState: logic.state
    // Screens under 900px tall (1366 x 768) pull the Clock and the user column in.
    readonly property bool shortScreen: height < 900

    focus: true

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
}
