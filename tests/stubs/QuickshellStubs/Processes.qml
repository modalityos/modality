pragma Singleton
import QtQuick

// Every live stub Process, so tests can reach the processes a backend declares.
QtObject {
    property var all: []

    function add(process) {
        all = all.concat([process]);
    }

    function remove(process) {
        all = all.filter(other => other !== process);
    }

    // The first live process whose command line contains text.
    function find(text) {
        return all.find(process => process.command.join(" ").includes(text)) ?? null;
    }

    // Finish a process: its stdout collector gets text, then the process exits.
    function finish(process, text, exitCode) {
        process.stdout.text = text;
        process.stdout.streamFinished();
        process.running = false;
        process.exited(exitCode ?? 0, 0);
    }
}
