import QtQuick
import QtTest
import Modality.Theme
import Modality.Controls

TestCase {
    name: "Avatar"
    width: 300
    height: 200
    visible: true
    when: windowShown

    Component {
        id: avatarComponent

        Avatar {
            x: 40
            y: 40
            name: "John Doe"
            source: Qt.resolvedUrl("../data/avatars/avatar-cat.png")
        }
    }

    function createAvatar(properties) {
        const avatar = createTemporaryObject(avatarComponent, this, properties ?? {});
        verify(avatar);
        return avatar;
    }

    function test_avatar_is_large_by_default_and_round() {
        const avatar = createAvatar();
        compare(avatar.width, Theme.avatarSizeLarge);
        compare(avatar.height, Theme.avatarSizeLarge);
        compare(avatar.radius, Theme.avatarSizeLarge / 2);
    }

    function test_small_avatar_takes_its_size() {
        const avatar = createAvatar({ size: 64 });
        compare(avatar.width, 64);
        compare(avatar.radius, 32);
    }

    function test_avatar_loads_its_image() {
        const avatar = createAvatar();
        tryCompare(avatar, "status", Image.Ready);
    }

    function test_avatar_default_has_floating_shadow() {
        const avatar = createAvatar({ size: 64 });
        compare(avatar.shadow, Theme.shadowFloating);
        compare(avatar.visualScale, 1);
        compare(avatar.visualOpacity, 1);
        verify(!avatar.ringShown);
    }

    function test_avatar_hover_lifts_to_modal_shadow_and_grows() {
        const avatar = createAvatar({ size: 64 });
        mouseMove(avatar, 32, 32);
        tryVerify(() => avatar.hovered);
        compare(avatar.shadow, Theme.shadowModal);
        compare(avatar.visualScale, 1.04);
    }

    function test_avatar_pressed_drops_to_raised_shadow_and_shrinks() {
        const avatar = createAvatar({ size: 64 });
        mousePress(avatar, 32, 32);
        verify(avatar.pressed);
        compare(avatar.shadow, Theme.shadowRaised);
        compare(avatar.visualScale, 0.96);
        mouseRelease(avatar, 32, 32);
    }

    function test_avatar_is_not_focusable_unless_asked() {
        const avatar = createAvatar();
        compare(avatar.focusPolicy, Qt.NoFocus);
    }

    function test_focused_avatar_shows_the_ring_with_floating_shadow() {
        const avatar = createAvatar({ size: 64, focusPolicy: Qt.StrongFocus });
        avatar.forceActiveFocus();
        verify(avatar.ringShown);
        compare(avatar.shadow, Theme.shadowFloating);
    }

    function test_disabled_avatar_fades_without_shadow() {
        const avatar = createAvatar({ size: 64, enabled: false });
        compare(avatar.visualOpacity, 0.4);
        compare(avatar.shadow, null);
    }

    function test_avatar_is_named_after_its_user() {
        const avatar = createAvatar();
        compare(avatar.Accessible.name, "John Doe");
    }
}
