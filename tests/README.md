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

## Preview

The Control states sheet, every Control in every state:

```sh
/usr/lib/qt6/bin/qml -I qml qml/preview/Controls.qml
```

T switches light and dark; R switches Reduce transparency. Offscreen, the default software renderer skips shader effects (shadows, avatar masks); add `QT_QUICK_BACKEND=rhi QSG_RHI_BACKEND=opengl` to see them.
