import QtQuick
import QtTest
import Modality.Theme
import Modality.Controls

TestCase {
    name: "IconButton"
    width: 300
    height: 200
    visible: true
    when: windowShown

    Component {
        id: iconButtonComponent

        IconButton {
            x: 20
            y: 20
            text: "Restart"
            glyph: Glyphs.restart
        }
    }

    SignalSpy {
        id: clickedSpy

        signalName: "clicked"
    }

    function createIconButton(properties) {
        const button = createTemporaryObject(iconButtonComponent, this, properties ?? {});
        verify(button);
        return button;
    }

    function circleCentre(button) {
        return { x: button.width / 2, y: Theme.space10 / 2 };
    }

    function cleanup() {
        Theme.theme = "dark";
        Theme.reduceTransparency = false;
        clickedSpy.clear();
    }

    function test_icon_button_default_is_glass_with_raised_shadow() {
        const button = createIconButton();
        compare(button.fillColor, Theme.materialPopoverTint);
        compare(button.glyphColor, Theme.textPrimary);
        compare(button.shadow, Theme.shadowRaised);
        compare(button.circleScale, 1);
        compare(button.circleOpacity, 1);
        verify(!button.ringShown);
    }

    function test_icon_button_hover_is_opaque_overlay_with_floating_shadow() {
        const button = createIconButton();
        const centre = circleCentre(button);
        mouseMove(button, centre.x, centre.y);
        tryVerify(() => button.hovered);
        compare(button.fillColor, Theme.surfaceOverlay);
        compare(button.shadow, Theme.shadowFloating);
    }

    function test_icon_button_pressed_is_sunken_and_shrinks_without_shadow() {
        const button = createIconButton();
        const centre = circleCentre(button);
        mousePress(button, centre.x, centre.y);
        verify(button.pressed);
        compare(button.fillColor, Theme.surfaceSunken);
        compare(button.circleScale, 0.95);
        compare(button.shadow, null);
        mouseRelease(button, centre.x, centre.y);
    }

    function test_icon_button_focused_is_glass_with_the_ring() {
        const button = createIconButton();
        button.forceActiveFocus();
        verify(button.ringShown);
        compare(button.fillColor, Theme.materialPopoverTint);
    }

    function test_icon_button_disabled_dims_the_glyph_and_drops_the_shadow() {
        const button = createIconButton({ enabled: false });
        compare(button.fillColor, Theme.materialPopoverTint);
        compare(button.glyphColor, Theme.textDisabled);
        compare(button.circleOpacity, 0.5);
        compare(button.shadow, null);
    }

    function test_icon_button_glass_uses_the_fallback_when_transparency_is_reduced() {
        const button = createIconButton();
        Theme.reduceTransparency = true;
        compare(button.fillColor, Theme.materialPopoverFallback);
    }

    function test_icon_button_options_open_is_opaque_overlay() {
        const button = createIconButton({ checkable: true, checked: true });
        compare(button.fillColor, Theme.surfaceOverlay);
    }

    function test_icon_button_label_is_footnote_medium() {
        const button = createIconButton();
        compare(button.font.pixelSize, Theme.footnoteMedium.font.pixelSize);
        compare(button.font.weight, Theme.footnoteMedium.font.weight);
        compare(button.labelColor, Theme.textPrimary);
    }

    function test_enter_and_space_activate_a_focused_icon_button() {
        const button = createIconButton();
        clickedSpy.target = button;
        button.forceActiveFocus();
        keyClick(Qt.Key_Return);
        keyClick(Qt.Key_Space);
        compare(clickedSpy.count, 2);
    }

    function test_icon_button_is_named_by_its_label() {
        const button = createIconButton();
        compare(button.Accessible.name, "Restart");
    }

    function test_icon_button_states_can_be_set_through_properties() {
        const button = createIconButton({ hoverActive: true });
        compare(button.fillColor, Theme.surfaceOverlay);
        button.down = true;
        compare(button.fillColor, Theme.surfaceSunken);
        compare(button.circleScale, 0.95);
        button.down = false;
        button.ringShown = true;
        verify(!button.activeFocus);
    }
}
