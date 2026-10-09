import QtQuick
import QtQuick.Layouts
import Modality.Theme
import Modality.Controls

// The Control states sheet (design/greeter-login/), for checking the Controls by eye.
// Run: /usr/lib/qt6/bin/qml -I qml qml/preview/Controls.qml
// T switches light and dark; R switches Reduce transparency.
Window {
    id: window

    readonly property var states: ["default", "hover", "pressed", "focused", "disabled"]

    width: 1600
    height: 900
    visible: true
    title: qsTr("Modality Controls (%1)").arg(Theme.theme)
    color: Theme.bg

    // Stands in for the Silk wallpaper: the Foundations gradient through wallpaper1..3.
    Rectangle {
        anchors.centerIn: parent
        width: Math.hypot(parent.width, parent.height)
        height: width
        rotation: Theme.wallpaperAngle - 90
        gradient: Gradient {
            GradientStop { position: 0; color: Theme.wallpaper1 }
            GradientStop { position: Theme.wallpaperMidStop; color: Theme.wallpaper2 }
            GradientStop { position: 1; color: Theme.wallpaper3 }
        }
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_T)
                Theme.theme = Theme.dark ? "light" : "dark";
            else if (event.key === Qt.Key_R)
                Theme.reduceTransparency = !Theme.reduceTransparency;
        }
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: Theme.space8
        anchors.leftMargin: Theme.space16
        columns: 6
        columnSpacing: Theme.space4
        rowSpacing: Theme.space6

        Row {
            Layout.columnSpan: 6
            spacing: Theme.space3

            Button {
                variant: Button.Secondary
                text: Theme.dark ? qsTr("Light theme (T)") : qsTr("Dark theme (T)")
                focusPolicy: Qt.NoFocus
                onClicked: Theme.theme = Theme.dark ? "light" : "dark"
            }

            Button {
                variant: Button.Secondary
                text: Theme.reduceTransparency ? qsTr("Glass (R)") : qsTr("Reduce transparency (R)")
                focusPolicy: Qt.NoFocus
                onClicked: Theme.reduceTransparency = !Theme.reduceTransparency
            }
        }

        SheetLabel { text: "" }
        Repeater {
            model: window.states

            SheetLabel {
                required property string modelData

                text: modelData.charAt(0).toUpperCase() + modelData.slice(1)
                font: Theme.footnoteStrong.font
            }
        }

        SheetLabel { text: "Avatar" }
        Repeater {
            model: window.states

            Avatar {
                required property string modelData

                size: 64
                name: "John Doe"
                source: Qt.resolvedUrl("../../data/avatars/avatar-cat.png")
                hoverActive: modelData === "hover"
                down: modelData === "pressed"
                ringShown: modelData === "focused"
                enabled: modelData !== "disabled"
            }
        }

        SheetLabel { text: "PasswordField" }
        Repeater {
            model: window.states

            PasswordField {
                required property string modelData

                hoverActive: modelData === "hover"
                down: modelData === "pressed"
                ringShown: modelData === "focused"
                enabled: modelData !== "disabled"
            }
        }

        SheetLabel { text: "Button primary" }
        Repeater {
            model: window.states

            Button {
                required property string modelData

                text: "Try again"
                hoverActive: modelData === "hover"
                down: modelData === "pressed"
                ringShown: modelData === "focused"
                enabled: modelData !== "disabled"
            }
        }

        SheetLabel { text: "Button secondary" }
        Repeater {
            model: window.states

            Button {
                required property string modelData

                variant: Button.Secondary
                text: "Cancel"
                hoverActive: modelData === "hover"
                down: modelData === "pressed"
                ringShown: modelData === "focused"
                enabled: modelData !== "disabled"
            }
        }

        SheetLabel { text: "IconButton" }
        Repeater {
            model: window.states

            IconButton {
                required property string modelData

                text: "Restart"
                glyph: Glyphs.restart
                hoverActive: modelData === "hover"
                down: modelData === "pressed"
                ringShown: modelData === "focused"
                enabled: modelData !== "disabled"
            }
        }

        SheetLabel { text: "Menu item" }
        Repeater {
            model: window.states

            MenuItem {
                required property string modelData

                Layout.preferredWidth: 180
                text: "Hyprland"
                hoverActive: modelData === "hover"
                down: modelData === "pressed"
                ringShown: modelData === "focused"
                enabled: modelData !== "disabled"
            }
        }

        SheetLabel {
            Layout.alignment: Qt.AlignTop
            text: "Notice · Menu · Checking"
        }

        Column {
            Layout.alignment: Qt.AlignTop
            spacing: Theme.space3

            Notice {
                tone: Notice.Warning
                glyph: Glyphs.capsLock
                text: "Caps Lock is on"
            }

            Notice {
                tone: Notice.Danger
                glyph: Glyphs.cross
                text: "Wrong password"
            }
        }

        Notice {
            Layout.alignment: Qt.AlignTop
            tone: Notice.Danger
            text: "Couldn't start the session."
            actionText: "Try again"
        }

        Menu {
            id: sessionMenu

            Layout.alignment: Qt.AlignTop
            title: "Session"
            model: [{ text: "KWin", checked: true }, { text: "Hyprland" }]
            Component.onCompleted: {
                open();
                itemAt(0).ringShown = false;
                itemAt(1).hoverActive = true;
            }
        }

        PasswordField {
            Layout.alignment: Qt.AlignTop
            text: "secret"
            busy: true
        }

        Item {
            Layout.fillWidth: true
        }
    }

    component SheetLabel: Text {
        Layout.preferredWidth: 200
        font: Theme.bodyStrong.font
        color: Theme.textPrimary
    }
}
