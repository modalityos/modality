import QtQuick
import QtQuick.Effects

// One elevation Token drawn behind an element: a hairline plus one soft shadow.
// Fill the element with it; token null draws nothing.
Item {
    id: shadow

    property var token: null
    property real radius: 0

    visible: token !== null

    RectangularShadow {
        anchors.fill: parent
        radius: shadow.radius
        offset: Qt.vector2d(shadow.token?.offsetX ?? 0, shadow.token?.offsetY ?? 0)
        blur: shadow.token?.blur ?? 0
        color: shadow.token?.color ?? "transparent"
    }

    // A 0.5px hairline drawn as 1px at half the alpha.
    Rectangle {
        readonly property color hairline: shadow.token?.hairlineColor ?? "transparent"

        anchors.fill: parent
        anchors.margins: -1
        radius: shadow.radius + 1
        color: "transparent"
        border.width: 1
        border.color: Qt.rgba(hairline.r, hairline.g, hairline.b, hairline.a / 2)
    }
}
