pragma ComponentBehavior: Bound
import QtQuick
import Modality.Theme
import Modality.Controls

// Options at the bottom-right, shown only when there is a choice of Session.
Item {
    id: options

    property var sessions: []
    // The wallpaper the Glass blurs.
    property Item backdrop
    property bool shortScreen: false

    IconButton {
        id: button

        objectName: "optionsButton"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: Theme.space10
        anchors.bottomMargin: options.shortScreen ? 28 : Theme.space10
        visible: options.sessions.length > 1
        text: qsTr("Options")
        glyph: Glyphs.options

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
}
