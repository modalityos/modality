# Each service is a pure Rust crate plus a thin QML wrapper crate

Every service is split in two: a pure crate (`modalityos-<name>`) with all the logic and no Qt dependency, and a wrapper crate (`modalityos-<name>-qml`) that only converts types, mirrors state into properties and moves work between the async runtime and the Qt thread. Daemons and the CLI can then use services without building Qt, and logic is testable with `cargo test` alone. Dependencies only point downward: Apps → `-qml` crates → pure crates → `modalityos-core`; daemons and CLI → pure crates.

## Consequences

- Domain logic found in a `-qml` crate is in the wrong layer; a pure crate that needs Qt is in the wrong layer.
- Wrapper invokables ask the underlying daemon to change state and update properties only from its change events, so state always reflects the daemon, including changes made by the Shell or another App.
