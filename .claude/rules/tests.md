---
paths:
  - "tests/**"
---

# Writing tests

Run: `just test`, `just test-one tests/tst_<name>.qml`; `just check` before pushing. Each `.qml` and `.js` under `greeter/` and `qml/Modality/` must be loaded by some test (`just coverage`).

## Seam 1: the Greeter with `FakeBackend`

- `import "helpers"` and `import "../greeter/lib"`; create `FakeBackend {}` then `Greeter { backend: ... }` with `createTemporaryObject`. Pass backend properties (`users`, `sessions`, `lastUser`, settings) at creation.
- Each operation the screen calls is recorded in `backend.calls` as `[name, ...args]`; `backend.lastCall()` gives the latest.
- Play greetd by emitting backend signals: `backend.authPrompt("Password:", true)`, `authFailure(msg)`, `authError(msg)`, `readyToLaunch()`, `launched()`, `error(msg)`, `loginUnavailable()`.
- Its wallpapers are the PNGs in `fixtures/wallpapers/`.

## Seam 2: the real backend with Quickshell stubs

- `tests/stubs/Quickshell/` stubs `Quickshell` (`Quickshell.environment = {...}` feeds `env()`), `ShellRoot`, `FloatingWindow`, `Process`, `StdioCollector`, `FileView` and `Greetd`.
- `Greetd` records calls in `Greetd.calls` / `Greetd.lastCall()`; emit its signals (`authMessage`, `authFailure`, `readyToLaunch`, `launched`, `error`) to drive a conversation.
- Stub `Process`es never run. `import QuickshellStubs`, then `Processes.find("<part of its command>")` and `Processes.finish(process, output, exitCode)`.
- Stub `FileView`s use `Files`: `Files.write(path, text)` seeds a file, `Files.read(path)` reads what was written.

## Resets

Singletons outlive a test. Reset in `init()`: `Greetd.reset()`, `Files.reset()`. Reset in `cleanup()` whatever a test changed on `Theme` (`Theme.theme = "dark"`, `Theme.reduceTransparency = false`) and `Quickshell.environment = {}`.

## Fixtures

Small files go in `tests/fixtures/`; load them with `Qt.resolvedUrl("fixtures/...")`.

## The kit rule

Reuse and extend `tests/stubs/`, `tests/helpers/` and `tests/fixtures/` instead of one-off stubs. Record each addition here and in `docs/testing.md` (The shared test kit).
