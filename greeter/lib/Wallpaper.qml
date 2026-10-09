import QtQuick
import Modality.Theme

// The machine-wide wallpaper in the active theme, from its packaged renders.
// A 16:10 screen gets the 3840 x 2400 render; any other shape covers with 3840 x 2160.
Image {
    id: wallpaper

    property url folder
    property string name: "silk"

    readonly property bool sixteenByTen: height > 0 && Math.abs(width / height - 1.6) < 0.01
    readonly property string size: sixteenByTen ? "3840x2400" : "3840x2160"

    source: folder.toString().length > 0
            ? `${folder}/wallpaper-${name}-${Theme.dark ? "dark" : "light"}-${size}.png`
            : ""
    sourceSize: Qt.size(width, height)
    fillMode: Image.PreserveAspectCrop
    asynchronous: true
    Accessible.ignored: true
}
