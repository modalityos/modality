pragma ComponentBehavior: Bound
import QtQuick
import Modality.Theme

// A Glass menu of choices under a small heading. model is a list of { text, checked, enabled }.
// Up and Down move the highlight, Enter or a click picks (triggered), Esc closes (dismissed).
// Tab and Shift+Tab move like Down and Up, so focus stays inside the open Menu.
FocusScope {
    id: menu

    property string title
    property var model: []
    property int currentIndex: 0
    property bool opened: false

    readonly property var shadow: Theme.shadowFloating
    readonly property real radius: Theme.radiusCard
    readonly property font titleFont: Theme.footnoteStrong.font
    readonly property color titleColor: Theme.textSecondary

    signal triggered(int index)
    signal dismissed

    function itemAt(index) {
        return repeater.itemAt(index);
    }

    function open() {
        currentIndex = firstIndex();
        opened = true;
        closeAnimation.stop();
        openAnimation.restart();
        itemAt(currentIndex)?.forceActiveFocus();
    }

    function close() {
        if (!opened)
            return;
        opened = false;
        openAnimation.stop();
        closeAnimation.restart();
    }

    function isPickable(index) {
        const entry = model[index];
        return entry !== undefined && entry.enabled !== false;
    }

    function firstIndex() {
        const checked = model.findIndex((entry, index) => entry.checked && isPickable(index));
        if (checked >= 0)
            return checked;
        return model.findIndex((entry, index) => isPickable(index));
    }

    function move(step) {
        for (let index = currentIndex + step; index >= 0 && index < model.length; index += step) {
            if (isPickable(index)) {
                currentIndex = index;
                itemAt(index).forceActiveFocus();
                return;
            }
        }
    }

    // Raw sizes from the design: 220px wide, 4px padding, 2px between items.
    implicitWidth: 220
    implicitHeight: column.implicitHeight + 8
    visible: opened || closeAnimation.running
    opacity: 0
    transform: Translate {
        id: slide
    }

    Keys.onUpPressed: move(-1)
    Keys.onDownPressed: move(1)
    Keys.onEscapePressed: {
        close();
        dismissed();
    }

    Shadow {
        anchors.fill: parent
        token: menu.shadow
        radius: menu.radius
    }

    Glass {
        anchors.fill: parent
        radius: menu.radius
    }

    Column {
        id: column

        anchors.fill: parent
        anchors.margins: 4
        spacing: 2

        Text {
            width: parent.width
            visible: menu.title.length > 0
            text: menu.title
            font: menu.titleFont
            color: menu.titleColor
            topPadding: 6
            bottomPadding: 4
            leftPadding: 10
            rightPadding: 10
            Accessible.role: Accessible.Heading
        }

        Repeater {
            id: repeater

            model: menu.model

            MenuItem {
                id: menuItem

                required property var modelData
                required property int index

                width: column.width
                text: menuItem.modelData.text
                checked: menuItem.modelData.checked === true
                enabled: menuItem.modelData.enabled !== false
                // On the item: a focused item would take Tab itself before the Menu saw it.
                Keys.onTabPressed: menu.move(1)
                Keys.onBacktabPressed: menu.move(-1)
                onClicked: {
                    menu.close();
                    menu.triggered(menuItem.index);
                }
            }
        }
    }

    ParallelAnimation {
        id: openAnimation

        OpacityAnimator {
            target: menu
            to: 1
            duration: Theme.motionDurationNormal
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.motionEasingOut
        }

        NumberAnimation {
            target: slide
            property: "y"
            from: 4
            to: 0
            duration: Theme.motionDurationNormal
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.motionEasingOut
        }
    }

    ParallelAnimation {
        id: closeAnimation

        OpacityAnimator {
            target: menu
            to: 0
            duration: Theme.motionDurationNormal
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.motionEasingIn
        }

        NumberAnimation {
            target: slide
            property: "y"
            to: 4
            duration: Theme.motionDurationNormal
            easing.type: Easing.Bezier
            easing.bezierCurve: Theme.motionEasingIn
        }
    }
}
