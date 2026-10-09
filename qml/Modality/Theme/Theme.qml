pragma Singleton
import QtQuick

// Foundations Tokens (design/foundations/spec.md) under their code names.
QtObject {
    // "dark" or "light"; the Greeter defaults to dark.
    property string theme: "dark"

    readonly property bool dark: theme !== "light"

    // Colours
    readonly property color bg: dark ? "#1f1e1d" : "#efeeec"
    readonly property color surfaceRaised: dark ? "#2b2a28" : "#ffffff"
    readonly property color surfaceSunken: dark ? "#181716" : "#e6e5e3"
    readonly property color surfaceOverlay: dark ? "#2f2e2c" : "#fbfbfa"
    readonly property color fill: dark ? rgba(255, 255, 255, 0.08) : rgba(0, 0, 0, 0.05)
    readonly property color fillStrong: dark ? rgba(255, 255, 255, 0.14) : rgba(0, 0, 0, 0.1)
    readonly property color separator: dark ? rgba(255, 255, 255, 0.1) : rgba(0, 0, 0, 0.1)
    readonly property color borderStrong: dark ? rgba(255, 255, 255, 0.42) : rgba(0, 0, 0, 0.48)
    readonly property color textPrimary: dark ? rgba(255, 255, 255, 0.88) : rgba(0, 0, 0, 0.86)
    readonly property color textSecondary: dark ? rgba(255, 255, 255, 0.64) : rgba(0, 0, 0, 0.64)
    readonly property color textTertiary: dark ? rgba(255, 255, 255, 0.56) : rgba(0, 0, 0, 0.58)
    readonly property color textDisabled: dark ? rgba(255, 255, 255, 0.26) : rgba(0, 0, 0, 0.26)
    readonly property color accent: dark ? "#366bfc" : "#1c6ee8"
    readonly property color accentHover: dark ? "#2f62ee" : "#1862d0"
    readonly property color accentPressed: dark ? "#2858dc" : "#1455b8"
    readonly property color accentSubtle: dark ? rgba(80, 150, 255, 0.2) : rgba(28, 110, 232, 0.14)
    // Assigned in onCompleted: an "onAccent:" initializer would parse as a signal handler.
    property color onAccent
    readonly property color accentText: dark ? "#8cbcff" : "#1255b8"
    readonly property color success: dark ? "#4fd27a" : "#17652f"
    readonly property color successSubtle: dark ? rgba(79, 210, 122, 0.16) : rgba(30, 160, 70, 0.14)
    readonly property color warning: dark ? "#f5b83d" : "#7a4e00"
    readonly property color warningSubtle: dark ? rgba(245, 184, 61, 0.16) : rgba(240, 160, 0, 0.16)
    readonly property color danger: dark ? "#ff8f87" : "#a8231f"
    readonly property color dangerSubtle: dark ? rgba(255, 125, 116, 0.12) : rgba(230, 50, 40, 0.12)
    readonly property color info: dark ? "#8cbcff" : "#1255b8"
    readonly property color infoSubtle: dark ? rgba(120, 176, 255, 0.12) : rgba(28, 110, 232, 0.12)
    readonly property color focusRing: dark ? "#8cbcff" : "#1c6ee8"
    readonly property color scrim: dark ? rgba(0, 0, 0, 0.5) : rgba(0, 0, 0, 0.28)
    readonly property color wallpaper1: dark ? "#1f45c0" : "#6f9dff"
    readonly property color wallpaper2: dark ? "#5530b0" : "#a98cff"
    readonly property color wallpaper3: dark ? "#a0306e" : "#ff9fbf"
    readonly property color materialPanelTint: dark ? rgba(40, 40, 40, 0.68) : rgba(246, 245, 243, 0.72)
    readonly property color materialPanelFallback: dark ? "#272624" : "#f3f2f0"
    readonly property color materialPopoverTint: dark ? rgba(32, 32, 34, 0.9) : rgba(251, 251, 250, 0.82)
    readonly property color materialPopoverFallback: dark ? "#2f2e2c" : "#fbfbfa"
    readonly property color materialSidebarTint: dark ? rgba(30, 30, 30, 0.62) : rgba(236, 234, 231, 0.68)
    readonly property color materialSidebarFallback: dark ? "#242321" : "#e9e8e5"

    // Elevation: a 0.5px hairline plus one soft shadow
    readonly property var shadowResting: dark ? shadow(rgba(255, 255, 255, 0.08), 1, 2, rgba(0, 0, 0, 0.4)) : shadow(rgba(0, 0, 0, 0.08), 1, 2, rgba(0, 0, 0, 0.05))
    readonly property var shadowRaised: dark ? shadow(rgba(255, 255, 255, 0.1), 2, 6, rgba(0, 0, 0, 0.5)) : shadow(rgba(0, 0, 0, 0.1), 2, 6, rgba(0, 0, 0, 0.1))
    readonly property var shadowFloating: dark ? shadow(rgba(255, 255, 255, 0.12), 10, 30, rgba(0, 0, 0, 0.55)) : shadow(rgba(0, 0, 0, 0.12), 10, 30, rgba(0, 0, 0, 0.16))
    readonly property var shadowModal: dark ? shadow(rgba(255, 255, 255, 0.14), 22, 60, rgba(0, 0, 0, 0.65)) : shadow(rgba(0, 0, 0, 0.14), 22, 60, rgba(0, 0, 0, 0.28))

    // Spacing
    readonly property int space1: 4
    readonly property int space2: 8
    readonly property int space3: 12
    readonly property int space4: 16
    readonly property int space5: 20
    readonly property int space6: 24
    readonly property int space8: 32
    readonly property int space10: 40
    readonly property int space12: 48
    readonly property int space16: 64

    // Shape
    readonly property int radiusSmall: 6
    readonly property int radiusControl: 8
    readonly property int radiusCard: 12
    readonly property int radiusPanel: 16
    readonly property int radiusPill: 9999

    // Sizes
    readonly property int controlHeight: 28
    readonly property int controlHeightSmall: 24
    readonly property int rowHeight: 28
    readonly property int controlHeightLarge: 32
    readonly property int rowHeightLarge: 44
    readonly property int toolbarHeight: 52
    readonly property int avatarSizeLarge: 96

    // Materials: compositor blur amounts
    readonly property int materialPanelBlur: 30
    readonly property int materialPopoverBlur: 24
    readonly property int materialSidebarBlur: 40
    readonly property real materialSaturation: 1.6

    // Wallpaper gradient
    readonly property int wallpaperAngle: 135
    readonly property real wallpaperMidStop: 0.55

    // Focus
    readonly property int focusRingWidth: 3
    readonly property int focusRingOffset: 2

    // Motion: durations in ms, easings as Easing.BezierCurve control points
    readonly property int motionDurationFast: 100
    readonly property int motionDurationNormal: 200
    readonly property int motionDurationSlow: 300
    readonly property var motionEasingStandard: [0.2, 0, 0, 1, 1, 1]
    readonly property var motionEasingIn: [0.4, 0, 1, 1, 1, 1]
    readonly property var motionEasingOut: [0, 0, 0.2, 1, 1, 1]
    readonly property var motionEasingSpring: [0.34, 1.56, 0.64, 1, 1, 1]

    // Type. Noto Sans and Noto Sans Mono fill in through fontconfig for scripts these lack.
    readonly property string fontSans: "Inter"
    readonly property string fontMono: "JetBrains Mono"

    // Each type style is { font, lineHeight }; set Text.lineHeightMode to Text.FixedHeight.
    readonly property var caption: typeStyle(fontSans, 10, 13, Font.Medium, 0.01)
    readonly property var footnote: typeStyle(fontSans, 11, 14, Font.Normal, 0)
    readonly property var footnoteMedium: typeStyle(fontSans, 11, 14, Font.Medium, 0)
    readonly property var footnoteStrong: typeStyle(fontSans, 11, 14, Font.DemiBold, 0)
    readonly property var body: typeStyle(fontSans, 13, 16, Font.Normal, 0)
    readonly property var bodyMedium: typeStyle(fontSans, 13, 16, Font.Medium, 0)
    readonly property var bodyStrong: typeStyle(fontSans, 13, 16, Font.DemiBold, 0)
    readonly property var headline: typeStyle(fontSans, 15, 20, Font.DemiBold, 0)
    readonly property var title3: typeStyle(fontSans, 15, 20, Font.Medium, 0)
    readonly property var title2: typeStyle(fontSans, 17, 22, Font.DemiBold, 0)
    readonly property var title1: typeStyle(fontSans, 22, 28, Font.DemiBold, -0.01)
    readonly property var largeTitle: typeStyle(fontSans, 26, 32, Font.Bold, -0.015)
    readonly property var display: typeStyle(fontSans, 96, 100, Font.DemiBold, -0.03)
    readonly property var mono: typeStyle(fontMono, 12, 16, Font.Normal, 0)

    function typeStyle(family, size, lineHeight, weight, letterSpacingEm) {
        return {
            font: Qt.font({ family: family, pixelSize: size, weight: weight, letterSpacing: letterSpacingEm * size }),
            lineHeight: lineHeight
        };
    }

    function rgba(r, g, b, a) {
        return Qt.rgba(r / 255, g / 255, b / 255, a);
    }

    function shadow(hairlineColor, offsetY, blur, color) {
        return { hairlineWidth: 0.5, hairlineColor: hairlineColor, offsetX: 0, offsetY: offsetY, blur: blur, color: color };
    }

    Component.onCompleted: onAccent = "#ffffff"
}
