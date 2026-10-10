pragma Singleton
import QtQuick

// Stroked glyphs from design/greeter-login/spec.md (Assets), as { box, stroke, path, roundCap }.
// Circles are written as two arcs so each glyph is one SVG path.
QtObject {
    readonly property var submit: ({
            box: 12,
            stroke: 1.6,
            path: "M2 6h8M6.5 2.5L10 6l-3.5 3.5"
        })
    readonly property var capsLock: ({
            box: 10,
            stroke: 1.3,
            path: "M5 1L1.5 5H3.5v2.5h3V5h2zM3.5 9h3"
        })
    readonly property var cross: ({
            box: 10,
            stroke: 1.4,
            path: "M2.5 2.5l5 5M7.5 2.5l-5 5"
        })
    readonly property var alert: ({
            box: 16,
            stroke: 1.5,
            path: "M1.5 8a6.5 6.5 0 1 0 13 0a6.5 6.5 0 1 0 -13 0M8 4.5v4.2M8 11v.5"
        })
    readonly property var otherUsers: ({
            box: 12,
            stroke: 1.3,
            path: "M2.7 4a1.8 1.8 0 1 0 3.6 0a1.8 1.8 0 1 0 -3.6 0M1.5 10a3 3 0 0 1 6 0M7 4.5a1.5 1.5 0 1 0 3 0a1.5 1.5 0 1 0 -3 0M8 7.3a2.6 2.6 0 0 1 3 2.7"
        })
    readonly property var check: ({
            box: 12,
            stroke: 1.6,
            path: "M2 6.5l2.5 2.5L10 3"
        })
    readonly property var options: ({
            box: 16,
            stroke: 1.5,
            path: "M5.8 8a2.2 2.2 0 1 0 4.4 0a2.2 2.2 0 1 0 -4.4 0M8 1.5v2M8 12.5v2M1.5 8h2M12.5 8h2M3.4 3.4l1.4 1.4M11.2 11.2l1.4 1.4M3.4 12.6l1.4-1.4M11.2 4.8l1.4-1.4"
        })
    readonly property var sleep: ({
            box: 16,
            stroke: 1.5,
            path: "M12.5 10A5.5 5.5 0 0 1 6 3.5a5.5 5.5 0 1 0 6.5 6.5z"
        })
    readonly property var restart: ({
            box: 16,
            stroke: 1.5,
            path: "M13 8a5 5 0 1 1-1.5-3.6M13 2.5v3h-3"
        })
    readonly property var shutDown: ({
            box: 16,
            stroke: 1.5,
            path: "M8 1.5v6M4.5 3.8a5 5 0 1 0 7 0"
        })
    readonly property var spinnerTrack: ({
            box: 18,
            stroke: 2,
            path: "M2 9a7 7 0 1 0 14 0a7 7 0 1 0 -14 0",
            roundCap: true
        })
    readonly property var spinnerArc: ({
            box: 18,
            stroke: 2,
            path: "M9 2a7 7 0 0 1 7 7",
            roundCap: true
        })
}
