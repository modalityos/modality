import QtQuick
import QuickshellStubs

// Stub of Quickshell's FileView over Files, a fake filesystem: text() is "" for a missing
// file, as the real one's is, and setText() writes the file at once.
QtObject {
    property string path
    property bool preload: true
    property bool blockLoading: false
    property bool blockAllReads: false
    property bool blockWrites: false
    property bool atomicWrites: true
    property bool printErrors: true
    property bool watchChanges: false

    signal loaded
    signal loadFailed(int error)
    signal saved
    signal saveFailed(int error)
    signal fileChanged

    // Reading Files.contents keeps a binding on text() live, as with the real FileView.
    function text() {
        return Files.contents[path] ?? "";
    }

    function setText(text) {
        Files.write(path, text);
        saved();
    }

    function reload() {
    }
}
