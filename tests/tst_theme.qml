import QtQuick
import QtTest
import Modality.Theme

// Every Foundations Token, by code name, against design/foundations/spec.md.
TestCase {
    name: "Theme"

    // Expected values copied from the Tokens table of design/foundations/spec.md.
    readonly property var tokens: [
        {"name": "bg", "light": {"color": "#efeeec"}, "dark": {"color": "#1f1e1d"}},
        {"name": "surfaceRaised", "light": {"color": "#ffffff"}, "dark": {"color": "#2b2a28"}},
        {"name": "surfaceSunken", "light": {"color": "#e6e5e3"}, "dark": {"color": "#181716"}},
        {"name": "surfaceOverlay", "light": {"color": "#fbfbfa"}, "dark": {"color": "#2f2e2c"}},
        {"name": "fill", "light": {"color": "rgba(0, 0, 0, 0.05)"}, "dark": {"color": "rgba(255, 255, 255, 0.08)"}},
        {"name": "fillStrong", "light": {"color": "rgba(0, 0, 0, 0.1)"}, "dark": {"color": "rgba(255, 255, 255, 0.14)"}},
        {"name": "separator", "light": {"color": "rgba(0, 0, 0, 0.1)"}, "dark": {"color": "rgba(255, 255, 255, 0.1)"}},
        {"name": "borderStrong", "light": {"color": "rgba(0, 0, 0, 0.48)"}, "dark": {"color": "rgba(255, 255, 255, 0.42)"}},
        {"name": "textPrimary", "light": {"color": "rgba(0, 0, 0, 0.86)"}, "dark": {"color": "rgba(255, 255, 255, 0.88)"}},
        {"name": "textSecondary", "light": {"color": "rgba(0, 0, 0, 0.64)"}, "dark": {"color": "rgba(255, 255, 255, 0.64)"}},
        {"name": "textTertiary", "light": {"color": "rgba(0, 0, 0, 0.58)"}, "dark": {"color": "rgba(255, 255, 255, 0.56)"}},
        {"name": "textDisabled", "light": {"color": "rgba(0, 0, 0, 0.26)"}, "dark": {"color": "rgba(255, 255, 255, 0.26)"}},
        {"name": "accent", "light": {"color": "#1c6ee8"}, "dark": {"color": "#366bfc"}},
        {"name": "accentHover", "light": {"color": "#1862d0"}, "dark": {"color": "#2f62ee"}},
        {"name": "accentPressed", "light": {"color": "#1455b8"}, "dark": {"color": "#2858dc"}},
        {"name": "accentSubtle", "light": {"color": "rgba(28, 110, 232, 0.14)"}, "dark": {"color": "rgba(80, 150, 255, 0.2)"}},
        {"name": "onAccent", "light": {"color": "#ffffff"}, "dark": {"color": "#ffffff"}},
        {"name": "accentText", "light": {"color": "#1255b8"}, "dark": {"color": "#8cbcff"}},
        {"name": "success", "light": {"color": "#17652f"}, "dark": {"color": "#4fd27a"}},
        {"name": "successSubtle", "light": {"color": "rgba(30, 160, 70, 0.14)"}, "dark": {"color": "rgba(79, 210, 122, 0.16)"}},
        {"name": "warning", "light": {"color": "#7a4e00"}, "dark": {"color": "#f5b83d"}},
        {"name": "warningSubtle", "light": {"color": "rgba(240, 160, 0, 0.16)"}, "dark": {"color": "rgba(245, 184, 61, 0.16)"}},
        {"name": "danger", "light": {"color": "#a8231f"}, "dark": {"color": "#ff8f87"}},
        {"name": "dangerSubtle", "light": {"color": "rgba(230, 50, 40, 0.12)"}, "dark": {"color": "rgba(255, 125, 116, 0.12)"}},
        {"name": "info", "light": {"color": "#1255b8"}, "dark": {"color": "#8cbcff"}},
        {"name": "infoSubtle", "light": {"color": "rgba(28, 110, 232, 0.12)"}, "dark": {"color": "rgba(120, 176, 255, 0.12)"}},
        {"name": "focusRing", "light": {"color": "#1c6ee8"}, "dark": {"color": "#8cbcff"}},
        {"name": "scrim", "light": {"color": "rgba(0, 0, 0, 0.28)"}, "dark": {"color": "rgba(0, 0, 0, 0.5)"}},
        {"name": "wallpaper1", "light": {"color": "#6f9dff"}, "dark": {"color": "#1f45c0"}},
        {"name": "wallpaper2", "light": {"color": "#a98cff"}, "dark": {"color": "#5530b0"}},
        {"name": "wallpaper3", "light": {"color": "#ff9fbf"}, "dark": {"color": "#a0306e"}},
        {"name": "materialPanelTint", "light": {"color": "rgba(246, 245, 243, 0.72)"}, "dark": {"color": "rgba(40, 40, 40, 0.68)"}},
        {"name": "materialPanelFallback", "light": {"color": "#f3f2f0"}, "dark": {"color": "#272624"}},
        {"name": "materialPopoverTint", "light": {"color": "rgba(251, 251, 250, 0.82)"}, "dark": {"color": "rgba(32, 32, 34, 0.9)"}},
        {"name": "materialPopoverFallback", "light": {"color": "#fbfbfa"}, "dark": {"color": "#2f2e2c"}},
        {"name": "materialSidebarTint", "light": {"color": "rgba(236, 234, 231, 0.68)"}, "dark": {"color": "rgba(30, 30, 30, 0.62)"}},
        {"name": "materialSidebarFallback", "light": {"color": "#e9e8e5"}, "dark": {"color": "#242321"}},
        {"name": "shadowResting", "light": {"shadow": {"hairlineWidth": 0.5, "hairlineColor": "rgba(0, 0, 0, 0.08)", "offsetX": 0.0, "offsetY": 1.0, "blur": 2.0, "color": "rgba(0, 0, 0, 0.05)"}}, "dark": {"shadow": {"hairlineWidth": 0.5, "hairlineColor": "rgba(255, 255, 255, 0.08)", "offsetX": 0.0, "offsetY": 1.0, "blur": 2.0, "color": "rgba(0, 0, 0, 0.4)"}}},
        {"name": "shadowRaised", "light": {"shadow": {"hairlineWidth": 0.5, "hairlineColor": "rgba(0, 0, 0, 0.1)", "offsetX": 0.0, "offsetY": 2.0, "blur": 6.0, "color": "rgba(0, 0, 0, 0.1)"}}, "dark": {"shadow": {"hairlineWidth": 0.5, "hairlineColor": "rgba(255, 255, 255, 0.1)", "offsetX": 0.0, "offsetY": 2.0, "blur": 6.0, "color": "rgba(0, 0, 0, 0.5)"}}},
        {"name": "shadowFloating", "light": {"shadow": {"hairlineWidth": 0.5, "hairlineColor": "rgba(0, 0, 0, 0.12)", "offsetX": 0.0, "offsetY": 10.0, "blur": 30.0, "color": "rgba(0, 0, 0, 0.16)"}}, "dark": {"shadow": {"hairlineWidth": 0.5, "hairlineColor": "rgba(255, 255, 255, 0.12)", "offsetX": 0.0, "offsetY": 10.0, "blur": 30.0, "color": "rgba(0, 0, 0, 0.55)"}}},
        {"name": "shadowModal", "light": {"shadow": {"hairlineWidth": 0.5, "hairlineColor": "rgba(0, 0, 0, 0.14)", "offsetX": 0.0, "offsetY": 22.0, "blur": 60.0, "color": "rgba(0, 0, 0, 0.28)"}}, "dark": {"shadow": {"hairlineWidth": 0.5, "hairlineColor": "rgba(255, 255, 255, 0.14)", "offsetX": 0.0, "offsetY": 22.0, "blur": 60.0, "color": "rgba(0, 0, 0, 0.65)"}}},
        {"name": "space1", "light": {"number": 4.0}, "dark": null},
        {"name": "space2", "light": {"number": 8.0}, "dark": null},
        {"name": "space3", "light": {"number": 12.0}, "dark": null},
        {"name": "space4", "light": {"number": 16.0}, "dark": null},
        {"name": "space5", "light": {"number": 20.0}, "dark": null},
        {"name": "space6", "light": {"number": 24.0}, "dark": null},
        {"name": "space8", "light": {"number": 32.0}, "dark": null},
        {"name": "space10", "light": {"number": 40.0}, "dark": null},
        {"name": "space12", "light": {"number": 48.0}, "dark": null},
        {"name": "space16", "light": {"number": 64.0}, "dark": null},
        {"name": "radiusSmall", "light": {"number": 6.0}, "dark": null},
        {"name": "radiusControl", "light": {"number": 8.0}, "dark": null},
        {"name": "radiusCard", "light": {"number": 12.0}, "dark": null},
        {"name": "radiusPanel", "light": {"number": 16.0}, "dark": null},
        {"name": "radiusPill", "light": {"number": 9999.0}, "dark": null},
        {"name": "controlHeight", "light": {"number": 28.0}, "dark": null},
        {"name": "controlHeightSmall", "light": {"number": 24.0}, "dark": null},
        {"name": "rowHeight", "light": {"number": 28.0}, "dark": null},
        {"name": "controlHeightLarge", "light": {"number": 32.0}, "dark": null},
        {"name": "rowHeightLarge", "light": {"number": 44.0}, "dark": null},
        {"name": "toolbarHeight", "light": {"number": 52.0}, "dark": null},
        {"name": "avatarSizeLarge", "light": {"number": 96.0}, "dark": null},
        {"name": "materialPanelBlur", "light": {"number": 30.0}, "dark": null},
        {"name": "materialPopoverBlur", "light": {"number": 24.0}, "dark": null},
        {"name": "materialSidebarBlur", "light": {"number": 40.0}, "dark": null},
        {"name": "materialSaturation", "light": {"number": 1.6}, "dark": null},
        {"name": "wallpaperAngle", "light": {"number": 135.0}, "dark": null},
        {"name": "wallpaperMidStop", "light": {"number": 0.55}, "dark": null},
        {"name": "focusRingWidth", "light": {"number": 3.0}, "dark": null},
        {"name": "focusRingOffset", "light": {"number": 2.0}, "dark": null},
        {"name": "motionDurationFast", "light": {"number": 100.0}, "dark": null},
        {"name": "motionDurationNormal", "light": {"number": 200.0}, "dark": null},
        {"name": "motionDurationSlow", "light": {"number": 300.0}, "dark": null},
        {"name": "motionEasingStandard", "light": {"easing": [0.2, 0.0, 0.0, 1.0, 1, 1]}, "dark": null},
        {"name": "motionEasingIn", "light": {"easing": [0.4, 0.0, 1.0, 1.0, 1, 1]}, "dark": null},
        {"name": "motionEasingOut", "light": {"easing": [0.0, 0.0, 0.2, 1.0, 1, 1]}, "dark": null},
        {"name": "motionEasingSpring", "light": {"easing": [0.34, 1.56, 0.64, 1.0, 1, 1]}, "dark": null}

    ]

    // Type styles from the Type table of design/foundations/spec.md.
    readonly property var typeStyles: [
        { name: "caption", family: "Inter", size: 10, lineHeight: 13, weight: 500, letterSpacingEm: 0.01 },
        { name: "footnote", family: "Inter", size: 11, lineHeight: 14, weight: 400, letterSpacingEm: 0 },
        { name: "footnoteMedium", family: "Inter", size: 11, lineHeight: 14, weight: 500, letterSpacingEm: 0 },
        { name: "footnoteStrong", family: "Inter", size: 11, lineHeight: 14, weight: 600, letterSpacingEm: 0 },
        { name: "body", family: "Inter", size: 13, lineHeight: 16, weight: 400, letterSpacingEm: 0 },
        { name: "bodyMedium", family: "Inter", size: 13, lineHeight: 16, weight: 500, letterSpacingEm: 0 },
        { name: "bodyStrong", family: "Inter", size: 13, lineHeight: 16, weight: 600, letterSpacingEm: 0 },
        { name: "headline", family: "Inter", size: 15, lineHeight: 20, weight: 600, letterSpacingEm: 0 },
        { name: "title3", family: "Inter", size: 15, lineHeight: 20, weight: 500, letterSpacingEm: 0 },
        { name: "title2", family: "Inter", size: 17, lineHeight: 22, weight: 600, letterSpacingEm: 0 },
        { name: "title1", family: "Inter", size: 22, lineHeight: 28, weight: 600, letterSpacingEm: -0.01 },
        { name: "largeTitle", family: "Inter", size: 26, lineHeight: 32, weight: 700, letterSpacingEm: -0.015 },
        { name: "display", family: "Inter", size: 96, lineHeight: 100, weight: 600, letterSpacingEm: -0.03 },
        { name: "mono", family: "JetBrains Mono", size: 12, lineHeight: 16, weight: 400, letterSpacingEm: 0 }
    ]

    function cssColor(css) {
        if (css.startsWith("#"))
            return Qt.color(css);
        const parts = css.match(/rgba\(([^)]*)\)/)[1].split(",").map(Number);
        return Qt.rgba(parts[0] / 255, parts[1] / 255, parts[2] / 255, parts[3]);
    }

    function compareColor(actual, css, label) {
        const expected = cssColor(css);
        const tolerance = 1 / 255;
        verify(actual !== undefined, `${label} is missing`);
        verify(Math.abs(actual.r - expected.r) <= tolerance
               && Math.abs(actual.g - expected.g) <= tolerance
               && Math.abs(actual.b - expected.b) <= tolerance
               && Math.abs(actual.a - expected.a) <= tolerance,
               `${label}: expected ${css}, got ${actual}`);
    }

    function compareValue(actual, expected, label) {
        if (expected.color !== undefined) {
            compareColor(actual, expected.color, label);
        } else if (expected.number !== undefined) {
            fuzzyCompare(actual, expected.number, 1e-9, label);
        } else if (expected.easing !== undefined) {
            compare(actual, expected.easing, label);
        } else {
            const shadow = expected.shadow;
            verify(actual !== undefined && actual !== null, `${label} is missing`);
            compare(actual.hairlineWidth, shadow.hairlineWidth, `${label} hairline width`);
            compareColor(actual.hairlineColor, shadow.hairlineColor, `${label} hairline colour`);
            compare(actual.offsetX, shadow.offsetX, `${label} x offset`);
            compare(actual.offsetY, shadow.offsetY, `${label} y offset`);
            compare(actual.blur, shadow.blur, `${label} blur`);
            compareColor(actual.color, shadow.color, `${label} colour`);
        }
    }

    function cleanup() {
        Theme.theme = "dark";
    }

    function test_greeter_theme_defaults_to_dark() {
        compare(Theme.theme, "dark");
    }

    function test_every_token_has_its_light_value() {
        Theme.theme = "light";
        for (const token of tokens)
            compareValue(Theme[token.name], token.light, `${token.name} (light)`);
    }

    function test_every_token_has_its_dark_value() {
        Theme.theme = "dark";
        for (const token of tokens)
            compareValue(Theme[token.name], token.dark ?? token.light, `${token.name} (dark)`);
    }

    function test_font_families_are_inter_and_jetbrains_mono() {
        compare(Theme.fontSans, "Inter");
        compare(Theme.fontMono, "JetBrains Mono");
    }

    function test_every_type_style_has_its_family_size_line_height_weight_and_spacing() {
        for (const style of typeStyles) {
            const actual = Theme[style.name];
            verify(actual !== undefined, `${style.name} is missing`);
            compare(actual.font.family, style.family, `${style.name} family`);
            compare(actual.font.pixelSize, style.size, `${style.name} size`);
            compare(actual.font.weight, style.weight, `${style.name} weight`);
            compare(actual.lineHeight, style.lineHeight, `${style.name} line height`);
            fuzzyCompare(actual.font.letterSpacing, style.letterSpacingEm * style.size, 0.05, `${style.name} letter spacing`);
        }
    }
}
