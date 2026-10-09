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
- `tst_realbackend.qml` runs the real backend against the stubs in `stubs/Quickshell/`. The `Greetd` stub records calls; reset it in `init()`, since singletons outlive a test. Stub `Process`es never run: find one with `Processes.find("<part of its command>")` (module `QuickshellStubs`) and feed it with `Processes.finish(process, output)`.
- `tst_shell.qml` loads `greeter/shell.qml` against stubbed `ShellRoot`, `FloatingWindow` and `Quickshell.env()`.

## Preview

The Control states sheet, every Control in every state:

```sh
/usr/lib/qt6/bin/qml -I qml qml/preview/Controls.qml
```

T switches light and dark; R switches Reduce transparency. Offscreen, the default software renderer skips shader effects (shadows, avatar masks); add `QT_QUICK_BACKEND=rhi QSG_RHI_BACKEND=opengl` to see them.
