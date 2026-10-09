import QtQuick
import QtQuick.Templates as T
import Modality.Theme
import Modality.Controls

// The Glass pill under the password field that opens the Choose a user panel.
T.AbstractButton {
    id: pill

    // The wallpaper the Glass blurs.
    property Item backdrop

    // Raw sizes from the design: 12px glyph, 6px to the label.
    readonly property int glyphSize: 12
    readonly property int glyphGap: 6
    readonly property real radius: height / 2

    text: qsTr("Other users")
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: Theme.controlHeightSmall
    leftPadding: Theme.space3
    rightPadding: Theme.space3
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    font: Theme.footnoteMedium.font
    Accessible.role: Accessible.Button
    Accessible.name: text

    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()

    contentItem: Row {
        spacing: pill.glyphGap

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            glyph: Glyphs.otherUsers
            size: pill.glyphSize
            color: Theme.textPrimary
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: pill.text
            font: pill.font
            lineHeight: Theme.footnoteMedium.lineHeight
            lineHeightMode: Text.FixedHeight
            color: Theme.textPrimary
        }
    }

    background: Item {
        Shadow {
            anchors.fill: parent
            token: Theme.shadowRaised
            radius: pill.radius
        }

        Frost {
            anchors.fill: parent
            source: pill.backdrop
            radius: pill.radius
        }

        Glass {
            anchors.fill: parent
            radius: pill.radius
        }

        FocusRing {
            anchors.fill: parent
            radius: pill.radius
            shown: pill.activeFocus
        }
    }
}
