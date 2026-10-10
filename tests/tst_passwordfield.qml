import QtQuick
import QtTest
import Modality.Theme
import Modality.Controls

TestCase {
    name: "PasswordField"
    width: 400
    height: 200
    visible: true
    when: windowShown

    Component {
        id: fieldComponent

        PasswordField {
            x: 40
            y: 40
        }
    }

    Component {
        id: typedSpyComponent

        SignalSpy {
            signalName: "typed"
        }
    }

    SignalSpy {
        id: submittedSpy

        signalName: "submitted"
    }

    function createField(properties) {
        const field = createTemporaryObject(fieldComponent, this, properties ?? {});
        verify(field);
        submittedSpy.target = field;
        return field;
    }

    function typeText(text) {
        for (const character of text)
            keyClick(character);
    }

    // The submit button is the 24px circle 4px in from the field's right edge.
    function submitButtonCentre(field) {
        return {
            x: field.width - 4 - Theme.controlHeightSmall / 2,
            y: field.height / 2
        };
    }

    function cleanup() {
        submittedSpy.clear();
        Theme.reduceTransparency = false;
    }

    function test_password_field_is_a_large_pill_with_placeholder() {
        const field = createField();
        compare(field.width, 240);
        compare(field.height, Theme.controlHeightLarge);
        compare(field.radius, Theme.controlHeightLarge / 2);
        compare(field.placeholderText, "Enter password");
    }

    function test_password_field_hides_what_is_typed() {
        const field = createField();
        field.forceActiveFocus();
        typeText("secret");
        compare(field.text, "secret");
        compare(field.echoMode, TextInput.Password);
    }

    function test_enter_submits_the_password() {
        const field = createField();
        field.forceActiveFocus();
        typeText("secret");
        keyClick(Qt.Key_Return);
        compare(submittedSpy.count, 1);
        compare(submittedSpy.signalArguments[0][0], "secret");
    }

    function test_enter_on_an_empty_field_is_ignored() {
        const field = createField();
        field.forceActiveFocus();
        keyClick(Qt.Key_Return);
        compare(submittedSpy.count, 0);
    }

    function test_the_arrow_button_submits_the_password() {
        const field = createField();
        field.forceActiveFocus();
        typeText("secret");
        const centre = submitButtonCentre(field);
        mouseClick(field, centre.x, centre.y);
        compare(submittedSpy.count, 1);
        compare(submittedSpy.signalArguments[0][0], "secret");
    }

    function test_escape_clears_the_field() {
        const field = createField();
        field.forceActiveFocus();
        typeText("secret");
        keyClick(Qt.Key_Escape);
        compare(field.text, "");
    }

    function test_password_field_default_is_glass_with_floating_shadow() {
        const field = createField();
        compare(field.fillColor, Theme.materialPopoverTint);
        compare(field.shadow, Theme.shadowFloating);
        verify(!field.ringShown);
    }

    function test_password_field_hover_is_opaque_overlay() {
        const field = createField();
        mouseMove(field, 40, field.height / 2);
        tryVerify(() => field.hovered);
        compare(field.fillColor, Theme.surfaceOverlay);
        compare(field.shadow, Theme.shadowFloating);
    }

    function test_password_field_pressed_is_opaque_overlay_with_raised_shadow() {
        const field = createField();
        mousePress(field, 40, field.height / 2);
        tryVerify(() => field.pressed);
        compare(field.fillColor, Theme.surfaceOverlay);
        compare(field.shadow, Theme.shadowRaised);
        mouseRelease(field, 40, field.height / 2);
    }

    function test_clicking_the_field_focuses_it() {
        const field = createField();
        mouseClick(field, 40, field.height / 2);
        verify(field.activeFocus);
        verify(field.ringShown);
    }

    function test_focused_password_field_shows_the_ring_on_glass() {
        const field = createField();
        field.forceActiveFocus();
        verify(field.ringShown);
        compare(field.fillColor, Theme.materialPopoverTint);
        compare(field.shadow, Theme.shadowFloating);
    }

    function test_disabled_password_field_fades_without_shadow() {
        const field = createField({
            enabled: false
        });
        compare(field.visualOpacity, 0.5);
        compare(field.shadow, null);
        compare(field.fillColor, Theme.materialPopoverTint);
    }

    function test_busy_password_field_dims_hides_the_ring_and_ignores_input() {
        const field = createField();
        field.forceActiveFocus();
        typeText("secret");
        field.busy = true;
        compare(field.visualOpacity, 0.7);
        verify(!field.ringShown);
        verify(field.activeFocus);
        typeText("x");
        keyClick(Qt.Key_Return);
        compare(field.text, "secret");
        compare(submittedSpy.count, 0);
    }

    function test_shake_moves_the_field_and_returns_it() {
        const field = createField();
        field.shake();
        verify(field.shaking);
        tryVerify(() => field.shakeOffset !== 0, 300);
        tryVerify(() => !field.shaking, 1500);
        compare(field.shakeOffset, 0);
    }

    function test_typed_reports_each_typed_character_with_its_modifiers() {
        const field = createField();
        const spy = createTemporaryObject(typedSpyComponent, this, {
            target: field
        });
        field.forceActiveFocus();
        keyClick("A");
        keyClick("b", Qt.ShiftModifier);
        keyClick(Qt.Key_Left);
        compare(spy.count, 2);
        compare(spy.signalArguments[0][0], "A");
        compare(spy.signalArguments[0][1], Qt.NoModifier);
        compare(spy.signalArguments[1][0], "b");
        compare(spy.signalArguments[1][1], Qt.ShiftModifier);
        compare(field.text, "Ab");
    }

    function test_password_field_states_can_be_set_through_properties() {
        const field = createField({
            hoverActive: true
        });
        compare(field.fillColor, Theme.surfaceOverlay);
        field.down = true;
        compare(field.shadow, Theme.shadowRaised);
        field.down = false;
        field.ringShown = true;
        verify(!field.activeFocus);
    }
}
