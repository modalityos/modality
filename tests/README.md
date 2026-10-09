# Tests

QML tests are Qt Quick Test files, `tst_*.qml`, run from the repo root:

```sh
QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qmltestrunner -import qml -import tests/stubs -input tests
```

`-import qml` makes `Modality.Theme` and `Modality.Controls` loadable; `-import tests/stubs` holds Quickshell stubs. One file: `-input tests/tst_button.qml`.

The import rule for the shared modules (Theme imports only Qt; Controls only Qt and Theme) is checked by:

```sh
tests/check-imports.sh
```

## The Greeter

- `tst_greeter.qml` drives the Greeter screen through `helpers/FakeBackend.qml`, a Greeter backend that records each operation in `calls` and whose events a test emits (`backend.authPrompt("Password:", true)`). Its wallpapers are tiny PNGs in `fixtures/wallpapers/`.
- `tst_realbackend.qml` runs the real backend against the stubs in `stubs/Quickshell/`. The `Greetd` stub records calls; reset it in `init()`, since singletons outlive a test. Stub `Process`es never run: find one with `Processes.find("<part of its command>")` (module `QuickshellStubs`) and feed it with `Processes.finish(process, output)`. Stub `FileView`s read and write `Files`, a fake filesystem in the same module: seed a file with `Files.write(path, text)`, read what was written with `Files.read(path)`, and `Files.reset()` in `init()`.
- `tst_power.qml` (seam 1) and `tst_realbackend_power.qml` (seam 2) cover the power row: each button's backend operation, and the `systemctl` command the real backend runs.
- `tst_settings.qml` (seam 1) and `tst_realbackend_settings.qml` (seam 2) cover machine settings: theme, clock, Reduce transparency on screen, and Admin overrides beating Defaults. Tests that set `Theme.reduceTransparency` through a backend reset it in `cleanup()`.
- `tst_keyboard.qml` walks the Tab order and the focus ring; `tst_layout.qml` checks Ready at 1366 × 768.
- `tst_shell.qml` loads `greeter/shell.qml` against stubbed `ShellRoot`, `FloatingWindow` and `Quickshell.env()`.

## Preview

The Control states sheet, every Control in every state:

```sh
/usr/lib/qt6/bin/qml -I qml qml/preview/Controls.qml
```

T switches light and dark; R switches Reduce transparency. Offscreen, the default software renderer skips shader effects (shadows, avatar masks); add `QT_QUICK_BACKEND=rhi QSG_RHI_BACKEND=opengl` to see them.
