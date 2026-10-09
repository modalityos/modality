import QtQuick
import QtQuick.Layouts
import Modality.Theme
import Modality.Controls

// The shown user: Avatar, name and password field, centred above the power row.
ColumnLayout {
    id: column

    // One entry of the Greeter backend's users.
    property var user: null
    property url defaultAvatar
    property alias passwordField: passwordField
    // The wallpaper the Glass elements blur.
    property Item backdrop

    spacing: Theme.space3

    UserAvatar {
        objectName: "userAvatar"
        Layout.alignment: Qt.AlignHCenter
        user: column.user
        fallback: column.defaultAvatar
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
}
