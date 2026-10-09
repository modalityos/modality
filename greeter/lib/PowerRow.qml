pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Modality.Theme
import Modality.Controls

// Sleep, Restart and Shut Down. Each acts at once, with no confirmation.
RowLayout {
    id: row

    property GreeterBackend backend
    // The wallpaper the buttons' Glass circles frost.
    property Item backdrop

    spacing: Theme.space8

    component PowerButton: IconButton {
        id: button

        // Beneath the circle's own Glass tint.
        Frost {
            z: -1
            width: button.circleSize
            height: button.circleSize
            anchors.horizontalCenter: parent.horizontalCenter
            source: row.backdrop
            radius: width / 2
        }
    }

    PowerButton {
        objectName: "sleepButton"
        text: qsTr("Sleep")
        glyph: Glyphs.sleep
        onClicked: row.backend.suspend()
    }

    PowerButton {
        objectName: "restartButton"
        text: qsTr("Restart")
        glyph: Glyphs.restart
        onClicked: row.backend.reboot()
    }

    PowerButton {
        objectName: "shutDownButton"
        text: qsTr("Shut Down")
        glyph: Glyphs.shutDown
        onClicked: row.backend.powerOff()
    }
}
