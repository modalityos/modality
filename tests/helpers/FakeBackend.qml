import QtQuick
import "../../greeter/lib"

// A Greeter backend for tests: records every operation in calls; tests emit its events.
GreeterBackend {
    property var calls: []

    function lastCall() {
        return calls.length > 0 ? calls[calls.length - 1] : [];
    }

    function record(call) {
        calls = calls.concat([call]);
    }

    users: [
        {
            name: "katherine",
            realName: "Katherine Johnson",
            avatar: "",
            systemAccount: false
        }
    ]
    lastUser: "katherine"
    sessions: [
        {
            id: "org.modalityos.kwin",
            name: "ModalityOS (KWin)",
            command: ["/opt/modalityos/bin/modalityos-session-kwin"],
            desktopNames: ["ModalityOS"]
        }
    ]
    defaultSession: "org.modalityos.kwin"
    wallpaperFolder: Qt.resolvedUrl("../fixtures/wallpapers")
    defaultAvatar: Qt.resolvedUrl("../../data/avatars/avatar-cat.png")

    function startAuthentication(user) {
        record(["startAuthentication", user]);
    }

    function answer(response) {
        record(["answer", response]);
    }

    function cancel() {
        record(["cancel"]);
    }

    function launch(session) {
        record(["launch", session.id]);
    }

    function remember(user, sessionId) {
        record(["remember", user, sessionId]);
    }

    function suspend() {
        record(["suspend"]);
    }

    function reboot() {
        record(["reboot"]);
    }

    function powerOff() {
        record(["powerOff"]);
    }
}
