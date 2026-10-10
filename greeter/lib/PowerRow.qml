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
    // The overlay open on the screen, "" for none: under one the buttons take no focus and
    // do nothing.
    property string overlay: ""

    spacing: Theme.space8

    component PowerButton: FrostedIconButton {
        // The backend operation the button runs.
        required property var operation

        backdrop: row.backdrop
        focusPolicy: row.overlay === "" ? Qt.StrongFocus : Qt.NoFocus
        onClicked: {
            if (row.overlay === "")
                operation();
        }
    }

    PowerButton {
        objectName: "sleepButton"
        text: qsTr("Sleep")
        glyph: Glyphs.sleep
        operation: () => row.backend.suspend()
    }

    PowerButton {
        objectName: "restartButton"
        text: qsTr("Restart")
        glyph: Glyphs.restart
        operation: () => row.backend.reboot()
    }

    PowerButton {
        objectName: "shutDownButton"
        text: qsTr("Shut Down")
        glyph: Glyphs.shutDown
        operation: () => row.backend.powerOff()
    }
}
