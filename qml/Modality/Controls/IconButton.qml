import QtQuick
import QtQuick.Templates as T
import Modality.Theme

// A Glass circle with a glyph and a label under it (Options, Sleep, Restart, Shut Down).
// Checked keeps the opaque fill, for Options while its Menu is open.
T.AbstractButton {
    id: control

    property var glyph: null

    readonly property bool ringShown: activeFocus
    readonly property color fillColor: {
        if (!enabled)
            return Theme.materialPopover;
        if (pressed)
            return Theme.surfaceSunken;
        return hovered || checked ? Theme.surfaceOverlay : Theme.materialPopover;
    }
    readonly property color glyphColor: enabled ? Theme.textPrimary : Theme.textDisabled
    readonly property color labelColor: Theme.textPrimary
    readonly property var shadow: !enabled || pressed ? null : hovered ? Theme.shadowFloating : Theme.shadowRaised
    readonly property real circleScale: pressed ? 0.95 : 1
    readonly property real circleOpacity: enabled ? 1 : 0.5

    // Raw sizes from the design: 40px circle, 16px glyph, 6px to the label.
    readonly property int circleSize: 40
    readonly property int glyphSize: 16
    readonly property int labelGap: 6

    implicitWidth: Math.max(circleSize, label.implicitWidth)
    implicitHeight: circleSize + labelGap + label.implicitHeight
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.StrongFocus
    font: Theme.footnoteMedium.font
    Accessible.role: Accessible.Button
    Accessible.name: text

    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()

    contentItem: Item {
        Item {
            id: circle

            width: control.circleSize
            height: control.circleSize
            anchors.horizontalCenter: parent.horizontalCenter
            scale: control.circleScale
            opacity: control.circleOpacity

            Behavior on scale {
                NumberAnimation {
                    duration: Theme.motionDurationFast
                    easing.type: Easing.Bezier
                    easing.bezierCurve: Theme.motionEasingStandard
                }
            }

            Shadow {
                anchors.fill: parent
                token: control.shadow
                radius: width / 2
            }

            Glass {
                anchors.fill: parent
                radius: width / 2
                frosted: control.enabled ? !control.pressed && !control.hovered && !control.checked : true
                color: control.fillColor

                Behavior on color {
                    FastColorAnimation {}
                }
            }

            Icon {
                anchors.centerIn: parent
                glyph: control.glyph
                size: control.glyphSize
                color: control.glyphColor
            }

            FocusRing {
                anchors.fill: parent
                radius: width / 2
                shown: control.ringShown
            }
        }

        Text {
            id: label

            anchors.top: circle.bottom
            anchors.topMargin: control.labelGap
            anchors.horizontalCenter: parent.horizontalCenter
            text: control.text
            font: control.font
            color: control.labelColor
            lineHeight: Theme.footnoteMedium.lineHeight
            lineHeightMode: Text.FixedHeight
        }
    }
}
