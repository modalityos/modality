import QtQuick
import QtQuick.Layouts
import Modality.Theme
import Modality.Controls

// The shown user: Avatar, name and password field, centred above the power row.
ColumnLayout {
    id: column

    // One entry of the Greeter backend's users.
    property var user: null
    property alias passwordField: passwordField
    // The wallpaper the Glass elements blur.
    property Item backdrop
    property bool wrongPasswordShown: false
    property bool capsLockShown: false
    property bool sessionFailed: false
    readonly property alias tryAgainButton: sessionFailedNotice.actionItem

    signal retryRequested

    spacing: Theme.space3

    Avatar {
        Layout.alignment: Qt.AlignHCenter
        name: column.user?.realName || column.user?.name || ""
        source: column.user?.avatar ?? ""
    }

    Text {
        objectName: "userName"
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.Wrap
        text: column.user?.realName || column.user?.name || ""
        font: Theme.headline.font
        lineHeight: Theme.headline.lineHeight
        lineHeightMode: Text.FixedHeight
        color: Theme.textPrimary
    }

    PasswordField {
        id: passwordField

        objectName: "passwordField"
        Layout.alignment: Qt.AlignHCenter
        focus: true

        // Beneath the field's own Glass tint.
        Frost {
            objectName: "passwordFrost"
            z: -1
            anchors.fill: parent
            source: column.backdrop
            radius: passwordField.radius
        }
    }

    FadingNotice {
        objectName: "wrongPasswordNotice"
        shown: column.wrongPasswordShown
        tone: Notice.Danger
        glyph: Glyphs.cross
        text: qsTr("Wrong password")
    }

    FadingNotice {
        objectName: "capsLockNotice"
        shown: column.capsLockShown
        tone: Notice.Warning
        glyph: Glyphs.capsLock
        text: qsTr("Caps Lock is on")
    }

    FadingNotice {
        id: sessionFailedNotice

        objectName: "sessionFailedNotice"
        shown: column.sessionFailed
        tone: Notice.Danger
        text: qsTr("Couldn't start the session.")
        actionText: qsTr("Try again")
        onActionTriggered: column.retryRequested()
    }

    // A Notice under the field that fades in and out, over its own frosted wallpaper.
    component FadingNotice: Notice {
        id: notice

        property bool shown: false

        Layout.alignment: Qt.AlignHCenter
        opacity: shown ? 1 : 0
        visible: shown || opacity > 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motionDurationNormal
                easing.type: Easing.Bezier
                easing.bezierCurve: notice.shown ? Theme.motionEasingOut : Theme.motionEasingIn
            }
        }

        Frost {
            z: -1
            anchors.fill: parent
            source: column.backdrop
            radius: notice.radius
        }
    }
}
