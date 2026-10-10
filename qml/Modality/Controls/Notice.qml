import QtQuick
import QtQuick.Layouts
import Modality.Theme

// A Glass pill with a short message in a status tone (Caps Lock, Wrong password).
// With actionText it floats and carries a primary Button (Session failed: Try again).
Item {
    id: notice

    enum Tone {
        Warning,
        Danger
    }

    property int tone: Notice.Warning
    property string text
    property var glyph: null
    property string actionText

    readonly property bool hasAction: actionText.length > 0
    readonly property color toneColor: tone === Notice.Danger ? Theme.danger : Theme.warning
    readonly property color fillColor: Theme.materialPopover
    readonly property var shadow: hasAction ? Theme.shadowFloating : null
    readonly property real radius: height / 2
    readonly property font font: Theme.footnoteMedium.font
    readonly property alias actionItem: actionButton

    signal actionTriggered

    implicitWidth: row.implicitWidth + row.anchors.leftMargin + row.anchors.rightMargin
    implicitHeight: row.implicitHeight + row.anchors.topMargin + row.anchors.bottomMargin
    Accessible.role: Accessible.AlertMessage
    Accessible.name: text

    Shadow {
        anchors.fill: parent
        token: notice.shadow
        radius: notice.radius
    }

    Glass {
        anchors.fill: parent
        radius: notice.radius
    }

    // Raw padding from the design: 4 12 plain; 6 6 6 14 around the 24px action button.
    RowLayout {
        id: row

        anchors.fill: parent
        anchors.topMargin: notice.hasAction ? 6 : 4
        anchors.bottomMargin: anchors.topMargin
        anchors.leftMargin: notice.hasAction ? 14 : Theme.space3
        anchors.rightMargin: notice.hasAction ? 6 : Theme.space3
        spacing: notice.hasAction ? Theme.space3 : 6

        Icon {
            visible: notice.glyph !== null
            glyph: notice.glyph
            size: 10
            color: notice.toneColor
        }

        Text {
            text: notice.text
            font: notice.font
            color: notice.toneColor
            lineHeight: Theme.footnoteMedium.lineHeight
            lineHeightMode: Text.FixedHeight
            verticalAlignment: Text.AlignVCenter
        }

        Button {
            id: actionButton

            visible: notice.hasAction
            text: notice.actionText
            onClicked: notice.actionTriggered()
        }
    }
}
