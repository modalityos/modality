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

    GreeterLogic {
        id: logic

        backend: greeter.backend
        passwordLength: userColumn.passwordField.text.length
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
            defaultAvatar: greeter.backend?.defaultAvatar ?? ""
            otherUsersShown: (greeter.backend?.users.length ?? 0) > 1
            backdrop: wallpaper
            passwordField.busy: logic.state === "checking" || logic.state === "starting"
        }

        Connections {
            target: logic

            function onPasswordRejected() {
                userColumn.passwordField.text = "";
            }

            // A Session that failed to start brings the faded screen back.
            function onStateChanged() {
                if (logic.state !== "starting")
                    content.opacity = 1;
            }
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
