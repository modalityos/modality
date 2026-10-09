import QtQuick
import Modality.Theme
import Modality.Controls

// The Greeter screen: fills the one output Cage gives it. Plain QML over a Greeter backend,
// so it runs the same under Quickshell and under qmltestrunner.
FocusScope {
    id: greeter

    property GreeterBackend backend
    readonly property string state: logic.state

    focus: true

    // Screens under 900px tall (1366 x 768) pull the Clock and the user column in.
    readonly property bool shortScreen: height < 900

    GreeterLogic {
        id: logic

        backend: greeter.backend
        passwordLength: userColumn.passwordField.text.length
    }

    Item {
        id: content

        anchors.fill: parent

        UserColumn {
            id: userColumn

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: greeter.shortScreen ? 96 : 176
            width: 280
            user: logic.selectedUser
            passwordField.busy: logic.state === "checking" || logic.state === "starting"
        }

        Connections {
            target: userColumn.passwordField

            function onSubmitted(password) {
                logic.submit(password);
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
