import QtQuick
import Modality.Controls

// An IconButton whose Glass circle frosts the wallpaper beneath it.
IconButton {
    id: button

    // The wallpaper the circle frosts.
    property Item backdrop

    // Beneath the circle's own Glass tint.
    Frost {
        z: -1
        width: button.circleSize
        height: button.circleSize
        anchors.horizontalCenter: parent.horizontalCenter
        source: button.backdrop
        radius: width / 2
    }
}
