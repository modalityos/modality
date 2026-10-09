import QtQuick
import QtQuick.Templates as T
import Modality.Theme

// One row of a Menu. Checked shows the check glyph; unchecked labels indent to line up.
T.AbstractButton {
    id: control

    readonly property real radius: Theme.radiusSmall
    // Default to the live input state; set them to show a state without input.
    property bool hoverActive: hovered
    property bool ringShown: activeFocus
    readonly property color fillColor: !enabled ? "transparent" : down ? Theme.accentPressed : hoverActive ? Theme.accent : "transparent"
    readonly property color labelColor: !enabled ? Theme.textDisabled : down || hoverActive ? Theme.onAccent : Theme.textPrimary
    // Raw sizes from the design: 12px check glyph, 10px side padding.
    readonly property int indicatorWidth: 12

    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: Theme.rowHeight
    leftPadding: checked ? 10 : 10 + indicatorWidth + spacing
    rightPadding: 10
    topPadding: 0
    bottomPadding: 0
    spacing: Theme.space2
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    font: Theme.body.font
    Accessible.role: Accessible.MenuItem
    Accessible.name: text
    Accessible.checked: checked

    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()

    contentItem: Row {
        spacing: control.spacing

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            visible: control.checked
            glyph: Glyphs.check
            size: control.indicatorWidth
            color: control.labelColor
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: control.text
            font: control.font
            color: control.labelColor
            elide: Text.ElideRight
        }
    }

    background: Item {
        Rectangle {
            anchors.fill: parent
            radius: control.radius
            color: control.fillColor

            Behavior on color {
                FastColorAnimation {}
            }
        }

        FocusRing {
            anchors.fill: parent
            radius: control.radius
            shown: control.ringShown
        }
    }
}
