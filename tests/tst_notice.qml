import QtQuick
import QtTest
import Modality.Theme
import Modality.Controls

TestCase {
    name: "Notice"
    width: 400
    height: 200
    visible: true
    when: windowShown

    Component {
        id: noticeComponent

        Notice {
            x: 20
            y: 20
            text: "Caps Lock is on"
        }
    }

    SignalSpy {
        id: actionSpy

        signalName: "actionTriggered"
    }

    function createNotice(properties) {
        const notice = createTemporaryObject(noticeComponent, this, properties ?? {});
        verify(notice);
        return notice;
    }

    function cleanup() {
        actionSpy.clear();
        Theme.theme = "dark";
        Theme.reduceTransparency = false;
    }

    function test_warning_notice_is_in_the_warning_colour() {
        const notice = createNotice({
            tone: Notice.Warning,
            glyph: Glyphs.capsLock
        });
        compare(notice.toneColor, Theme.warning);
    }

    function test_danger_notice_is_in_the_danger_colour() {
        const notice = createNotice({
            tone: Notice.Danger,
            text: "Wrong password",
            glyph: Glyphs.cross
        });
        compare(notice.toneColor, Theme.danger);
    }

    function test_notice_tones_follow_the_light_theme() {
        const notice = createNotice({
            tone: Notice.Danger
        });
        Theme.theme = "light";
        compare(notice.toneColor, Qt.color("#a8231f"));
        notice.tone = Notice.Warning;
        compare(notice.toneColor, Qt.color("#7a4e00"));
    }

    function test_notice_is_a_glass_pill_without_shadow_in_footnote_medium() {
        const notice = createNotice();
        compare(notice.fillColor, Theme.materialPopoverTint);
        compare(notice.shadow, null);
        compare(notice.radius, notice.height / 2);
        compare(notice.font.pixelSize, Theme.footnoteMedium.font.pixelSize);
        compare(notice.font.weight, Theme.footnoteMedium.font.weight);
        Theme.reduceTransparency = true;
        compare(notice.fillColor, Theme.materialPopoverFallback);
    }

    function test_notice_with_action_floats_and_reports_its_action() {
        const notice = createNotice({
            tone: Notice.Danger,
            text: "Couldn't start the session.",
            actionText: "Try again"
        });
        actionSpy.target = notice;
        compare(notice.shadow, Theme.shadowFloating);
        verify(notice.actionItem.visible);
        compare(notice.actionItem.text, "Try again");
        mouseClick(notice.actionItem);
        compare(actionSpy.count, 1);
    }

    function test_focused_action_runs_on_enter() {
        const notice = createNotice({
            tone: Notice.Danger,
            text: "Couldn't start the session.",
            actionText: "Try again"
        });
        actionSpy.target = notice;
        notice.actionItem.forceActiveFocus();
        verify(notice.actionItem.ringShown);
        keyClick(Qt.Key_Return);
        compare(actionSpy.count, 1);
    }

    function test_notice_without_action_has_no_button() {
        const notice = createNotice();
        verify(!notice.actionItem.visible);
    }
}
