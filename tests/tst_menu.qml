import QtQuick
import QtTest
import Modality.Theme
import Modality.Controls

TestCase {
    name: "Menu"
    width: 400
    height: 300
    visible: true
    when: windowShown

    Component {
        id: menuComponent

        Menu {
            x: 20
            y: 20
            title: "Session"
            model: [
                {
                    text: "KWin",
                    checked: true
                },
                {
                    text: "Hyprland"
                },
                {
                    text: "Sway",
                    enabled: false
                }
            ]
        }
    }

    Component {
        id: menuItemComponent

        MenuItem {
            x: 20
            y: 20
            width: 180
            text: "Hyprland"
        }
    }

    SignalSpy {
        id: triggeredSpy

        signalName: "triggered"
    }

    SignalSpy {
        id: dismissedSpy

        signalName: "dismissed"
    }

    function createMenu() {
        const menu = createTemporaryObject(menuComponent, this);
        verify(menu);
        triggeredSpy.target = menu;
        dismissedSpy.target = menu;
        return menu;
    }

    function createMenuItem(properties) {
        const item = createTemporaryObject(menuItemComponent, this, properties ?? {});
        verify(item);
        return item;
    }

    function cleanup() {
        triggeredSpy.clear();
        dismissedSpy.clear();
    }

    function test_menu_item_default_is_transparent_with_primary_text() {
        const item = createMenuItem();
        compare(item.fillColor, Qt.color("transparent"));
        compare(item.labelColor, Theme.textPrimary);
        compare(item.height, Theme.rowHeight);
        compare(item.radius, Theme.radiusSmall);
        compare(item.font.pixelSize, Theme.body.font.pixelSize);
        verify(!item.ringShown);
    }

    function test_menu_item_hover_is_accent() {
        const item = createMenuItem();
        mouseMove(item, 20, item.height / 2);
        tryVerify(() => item.hovered);
        compare(item.fillColor, Theme.accent);
        compare(item.labelColor, Theme.onAccent);
    }

    function test_menu_item_pressed_is_accent_pressed() {
        const item = createMenuItem();
        mousePress(item, 20, item.height / 2);
        compare(item.fillColor, Theme.accentPressed);
        compare(item.labelColor, Theme.onAccent);
        mouseRelease(item, 20, item.height / 2);
    }

    function test_menu_item_focused_is_transparent_with_the_ring() {
        const item = createMenuItem();
        item.forceActiveFocus();
        verify(item.ringShown);
        compare(item.fillColor, Qt.color("transparent"));
    }

    function test_menu_item_disabled_has_disabled_text() {
        const item = createMenuItem({
            enabled: false
        });
        compare(item.fillColor, Qt.color("transparent"));
        compare(item.labelColor, Theme.textDisabled);
    }

    function test_unchecked_menu_item_label_lines_up_with_checked_ones() {
        const plain = createMenuItem();
        const checked = createMenuItem({
            checked: true,
            y: 60
        });
        compare(plain.leftPadding, 30);
        compare(checked.leftPadding, 10);
        compare(checked.indicatorWidth + checked.spacing + checked.leftPadding, 30);
    }

    function test_menu_is_closed_until_opened() {
        const menu = createMenu();
        verify(!menu.opened);
        verify(!menu.visible);
        menu.open();
        verify(menu.opened);
        tryCompare(menu, "visible", true);
        compare(menu.shadow, Theme.shadowFloating);
        compare(menu.width, 220);
    }

    function test_opening_focuses_the_checked_item() {
        const menu = createMenu();
        menu.open();
        compare(menu.currentIndex, 0);
        verify(menu.itemAt(0).activeFocus);
    }

    function test_arrows_move_the_highlight_and_enter_picks() {
        const menu = createMenu();
        menu.open();
        keyClick(Qt.Key_Down);
        compare(menu.currentIndex, 1);
        verify(menu.itemAt(1).activeFocus);
        keyClick(Qt.Key_Return);
        compare(triggeredSpy.count, 1);
        compare(triggeredSpy.signalArguments[0][0], 1);
        verify(!menu.opened);
    }

    function test_arrows_skip_disabled_items_and_stop_at_the_ends() {
        const menu = createMenu();
        menu.open();
        keyClick(Qt.Key_Down);
        keyClick(Qt.Key_Down);
        compare(menu.currentIndex, 1);
        keyClick(Qt.Key_Up);
        keyClick(Qt.Key_Up);
        compare(menu.currentIndex, 0);
    }

    function test_clicking_an_item_reports_it() {
        const menu = createMenu();
        menu.open();
        tryCompare(menu, "opacity", 1);
        const item = menu.itemAt(1);
        mouseClick(item);
        compare(triggeredSpy.count, 1);
        compare(triggeredSpy.signalArguments[0][0], 1);
    }

    function test_escape_closes_the_menu_without_a_choice() {
        const menu = createMenu();
        menu.open();
        keyClick(Qt.Key_Escape);
        verify(!menu.opened);
        compare(dismissedSpy.count, 1);
        compare(triggeredSpy.count, 0);
        tryCompare(menu, "visible", false);
    }

    function test_menu_heading_is_footnote_strong_secondary() {
        const menu = createMenu();
        compare(menu.titleFont.weight, Theme.footnoteStrong.font.weight);
        compare(menu.titleFont.pixelSize, Theme.footnoteStrong.font.pixelSize);
        compare(menu.titleColor, Theme.textSecondary);
    }

    function test_menu_item_states_can_be_set_through_properties() {
        const item = createMenuItem({
            hoverActive: true
        });
        compare(item.fillColor, Theme.accent);
        item.down = true;
        compare(item.fillColor, Theme.accentPressed);
        item.down = false;
        item.ringShown = true;
        verify(!item.activeFocus);
    }
}
