pragma Singleton
import QtQuick

// Stub of Quickshell's Greetd: records each call in calls; tests emit its signals.
// A singleton keeps state between tests, so call reset() in init().
QtObject {
    property bool available: true
    property string user: ""
    property var calls: []

    signal authMessage(string message, bool error, bool responseRequired, bool echoResponse)
    signal authFailure(string message)
    signal readyToLaunch
    signal launched
    signal error(string error)

    function reset() {
        available = true;
        user = "";
        calls = [];
    }

    function record(call) {
        calls = calls.concat([call]);
    }

    function lastCall() {
        return calls.length > 0 ? calls[calls.length - 1] : [];
    }

    function createSession(user) {
        record(["createSession", user]);
    }

    function respond(response) {
        record(["respond", response]);
    }

    function cancelSession() {
        record(["cancelSession"]);
    }

    function launch(command, environment, quit) {
        record(["launch", command, environment, quit]);
    }
}
