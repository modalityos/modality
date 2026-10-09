import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import Modality.Theme
import Modality.Controls

// One user in the Choose a user panel: small Avatar over the name. Highlighted while it
// has keyboard focus.
T.AbstractButton {
    id: cell

    // One entry of the Greeter backend's users.
    property var user: null
    property url defaultAvatar

    // Raw sizes from the design: 64px Avatar, 10px top and bottom padding.
    readonly property int avatarSize: 64
    readonly property bool highlighted: activeFocus

    text: user?.realName || user?.name || ""
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: implicitContentHeight + topPadding + bottomPadding
    topPadding: 10
    bottomPadding: 10
    leftPadding: Theme.space1
    rightPadding: Theme.space1
    focusPolicy: Qt.StrongFocus
    font: Theme.footnoteMedium.font
    Accessible.role: Accessible.Button
    Accessible.name: text

    Keys.onReturnPressed: clicked()
    Keys.onEnterPressed: clicked()

    contentItem: ColumnLayout {
        spacing: Theme.space2

        UserAvatar {
            Layout.alignment: Qt.AlignHCenter
            size: cell.avatarSize
            hoverEnabled: false
            user: cell.user
            fallback: cell.defaultAvatar
            onClicked: cell.clicked()
        }

        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: cell.text
            font: cell.font
            lineHeight: Theme.footnoteMedium.lineHeight
            lineHeightMode: Text.FixedHeight
            color: Theme.textPrimary
        }
    }

    background: Rectangle {
        radius: Theme.radiusCard
        color: cell.highlighted ? Theme.fillStrong : "transparent"

        FocusRing {
            anchors.fill: parent
            radius: parent.radius
            shown: cell.highlighted
        }
    }
}
