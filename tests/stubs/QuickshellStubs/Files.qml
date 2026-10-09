pragma Singleton
import QtQuick

// A fake filesystem for the FileView stub: file text by path. Reset it in init(), since
// singletons outlive a test.
QtObject {
    property var contents: ({})

    function reset() {
        contents = {};
    }

    function write(path, text) {
        const next = Object.assign({}, contents);
        next[path] = text;
        contents = next;
    }

    function read(path) {
        return contents[path];
    }
}
