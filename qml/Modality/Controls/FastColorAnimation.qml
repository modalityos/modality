import QtQuick
import Modality.Theme

// Hover and press colour change: motionDurationFast on motionEasingStandard.
ColorAnimation {
    duration: Theme.motionDurationFast
    easing.type: Easing.Bezier
    easing.bezierCurve: Theme.motionEasingStandard
}
