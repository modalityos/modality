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

    GreeterLogic {
        id: logic

        backend: greeter.backend
        passwordLength: passwordField.text.length
    }

    Item {
        id: content

        anchors.fill: parent

        PasswordField {
            id: passwordField

            anchors.centerIn: parent
            focus: true
            busy: logic.state === "checking" || logic.state === "starting"
            onSubmitted: password => logic.submit(password)
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
