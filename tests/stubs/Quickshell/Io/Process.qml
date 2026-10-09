import QtQuick
import QuickshellStubs

// Stub of Quickshell's Process: never runs anything. It registers itself in Processes,
// so a test can find it by its command and feed its stdout.
QtObject {
    id: process

    property list<string> command
    property bool running: false
    property QtObject stdout

    signal started
    signal exited(int exitCode, int exitStatus)

    Component.onCompleted: Processes.add(process)
    Component.onDestruction: Processes.remove(process)
}
