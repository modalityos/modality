import QtQuick
import Quickshell
import "lib"

// The Greeter's Quickshell config. Cage has no layer-shell, so the Greeter is one
// FloatingWindow; Cage runs with -m last and fills its one output with it (ADR 0001).
ShellRoot {
    FloatingWindow {
        title: qsTr("ModalityOS Greeter")
        visible: true
        color: "black"

        Greeter {
            objectName: "greeter"
            anchors.fill: parent
            backend: RealBackend {
                prefix: Quickshell.env("MODALITYOS_PREFIX") || "/usr"
            }
        }
    }
}
