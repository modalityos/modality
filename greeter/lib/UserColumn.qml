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
    }
}
