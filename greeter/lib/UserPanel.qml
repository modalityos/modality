pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Modality.Theme
import Modality.Controls

// Choose a user: a frosted panel on the scrim, one cell per user. Arrows move, Enter picks,
// Esc, Cancel or a click outside closes with no change.
FocusScope {
    id: panel

    property bool open: false
    // The Greeter backend's users, and the name of the one shown now.
    property var users: []
    property string currentUser
    property url defaultAvatar
    // The wallpaper the Glass blurs.
    property Item backdrop

    readonly property int columns: Math.max(1, Math.min(users.length, 4))
    readonly property real radius: Theme.radiusPanel

    signal picked(string name)
    signal cancelled

    // Arrows move by one cell; up and down move by a row. Off the grid, focus stays.
    function moveFocus(from, step) {
        const cell = cells.itemAt(from + step);
        if (from + step >= 0 && cell)
            cell.forceActiveFocus();
    }

    function focusCurrentUser() {
        const index = Math.max(0, users.findIndex(user => user.name === currentUser));
        cells.itemAt(index)?.forceActiveFocus();
    }

    visible: open || opacity > 0
    opacity: open ? 1 : 0
    onOpenChanged: {
        if (open)
            Qt.callLater(focusCurrentUser);
    }

    Behavior on opacity {
        OpacityAnimator {
            duration: Theme.motionDurationNormal
            easing.type: Easing.Bezier
            easing.bezierCurve: panel.open ? Theme.motionEasingOut : Theme.motionEasingIn
        }
    }

    Keys.onEscapePressed: panel.cancelled()

    Rectangle {
        anchors.fill: parent
        color: Theme.scrim

        MouseArea {
            anchors.fill: parent
            onClicked: panel.cancelled()
        }
    }

    Item {
        id: card

        anchors.centerIn: parent
        // Raw width from the design.
        width: 640
        height: layout.implicitHeight + 2 * Theme.space6
        scale: panel.open ? 1 : 0.98

        Behavior on scale {
            ScaleAnimator {
                duration: Theme.motionDurationNormal
                easing.type: Easing.Bezier
                easing.bezierCurve: panel.open ? Theme.motionEasingOut : Theme.motionEasingIn
            }
        }

        // Clicks on the card do not reach the scrim.
        MouseArea {
            anchors.fill: parent
        }

        Shadow {
            anchors.fill: parent
            token: Theme.shadowModal
            radius: panel.radius
        }

        Frost {
            anchors.fill: parent
            source: panel.backdrop
            radius: panel.radius
        }

        Glass {
            anchors.fill: parent
            radius: panel.radius
        }

        ColumnLayout {
            id: layout

            anchors.fill: parent
            anchors.margins: Theme.space6
            spacing: Theme.space5

            Text {
                objectName: "userPanelTitle"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: qsTr("Choose a user")
                font: Theme.title2.font
                lineHeight: Theme.title2.lineHeight
                lineHeightMode: Text.FixedHeight
                color: Theme.textPrimary
            }

            GridLayout {
                id: grid

                objectName: "userGrid"
                Layout.fillWidth: true
                columns: panel.columns
                rowSpacing: 20
                columnSpacing: Theme.space3

                Repeater {
                    id: cells

                    model: panel.users

                    UserCell {
                        required property var modelData
                        required property int index

                        objectName: `userCell${index}`
                        Layout.fillWidth: true
                        Layout.preferredWidth: (grid.width - (panel.columns - 1) * grid.columnSpacing) / panel.columns
                        Layout.alignment: Qt.AlignTop
                        user: modelData
                        defaultAvatar: panel.defaultAvatar
                        onClicked: panel.picked(modelData.name)

                        Keys.onLeftPressed: panel.moveFocus(index, -1)
                        Keys.onRightPressed: panel.moveFocus(index, 1)
                        Keys.onUpPressed: panel.moveFocus(index, -panel.columns)
                        Keys.onDownPressed: panel.moveFocus(index, panel.columns)
                    }
                }
            }

            Button {
                objectName: "userPanelCancel"
                Layout.alignment: Qt.AlignHCenter
                variant: Button.Secondary
                text: qsTr("Cancel")
                onClicked: panel.cancelled()
            }
        }
    }
}
