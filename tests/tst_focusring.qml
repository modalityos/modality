import QtQuick
import QtTest
import Modality.Theme
import Modality.Controls

TestCase {
    name: "FocusRing"
    width: 200
    height: 100
    visible: true
    when: windowShown

    Component {
        id: ringComponent

        Item {
            property alias ring: ring

            x: 20
            y: 20
            width: 100
            height: 28

            FocusRing {
                id: ring

                anchors.fill: parent
                radius: 14
                shown: true
            }
        }
    }

    function cleanup() {
        Theme.theme = "dark";
    }

    function test_focus_ring_is_a_surface_halo_then_the_focus_ring() {
        const ring = createTemporaryObject(ringComponent, this).ring;
        compare(ring.haloColor, Theme.materialPopoverFallback);
        compare(ring.haloWidth, 2);
        compare(ring.ringColor, Theme.focusRing);
        compare(ring.ringWidth, 3);
    }

    function test_focus_ring_sits_outside_the_element_by_offset_plus_width() {
        const ring = createTemporaryObject(ringComponent, this).ring;
        compare(ring.childrenRect.x, -5);
        compare(ring.childrenRect.y, -5);
        compare(ring.childrenRect.width, 110);
        compare(ring.childrenRect.height, 38);
    }

    function test_focus_ring_hidden_when_not_shown() {
        const ring = createTemporaryObject(ringComponent, this).ring;
        ring.shown = false;
        verify(!ring.visible);
    }

    function test_focus_ring_follows_the_light_theme() {
        const ring = createTemporaryObject(ringComponent, this).ring;
        Theme.theme = "light";
        compare(ring.ringColor, Qt.color("#1c6ee8"));
        compare(ring.haloColor, Qt.color("#fbfbfa"));
    }
}
