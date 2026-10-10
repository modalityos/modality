import QtQuick
import QtQuick.Effects
import Modality.Theme

// The blurred wallpaper behind one Glass element. Cage cannot blur (ADR 0001), so the
// Greeter blurs its own wallpaper: fill the element with this, beneath its Glass tint.
Item {
    id: frost

    // The wallpaper this element sits over.
    property Item source
    property real radius: 0

    readonly property int blurRadius: Theme.materialPopoverBlur
    // MultiEffect saturation runs -1..1 around 0, so this approximates CSS saturate(1.6).
    readonly property real saturation: Theme.materialSaturation - 1
    // The part of the wallpaper behind this element, in the wallpaper's coordinates.
    property rect region

    // Reduce transparency: the Glass above draws its solid fallback, so nothing shows through.
    visible: !Theme.reduceTransparency

    function updateRegion() {
        if (source)
            region = mapToItem(source, 0, 0, width, height);
    }

    // The region moves with every ancestor; this screen's ancestors are fixed, so connect once.
    Component.onCompleted: {
        for (let item = frost; item && item !== source; item = item.parent) {
            item.xChanged.connect(updateRegion);
            item.yChanged.connect(updateRegion);
            item.widthChanged.connect(updateRegion);
            item.heightChanged.connect(updateRegion);
        }
        updateRegion();
    }

    // Grab a margin of blurRadius around the element so the blur has wallpaper to pull in
    // at the edges, then mask back to the element's shape.
    ShaderEffectSource {
        id: grab

        anchors.fill: blur
        sourceItem: frost.source
        sourceRect: Qt.rect(frost.region.x - frost.blurRadius, frost.region.y - frost.blurRadius, frost.region.width + 2 * frost.blurRadius, frost.region.height + 2 * frost.blurRadius)
        visible: false
    }

    MultiEffect {
        id: blur

        anchors.fill: parent
        anchors.margins: -frost.blurRadius
        source: grab
        autoPaddingEnabled: false
        blurEnabled: true
        blurMax: frost.blurRadius
        blur: 1
        saturation: frost.saturation
        maskEnabled: true
        maskSource: mask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1
    }

    Item {
        id: mask

        anchors.fill: blur
        layer.enabled: true
        visible: false

        Rectangle {
            anchors.fill: parent
            anchors.margins: frost.blurRadius
            radius: frost.radius
        }
    }
}
