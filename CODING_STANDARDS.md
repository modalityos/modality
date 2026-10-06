# Coding standards

Checked by `/code-review` on every branch.

- **Rust:** clean under `cargo clippy --all-targets --all-features --locked -- -D warnings`. No `#[allow(...)]` without a one-line reason; prefer `#[expect(...)]`. Follow the `rust-best-practices` skill.
- **QML:** follow the `qt-qml` skill. Logic lives in plain QML/JS outside the thin Quickshell layer, so it can be tested.
- **Comments:** 1–2 lines of prose explaining why, not what. No investigation history, dates, or "per review" notes; that goes in the commit or PR.
- **Tests:** named after the behaviour they check, using terms from `GLOSSARY.md`.
- **Naming:** anything in a shared namespace uses `modalityos`, never `modality`. This is checked against ADR 0004.
  - Crates: `modalityos-<name>`; QML wrapper crates: `modalityos-<name>-qml`; Rust paths: `modalityos_<name>`.
  - Binaries, and filesystem paths such as `/usr/share/modalityos`, `/etc/modalityos` and `~/.config/modalityos`.
  - D-Bus names: `org.modalityos.<Name>`; `.desktop` IDs: `org.modalityos.*`.
  - QML imports only: `Modality.<Name>`.
  - The one exception: the CLI is `modalityctl`.
  - Every crate starts with `publish = false`.
