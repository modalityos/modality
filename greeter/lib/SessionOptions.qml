pragma ComponentBehavior: Bound
import QtQuick
import Modality.Theme
import Modality.Controls

// Options at the bottom-right and the Session Menu above it, shown only when there is a
// choice of Session.
Item {
    id: options

    property var sessions: []
    // The id of the Session a login would start: checked in the Menu.
    property string currentSession
    property bool open: false
    // The wallpaper the Glass blurs.
    property Item backdrop
    property bool shortScreen: false
    readonly property alias button: button

    signal toggled

    onOpenChanged: {
        if (open)
            menu.open();
        else
            menu.close();
    }

    IconButton {
        id: button

        objectName: "optionsButton"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: Theme.space10
        anchors.bottomMargin: options.shortScreen ? 28 : Theme.space10
        visible: options.sessions.length > 1
        checked: options.open
        text: qsTr("Options")
        glyph: Glyphs.options
        onClicked: options.toggled()

        // Beneath the circle's own Glass tint.
        Frost {
            z: -1
            width: button.circleSize
            height: button.circleSize
            anchors.horizontalCenter: parent.horizontalCenter
            source: options.backdrop
            radius: width / 2
        }
    }

    Menu {
        id: menu

        objectName: "sessionMenu"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: Theme.space10
        // Above the Options button and its label: the power row's bottom plus 72px.
        anchors.bottomMargin: (options.shortScreen ? 28 : Theme.space10) + 72
        title: qsTr("Session")
        model: options.sessions.map(session => ({
                    text: session.name,
                    checked: session.id === options.currentSession
                }))

        Frost {
            z: -1
            anchors.fill: parent
            source: options.backdrop
            radius: menu.radius
        }
    }
}
