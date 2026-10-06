# Coding standards

Checked by `/code-review` on every branch.

- **Rust:** clean under `cargo clippy --all-targets --all-features --locked -- -D warnings`. No `#[allow(...)]` without a one-line reason; prefer `#[expect(...)]`. Follow the `rust-best-practices` skill.
- **QML:** follow the `qt-qml` skill. Logic lives in plain QML/JS outside the thin Quickshell layer, so it can be tested.
- **Comments:** 1–2 lines of prose explaining why, not what. No investigation history, dates, or "per review" notes; that goes in the commit or PR.
- **Tests:** named after the behaviour they check, using terms from `GLOSSARY.md`.
