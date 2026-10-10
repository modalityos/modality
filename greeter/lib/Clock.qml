import QtQuick
import QtQuick.Layouts
import Modality.Theme

// The date over a large time, on the wallpaper with no backing.
ColumnLayout {
    id: clock

    property date now: new Date()
    // From the machine settings: 24-hour ("21:05") or 12-hour ("9:05 PM").
    property bool clock24Hour: true

    spacing: Theme.space1

    // Checks the wall clock every second and moves `now` only when the minute has changed, so
    // bindings don't churn. An aimed one-shot timer runs on monotonic time and stays wrong
    // after a suspend or a wall-clock step; this one corrects itself within a second.
    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: {
            const current = new Date();
            const minute = t => Math.floor(t.getTime() / 60000);
            if (minute(current) !== minute(clock.now))
                clock.now = current;
        }
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
        text: Qt.formatTime(clock.now, clock.clock24Hour ? "HH:mm" : "h:mm AP")
        font.family: Theme.display.font.family
        font.pixelSize: Theme.display.font.pixelSize
        font.weight: Theme.display.font.weight
        font.letterSpacing: Theme.display.font.letterSpacing
        // Tabular figures, so the digits don't shift as the minutes change.
        font.features: {
            "tnum": 1
        }
        lineHeight: Theme.display.lineHeight
        lineHeightMode: Text.FixedHeight
        color: Theme.textPrimary
    }
}
