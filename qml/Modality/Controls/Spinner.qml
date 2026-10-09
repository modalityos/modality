import QtQuick
import Modality.Theme

// The Checking spinner: a fillStrong track with a textSecondary quarter arc, turning.
Item {
    id: spinner

    property bool running: false

    implicitWidth: 18
    implicitHeight: 18
    Accessible.role: Accessible.Animation
    Accessible.name: qsTr("Checking")

    Icon {
        anchors.fill: parent
        glyph: Glyphs.spinnerTrack
        color: Theme.fillStrong
    }

    Icon {
        id: arc

        anchors.fill: parent
        glyph: Glyphs.spinnerArc
        color: Theme.textSecondary

        RotationAnimator on rotation {
            from: 0
            to: 360
            duration: 800
            loops: Animation.Infinite
            running: spinner.running && spinner.visible
        }
    }
}
