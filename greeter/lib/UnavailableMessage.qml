import QtQuick
import QtQuick.Layouts
import Modality.Theme
import Modality.Controls

// Login unavailable: greetd cannot be reached, so this Glass card takes the password
// field's place and says what to do instead.
Item {
    id: message

    // The wallpaper the Glass blurs.
    property Item backdrop
    readonly property string text: qsTr("Login is unavailable. Restart the computer or switch to a text console.")

    implicitWidth: Math.min(320, row.implicitWidth + row.anchors.leftMargin + row.anchors.rightMargin)
    implicitHeight: row.implicitHeight + row.anchors.topMargin + row.anchors.bottomMargin
    Accessible.role: Accessible.AlertMessage
    Accessible.name: text

    Frost {
        anchors.fill: parent
        source: message.backdrop
        radius: Theme.radiusCard
    }

    Shadow {
        anchors.fill: parent
        token: Theme.shadowFloating
        radius: Theme.radiusCard
    }

    Glass {
        anchors.fill: parent
        radius: Theme.radiusCard
    }

    // Raw padding from the design: 12 16, 10px between the icon and the text.
    RowLayout {
        id: row

        anchors.fill: parent
        anchors.topMargin: 12
        anchors.bottomMargin: 12
        anchors.leftMargin: Theme.space4
        anchors.rightMargin: Theme.space4
        spacing: 10

        Icon {
            Layout.alignment: Qt.AlignTop
            glyph: Glyphs.alert
            size: 16
            color: Theme.danger
        }

        Text {
            Layout.fillWidth: true
            text: message.text
            wrapMode: Text.Wrap
            font: Theme.footnote.font
            lineHeight: Theme.footnote.lineHeight
            lineHeightMode: Text.FixedHeight
            color: Theme.textPrimary
        }
    }
}
