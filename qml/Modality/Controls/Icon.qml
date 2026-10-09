import QtQuick
import QtQuick.Shapes

// Draws one Glyphs entry, stroked in color, scaled from its box to size.
Item {
    id: icon

    property var glyph: null
    property color color: "black"
    property real size: glyph?.box ?? 16

    implicitWidth: size
    implicitHeight: size
    Accessible.ignored: true

    Shape {
        width: icon.glyph?.box ?? 0
        height: width
        scale: width > 0 ? icon.size / width : 1
        transformOrigin: Item.TopLeft
        preferredRendererType: Shape.CurveRenderer
        visible: icon.glyph !== null

        ShapePath {
            strokeColor: icon.color
            strokeWidth: icon.glyph?.stroke ?? 1
            fillColor: "transparent"
            capStyle: icon.glyph?.roundCap ? ShapePath.RoundCap : ShapePath.FlatCap
            joinStyle: ShapePath.MiterJoin

            PathSvg {
                path: icon.glyph?.path ?? ""
            }
        }
    }
}
