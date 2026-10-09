import QtQuick
import QtQuick.Layouts
import Modality.Theme

// The date over a large time, on the wallpaper with no backing.
ColumnLayout {
    id: clock

    property date now: new Date()

    spacing: Theme.space1

    // Wakes on each minute boundary, so the time turns over with the system clock.
    Timer {
        running: true
        interval: 60000 - (clock.now.getSeconds() * 1000 + clock.now.getMilliseconds())
        onTriggered: clock.now = new Date()
    }

    Text {
        objectName: "clockDate"
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDate(clock.now, "dddd d MMMM")
        font: Theme.title1.font
        lineHeight: Theme.title1.lineHeight
        lineHeightMode: Text.FixedHeight
        color: Theme.textPrimary
    }

    Text {
        objectName: "clockTime"
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatTime(clock.now, "HH:mm")
        font.family: Theme.display.font.family
        font.pixelSize: Theme.display.font.pixelSize
        font.weight: Theme.display.font.weight
        font.letterSpacing: Theme.display.font.letterSpacing
        // Tabular figures, so the digits don't shift as the minutes change.
        font.features: { "tnum": 1 }
        lineHeight: Theme.display.lineHeight
        lineHeightMode: Text.FixedHeight
        color: Theme.textPrimary
    }
}
