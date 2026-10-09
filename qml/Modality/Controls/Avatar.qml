pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Templates as T
import Modality.Theme

// A user's picture in a circle. Not focusable unless focusPolicy says so.
T.AbstractButton {
    id: control

    property string name
    property url source
    property int size: Theme.avatarSizeLarge

    readonly property real radius: size / 2
    readonly property int status: image.status
    // Default to the live input state; set them to show a state without input.
    property bool hoverActive: hovered
    property bool ringShown: activeFocus
    // The elevation at rest and while focused; small Avatars in a panel sit lower.
    property var restingShadow: Theme.shadowFloating
    readonly property var shadow: {
        if (!enabled)
            return null;
        if (down)
            return Theme.shadowRaised;
        return hoverActive ? Theme.shadowModal : restingShadow;
    }
    readonly property real visualScale: !enabled ? 1 : down ? 0.96 : hoverActive ? 1.04 : 1
    readonly property real visualOpacity: enabled ? 1 : 0.4

    implicitWidth: size
    implicitHeight: size
    padding: 0
    hoverEnabled: true
    focusPolicy: Qt.NoFocus
    Accessible.role: Accessible.Button
    Accessible.name: name

    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()

    contentItem: Item {
        scale: control.visualScale
        opacity: control.visualOpacity

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
            radius: control.radius
        }

        Rectangle {
            anchors.fill: parent
            radius: control.radius
            color: Theme.fillStrong
        }

        Image {
            id: image

            anchors.fill: parent
            source: control.source
            sourceSize: Qt.size(control.size * 2, control.size * 2)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: mask
                maskThresholdMin: 0.5
                maskSpreadAtMin: 1
            }
        }

        Item {
            id: mask

            anchors.fill: parent
            layer.enabled: true
            visible: false

            Rectangle {
                anchors.fill: parent
                radius: control.radius
            }
        }

        FocusRing {
            anchors.fill: parent
            radius: control.radius
            shown: control.ringShown
        }
    }
}
