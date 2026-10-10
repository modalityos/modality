import QtQuick
import Modality.Theme

// The two-tone focus ring: a halo in the surface colour, then the ring, outside the element.
// Fill the element with it; radius is the element's.
Item {
    id: ring

    property real radius: 0
    property bool shown: false

    readonly property color haloColor: Theme.materialPopoverFallback
    readonly property int haloWidth: Theme.focusRingOffset
    readonly property color ringColor: Theme.focusRing
    readonly property int ringWidth: Theme.focusRingWidth

    visible: shown

    Rectangle {
        anchors.fill: parent
        anchors.margins: -ring.haloWidth
        radius: ring.radius + ring.haloWidth
        color: "transparent"
        border.width: ring.haloWidth
        border.color: ring.haloColor
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -(ring.haloWidth + ring.ringWidth)
        radius: ring.radius + ring.haloWidth + ring.ringWidth
        color: "transparent"
        border.width: ring.ringWidth
        border.color: ring.ringColor
    }
}
