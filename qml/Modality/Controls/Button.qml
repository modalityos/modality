import QtQuick
import QtQuick.Templates as T
import Modality.Theme

// Primary is the accent pill (Try again); Secondary is the quiet fill button (Cancel).
T.Button {
    id: control

    enum Variant {
        Primary,
        Secondary
    }

    property int variant: Button.Primary

    readonly property bool primary: variant === Button.Primary
    readonly property bool ringShown: activeFocus
    readonly property real radius: primary ? Theme.radiusPill : Theme.radiusControl
    readonly property color fillColor: {
        if (!enabled)
            return Theme.fill;
        if (!primary)
            return pressed || hovered ? Theme.fillStrong : Theme.fill;
        return pressed ? Theme.accentPressed : hovered ? Theme.accentHover : Theme.accent;
    }
    readonly property color labelColor: !enabled ? Theme.textDisabled : primary ? Theme.onAccent : Theme.textPrimary
    readonly property var shadow: primary && enabled && !pressed ? Theme.shadowRaised : null

    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: primary ? Theme.controlHeightSmall : Theme.controlHeight
    leftPadding: primary ? Theme.space3 : Theme.space4
    rightPadding: leftPadding
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    font: Theme.bodyMedium.font

    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()

    contentItem: Text {
        text: control.text
        font: control.font
        color: control.labelColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Item {
        Shadow {
            anchors.fill: parent
            token: control.shadow
            radius: control.radius
        }

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
