import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import Modality.Theme

// The Greeter's password pill: hidden text, an arrow button that submits, a spinner while busy.
// Enter or the arrow submits a non-empty password; Esc clears it.
FocusScope {
    id: control

    property alias text: input.text
    property string placeholderText: qsTr("Enter password")
    // Checking: dimmed, ring hidden and input ignored, while focus is held.
    property bool busy: false

    readonly property int echoMode: input.echoMode
    readonly property real radius: height / 2
    readonly property bool hovered: hoverHandler.hovered
    readonly property bool pressed: tapHandler.pressed
    readonly property bool interactive: enabled && !busy
    // Default to the live input state; set them to show a state without input.
    property bool hoverActive: hovered
    property bool down: pressed
    property bool ringShown: activeFocus && !busy
    readonly property color fillColor: interactive && (hoverActive || down) ? Theme.surfaceOverlay : Theme.materialPopover
    readonly property var shadow: !enabled ? null : interactive && down ? Theme.shadowRaised : Theme.shadowFloating
    readonly property real visualOpacity: !enabled ? 0.5 : busy ? 0.7 : 1
    readonly property real shakeOffset: shakeTranslate.x
    readonly property bool shaking: shakeAnimation.running

    signal submitted(string password)
    // A key typed text into the field; the Greeter infers Caps Lock from it.
    signal typed(string text, int modifiers)

    function submit() {
        if (interactive && input.text.length > 0)
            submitted(input.text);
    }

    // The wrong-password shake; the caller clears the field when shaking ends.
    function shake() {
        shakeAnimation.restart();
    }

    implicitWidth: 240
    implicitHeight: Theme.controlHeightLarge
    activeFocusOnTab: true
    opacity: visualOpacity
    transform: Translate {
        id: shakeTranslate
    }

    HoverHandler {
        id: hoverHandler
    }

    // Taps on the padding focus the input too.
    TapHandler {
        onTapped: input.forceActiveFocus()
    }

    Shadow {
        anchors.fill: parent
        token: control.shadow
        radius: control.radius
    }

    Glass {
        anchors.fill: parent
        radius: control.radius
        color: control.fillColor
        frosted: !control.interactive || !(control.hoverActive || control.down)

        Behavior on color {
            FastColorAnimation {}
        }
    }

    RowLayout {
        anchors.fill: parent
        // Right 4px centres the 24px submit button in the 32px pill.
        anchors.leftMargin: Theme.space4
        anchors.rightMargin: 4
        spacing: Theme.space2

        TextInput {
            id: input

            Layout.fillWidth: true
            Layout.fillHeight: true
            focus: true
            echoMode: TextInput.Password
            readOnly: control.busy
            verticalAlignment: TextInput.AlignVCenter
            clip: true
            font: Theme.body.font
            color: Theme.textPrimary
            selectionColor: Theme.accent
            selectedTextColor: Theme.onAccent
            Accessible.role: Accessible.EditableText
            Accessible.name: qsTr("Password")
            Accessible.passwordEdit: true

            // On the input, so it sees the press before TextInput takes it.
            TapHandler {
                id: tapHandler
            }

            Keys.onPressed: event => {
                if (control.interactive && event.text.length > 0 && event.text.charCodeAt(0) >= 0x20)
                    control.typed(event.text, event.modifiers);
                event.accepted = false;
            }
            Keys.onReturnPressed: control.submit()
            Keys.onEnterPressed: control.submit()
            Keys.onEscapePressed: {
                if (control.interactive)
                    input.clear();
            }

            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                visible: input.text.length === 0 && input.preeditText.length === 0
                text: control.placeholderText
                font: Theme.body.font
                color: Theme.textTertiary
                elide: Text.ElideRight
                Accessible.ignored: true
            }
        }

        Item {
            Layout.preferredWidth: Theme.controlHeightSmall
            Layout.preferredHeight: Theme.controlHeightSmall

            T.AbstractButton {
                anchors.fill: parent
                visible: !control.busy
                focusPolicy: Qt.NoFocus
                Accessible.role: Accessible.Button
                Accessible.name: qsTr("Log in")
                onClicked: control.submit()

                background: Rectangle {
                    radius: width / 2
                    color: Theme.accent
                }

                contentItem: Item {
                    Icon {
                        anchors.centerIn: parent
                        glyph: Glyphs.submit
                        color: Theme.onAccent
                    }
                }
            }

            Spinner {
                anchors.centerIn: parent
                running: control.busy
                visible: control.busy
            }
        }
    }

    FocusRing {
        anchors.fill: parent
        radius: control.radius
        shown: control.ringShown
    }

    // Keyframes 0, -8, 8, -6, 4, 0 px over 2 x motionDurationSlow, spring easing per segment.
    SequentialAnimation {
        id: shakeAnimation

        ShakeStep {
            target: shakeTranslate
            to: -8
        }

        ShakeStep {
            target: shakeTranslate
            to: 8
        }

        ShakeStep {
            target: shakeTranslate
            to: -6
        }

        ShakeStep {
            target: shakeTranslate
            to: 4
        }

        ShakeStep {
            target: shakeTranslate
            to: 0
        }
    }

    component ShakeStep: NumberAnimation {
        property: "x"
        duration: Theme.motionDurationSlow * 2 / 5
        easing.type: Easing.Bezier
        easing.bezierCurve: Theme.motionEasingSpring
    }
}
