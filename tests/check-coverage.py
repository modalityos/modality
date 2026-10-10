#!/usr/bin/env python3
"""List every QML and JS file under greeter/ and qml/Modality/ that no test loads; exit 1 if any.

A file counts as exercised when it is reachable from a tests/tst_*.qml file by following:
  - type names: an identifier Foo resolves to Foo.qml in the file's own directory, in a directory
    it imports (import "dir"), or in a module it imports (Modality.Controls -> qmldir under an
    import path: qml/ or tests/stubs/);
  - script imports: import "file.js" as X, and .import "file.js" as X inside JS;
  - URLs to a .qml or .js file in Qt.resolvedUrl(...), Qt.createComponent(...) or source: "...".
This proves a file is loaded by some test, not that its lines run: it is not line coverage.
qml/preview/ is skipped. Run with python3 -I; --self-test checks the resolver on a tiny tree.
"""

import re
import sys
import tempfile
from pathlib import Path

IMPORT_PATHS = ("qml", "tests/stubs")
TARGETS = ("greeter", "qml/Modality")

COMMENT = re.compile(r"//[^\n]*|/\*.*?\*/", re.S)
STRING = re.compile(r'"(?:\\.|[^"\\\n])*"|\'(?:\\.|[^\'\\\n])*\'')
DIR_IMPORT = re.compile(r'^\s*\.?import\s+"([^"]+)"', re.M)
MODULE_IMPORT = re.compile(r"^\s*import\s+([A-Za-z_][\w.]*)", re.M)
URL = re.compile(r'(?:resolvedUrl|createComponent)\(\s*"([^"]+\.(?:qml|js))"|source:\s*"([^"]+\.(?:qml|js))"')
IDENT = re.compile(r"\b[A-Z]\w*\b")


def qmldir_types(directory):
    """Type name -> file for a directory: its qmldir entries, plus every Foo.qml in it."""
    types = {p.stem: p for p in directory.glob("*.qml")}
    qmldir = directory / "qmldir"
    if qmldir.is_file():
        for line in qmldir.read_text().splitlines():
            parts = line.split()
            if parts and parts[0] == "singleton":
                parts = parts[1:]
            if len(parts) == 3 and parts[2].endswith((".qml", ".js")):
                types[parts[0]] = directory / parts[2]
    return types


def edges(path, root):
    """The files a QML or JS file loads."""
    text = path.read_text()
    found = set()
    scopes = [path.parent]
    for target in DIR_IMPORT.findall(text):
        resolved = (path.parent / target).resolve()
        if resolved.is_dir():
            scopes.append(resolved)
        elif resolved.is_file():
            found.add(resolved)
    for module in MODULE_IMPORT.findall(text):
        for base in IMPORT_PATHS:
            directory = root / base / module.replace(".", "/")
            if (directory / "qmldir").is_file():
                scopes.append(directory)
    for groups in URL.findall(text):
        resolved = (path.parent / (groups[0] or groups[1])).resolve()
        if resolved.is_file():
            found.add(resolved)
    if path.suffix == ".qml":
        names = set(IDENT.findall(STRING.sub('""', COMMENT.sub("", text))))
        for scope in scopes:
            for name, file in qmldir_types(scope).items():
                if name in names and file.resolve() != path:
                    found.add(file.resolve())
    return found


def unexercised(root):
    root = root.resolve()
    seen = set()
    pending = [p.resolve() for p in sorted((root / "tests").glob("tst_*.qml"))]
    while pending:
        path = pending.pop()
        if path in seen:
            continue
        seen.add(path)
        pending.extend(edges(path, root) - seen)
    return [p.relative_to(root) for p in target_files(root) if p not in seen]


def target_files(root):
    return sorted(
        p.resolve()
        for target in TARGETS
        for p in (root.resolve() / target).rglob("*")
        if p.suffix in (".qml", ".js")
    )


def self_test():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        files = {
            "tests/tst_a.qml": 'import QtQuick\nimport Modality.Controls\nimport "../greeter/lib"\n'
            'Item { Button {} property UsedType t; Component.onCompleted: Qt.createComponent('
            'Qt.resolvedUrl("../greeter/shell.qml")) }\n',
            "qml/Modality/Controls/qmldir": "module Modality.Controls\nButton 1.0 Button.qml\n"
            "singleton Glyphs 1.0 Glyphs.qml\nUnused 1.0 Unused.qml\n",
            "qml/Modality/Controls/Button.qml": "import QtQuick\nItem { width: Glyphs.size }\n",
            "qml/Modality/Controls/Glyphs.qml": "pragma Singleton\nimport QtQuick\nQtObject {}\n",
            "qml/Modality/Controls/Unused.qml": "import QtQuick\nItem {}\n",
            "greeter/lib/UsedType.qml": 'import QtQuick\nimport "logic.js" as Logic\nItem {}\n',
            "greeter/lib/logic.js": '.import "helper.js" as Helper\n',
            "greeter/lib/helper.js": "",
            "greeter/lib/Commented.qml": "import QtQuick\nItem {}\n",
            "greeter/lib/Stringed.qml": "import QtQuick\nItem {}\n",
            "greeter/shell.qml": 'import QtQuick\nItem { // Commented {}\n property string s: "Stringed" }\n',
        }
        for name, text in files.items():
            (root / name).parent.mkdir(parents=True, exist_ok=True)
            (root / name).write_text(text)
        got = [str(p) for p in unexercised(root)]
        want = ["greeter/lib/Commented.qml", "greeter/lib/Stringed.qml", "qml/Modality/Controls/Unused.qml"]
        if got != want:
            print(f"self-test failed: got {got}, want {want}")
            return 1
    print("self-test OK")
    return 0


def main():
    if sys.argv[1:] == ["--self-test"]:
        return self_test()
    root = Path(__file__).resolve().parent.parent
    missing = unexercised(root)
    total = len(target_files(root))
    loaded = total - len(missing)
    # The bar is every file: a percentage only makes the result easier to read.
    print(f"{loaded}/{total} Greeter and shared-module files loaded by a test ({loaded * 100 // total}%)")
    if missing:
        print("No test loads these files:")
        for path in missing:
            print(f"  {path}")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
