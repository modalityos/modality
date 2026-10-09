import QtQuick
import Modality.Theme

// The frosted popover material. Frosted means tint over blur; the Greeter supplies the
// blur behind it (ADR 0001). Controls set frosted false while an opaque fill shows.
Rectangle {
    property bool frosted: true

    color: Theme.materialPopover
}
