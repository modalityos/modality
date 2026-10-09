import QtQuick

// Stub of Quickshell's StdioCollector: a test sets text, then emits streamFinished.
QtObject {
    property string text
    property bool waitForEnd: true

    signal streamFinished
}
