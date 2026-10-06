# Quickshell only for the Shell and the Greeter

The Shell and the Greeter are Quickshell configs; Apps (Settings, Files and the rest) are ordinary Qt 6 programs with QML UIs and Rust logic bridged by CXX-Qt, and never import Quickshell modules. Quickshell's modules only exist inside its own runtime, and Apps need to be normal launchable programs with their own windows. Shell and Apps stay in sync by being clients of the same system daemons, not by sharing code.

## Consequences

- Some services exist twice: Quickshell's own module for the Shell, and a `Modality.*` module for Apps (Bluetooth, Network, Audio, Power and others).
- Pure-QML modules such as `Modality.Controls` are shared by both; Rust-backed `Modality.*` modules are compiled into each App and are not available to the Shell.
