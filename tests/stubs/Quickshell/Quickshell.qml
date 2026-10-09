pragma Singleton
import QtQuick

// Stub of the Quickshell singleton: env() reads environment, which tests set.
QtObject {
    property var environment: ({})

    function env(name) {
        return environment[name];
    }
}
