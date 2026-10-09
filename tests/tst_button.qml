import QtQuick
import QtTest
import Modality.Theme
import Modality.Controls

TestCase {
    name: "Button"
    width: 400
    height: 200
    visible: true
    when: windowShown

    Component {
        id: buttonComponent

        Button {
            x: 20
            y: 20
            text: "Try again"
        }
    }

    SignalSpy {
        id: clickedSpy

        signalName: "clicked"
    }

    function createButton(properties) {
        const button = createTemporaryObject(buttonComponent, this, properties ?? {});
        verify(button);
        return button;
    }

    function cleanup() {
        Theme.theme = "dark";
        clickedSpy.clear();
    }

    function test_primary_button_default_is_accent_with_raised_shadow() {
        const button = createButton();
        compare(button.fillColor, Theme.accent);
        compare(button.labelColor, Theme.onAccent);
        compare(button.shadow, Theme.shadowRaised);
        compare(button.radius, Theme.radiusPill);
        compare(button.height, Theme.controlHeightSmall);
        verify(!button.ringShown);
    }

    function test_primary_button_hover_is_accent_hover() {
        const button = createButton();
        mouseMove(button, button.width / 2, button.height / 2);
        tryVerify(() => button.hovered);
        compare(button.fillColor, Theme.accentHover);
        compare(button.shadow, Theme.shadowRaised);
    }

    function test_primary_button_pressed_is_accent_pressed_without_shadow() {
        const button = createButton();
        mousePress(button, button.width / 2, button.height / 2);
        verify(button.pressed);
        compare(button.fillColor, Theme.accentPressed);
        compare(button.shadow, null);
        mouseRelease(button, button.width / 2, button.height / 2);
    }

    function test_primary_button_focused_shows_the_ring() {
        const button = createButton();
        button.forceActiveFocus();
        verify(button.ringShown);
        compare(button.fillColor, Theme.accent);
    }

    function test_primary_button_disabled_is_fill_with_disabled_text() {
        const button = createButton({ enabled: false });
        compare(button.fillColor, Theme.fill);
        compare(button.labelColor, Theme.textDisabled);
        compare(button.shadow, null);
    }

    function test_secondary_button_states() {
        const button = createButton({ variant: Button.Secondary, text: "Cancel" });
        compare(button.fillColor, Theme.fill);
        compare(button.labelColor, Theme.textPrimary);
        compare(button.shadow, null);
        compare(button.radius, Theme.radiusControl);
        compare(button.height, Theme.controlHeight);

        mouseMove(button, button.width / 2, button.height / 2);
        tryVerify(() => button.hovered);
        compare(button.fillColor, Theme.fillStrong);

        mousePress(button, button.width / 2, button.height / 2);
        compare(button.fillColor, Theme.fillStrong);
        mouseRelease(button, button.width / 2, button.height / 2);

        button.forceActiveFocus();
        verify(button.ringShown);

        button.enabled = false;
        compare(button.fillColor, Theme.fill);
        compare(button.labelColor, Theme.textDisabled);
    }

    function test_button_label_uses_body_medium() {
        const button = createButton();
        compare(button.font.pixelSize, Theme.bodyMedium.font.pixelSize);
        compare(button.font.weight, Theme.bodyMedium.font.weight);
        compare(button.font.family, Theme.fontSans);
    }

    function test_enter_and_space_activate_a_focused_button() {
        const button = createButton();
        clickedSpy.target = button;
        button.forceActiveFocus();
        keyClick(Qt.Key_Return);
        compare(clickedSpy.count, 1);
        keyClick(Qt.Key_Space);
        compare(clickedSpy.count, 2);
    }

    function test_button_follows_the_light_theme() {
        const button = createButton();
        Theme.theme = "light";
        compare(button.fillColor, Theme.accent);
        compare(button.fillColor, Qt.color("#1c6ee8"));
    }

    function test_button_states_can_be_set_through_properties() {
        const button = createButton({ hoverActive: true });
        compare(button.fillColor, Theme.accentHover);
        button.down = true;
        compare(button.fillColor, Theme.accentPressed);
        button.down = false;
        button.ringShown = true;
        verify(button.ringShown);
        verify(!button.activeFocus);
    }
}
