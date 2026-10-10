# Testing

How ModalityOS is tested: what the tests cover and why, the tools, how to run them and read a failure, how to check a change by hand in the test VM, and what CI runs.

Every command lives in the root `justfile`. Install `just` once (`sudo pacman -S just`), then `just --list` shows every recipe with a one-line description.

## What is tested, and why

Tests check behaviour through a public **seam**, never internals: what the screen shows and does for a given backend input, what a parser returns for given text, what a Control does for a given input. Each test is named after the behaviour it checks, in the words of `GLOSSARY.md`, so a failing test's name says what broke.

The Greeter (spec #10) is tested through three seams.

### Seam 1: the Greeter against a fake backend

The main seam. The Greeter screen runs under `qmltestrunner` with no Quickshell at all; its backend is `tests/helpers/FakeBackend.qml`, which records each operation the screen asks for and lets a test play the part of greetd by emitting backend events. This covers every state and the keyboard path in the design spec: last user selected, typing, checking, wrong password, Caps Lock, session failed, unavailable, the Other users panel, Options, power actions, theme, clock and Reduce transparency.

| File | Covers |
|---|---|
| `tst_greeter.qml` | The login flow and its states, avatars, wallpapers, the Other users panel |
| `tst_power.qml` | Each power button calls its backend operation |
| `tst_options.qml` | Options and the Session Menu: shown only with more than one Session, picking, each user's remembered Session, the Tab order |
| `tst_settings.qml` | Machine settings on screen: theme, clock, Reduce transparency |
| `tst_keyboard.qml` | The Tab order and the focus ring |
| `tst_layout.qml` | The Ready state fits at 1366 × 768 |

### Seam 2: the real backend against stubbed Quickshell

`greeter/RealBackend.qml` is the thin layer that talks to Quickshell. Its Quickshell types (`Greetd`, `Process`, `FileView`) are replaced by stubs in `tests/stubs/`, fed fixture output. This covers parsing AccountsService output (system accounts filtered, icons), `wayland-sessions` entries (hidden ones skipped), the state file (read, write, missing, corrupt), settings precedence (Admin overrides beat Defaults) and greetd conversations (prompt, failure, success, unreachable).

| File | Covers |
|---|---|
| `tst_realbackend.qml` | Users, Sessions, the state file and greetd conversations |
| `tst_realbackend_power.qml` | The `systemctl` command each power action runs |
| `tst_realbackend_settings.qml` | Settings files and their precedence |
| `tst_shell.qml` | `greeter/shell.qml` loads against stubbed `ShellRoot`, `FloatingWindow` and `Quickshell.env()`, and finds its files through `MODALITYOS_PREFIX` |

### Seam 3: the shared modules at their public API

`Modality.Theme` and `Modality.Controls` are shared by the Shell, the Greeter and Apps, so they are tested on their own: every Token equals its design spec value by code name in both themes, and each Control's states, properties and signals.

| File | Covers |
|---|---|
| `tst_theme.qml` | Tokens and type styles in light and dark, fonts, Reduce transparency |
| `tst_button.qml`, `tst_iconbutton.qml` | Button and IconButton states, shadows, Enter and Space |
| `tst_passwordfield.qml` | Submit, Esc clears, states, busy, the shake |
| `tst_menu.qml` | Menu selection and keys |
| `tst_notice.qml` | Notice tones |
| `tst_avatar.qml` | Avatar sizes, picture, states and shadows |
| `tst_focusring.qml` | The focus ring |

### The shared test kit

Tests share one set of stubs, helpers and fixtures, so each new test reuses what is there rather than adding its own stub:

- `tests/stubs/Quickshell/`: stubs of the Quickshell types the Greeter uses (`Quickshell`, `ShellRoot`, `FloatingWindow`, `Quickshell.Io`'s `Process`, `StdioCollector` and `FileView`, and the `Greetd` service).
- `tests/stubs/QuickshellStubs/`: test-only controls for those stubs. `Processes` finds a stub `Process` by its command and feeds it output; `Files` is a fake filesystem behind `FileView`.
- `tests/helpers/FakeBackend.qml`: the Greeter backend for seam 1.
- `tests/fixtures/`: small files tests load, such as tiny wallpaper PNGs.

The kit grows as tests need it. Each addition is documented here and in `.claude/rules/tests.md`, the short version agents read when they work under `tests/`.

## The tools

- **Qt Quick Test** (`qmltestrunner`): runs every `tests/tst_*.qml`. Each file is a `TestCase`; each `test_*` function is a test. It runs offscreen, so no window opens.
- **qmllint**: Qt's static checker for QML: unknown properties, wrong types, unqualified ids. `just lint` runs it over every QML file in the repo and fails on any warning.
- **`tests/check-imports.sh`**: enforces the shared modules' import rule: `Modality.Theme` imports only Qt, `Modality.Controls` only Qt and `Modality.Theme`. Shared modules must not depend on a screen.
- **The coverage check** (`tests/check-coverage.py`): lists every QML and JS file under `greeter/` and `qml/Modality/` that no test loads, and fails if there is one. It follows type names, imports and component URLs out from each test file. Its limit: it proves a file is *loaded* by some test, not that its lines or branches run. It is not line coverage. `qml/preview/` is skipped. `--self-test` checks the script itself on a tiny tree. It prints the result as a share, such as `35/35 … (100%)`, but the bar is every file: one unloaded file fails it.
- **just**: the one place the commands live. People, agents and CI all call the same recipes.

## Running the checks

| Recipe | What it does |
|---|---|
| `just test` | The full QML suite, offscreen |
| `just test-one tests/tst_button.qml` | One test file |
| `just lint` | The import rule, then qmllint over every QML file |
| `just coverage` | The coverage check's self-test, then the check |
| `just check` | `lint`, `test` and `coverage`, in that order, all three even if one fails, then a summary such as `lint ✓ · test ✗ · coverage ✓`; run before pushing |
| `just preview` | The Control states sheet |

What `just test` runs, from the repo root:

```sh
QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qmltestrunner -import qml -import tests/stubs -input tests
```

`-import qml` makes `Modality.Theme` and `Modality.Controls` loadable; `-import tests/stubs` puts the Quickshell stubs in their place.

### Reading a failure

- **A test fails:** `qmltestrunner` prints `FAIL!  : qmltestrunner::<TestCase name>::<test name>()`, then the comparison that failed (`Actual` and `Expected`) and the file and line. The test name says which behaviour broke. Rerun that file alone with `just test-one`.
- **A file fails to load:** a QML error (unknown type, syntax error) is printed before the totals, and every test in that file is missing from them. Fix the error first.
- **`QWARN` lines** are warnings the code under test printed. Some are expected, such as a test feeding a picture that cannot be read.
- **The last line** gives the totals: `Totals: N passed, M failed, ...`. Any failure makes the recipe exit non-zero.
- **lint** prints each warning as `Warning: <file>:<line>:<column>: <message> [<category>]`; the category names the rule.
- **check** ends with one line per recipe, ✓ or ✗; scroll up to that recipe's `== just <recipe>` header for its output.
- **coverage** prints each file no test loads. Add a test that loads it through one of the seams above; if the file is loaded and the script misses it, fix the script.

## The preview scene

`just preview` opens the Control states sheet, `qml/preview/Controls.qml`: every Control in every state, for checking looks by eye. T switches light and dark; R switches Reduce transparency. Offscreen, the default software renderer skips shader effects (shadows, avatar masks); run it with `QT_QUICK_BACKEND=rhi QSG_RHI_BACKEND=opengl` to see them.

## Manual testing in the VM

Some things only show in a real boot: the Greeter starting under greetd and Cage, frosted glass over the real wallpaper, the shake on a wrong password, a correct password starting the KWin Session, power actions, more than one monitor.

- `just vm-create` builds the test VM, `modality-dev`, from a pinned Arch cloud image at a fixed address, and prints the `MODALITYOS_VM` line to set; `just vm-destroy` removes it. [The test VM](vm.md) covers the tools to install, what it builds, opening its screen and troubleshooting.
- `just deploy` installs a development build into the test VM and makes greetd its display manager. The VM is an ssh destination, read from `MODALITYOS_VM` or given with `--vm`. Options pass through to `tools/deploy-vm.sh`: `--prefix DIR`, `--reboot`.
- `just sync` sends only the changed files to a VM that has had one `just deploy`, and restarts greetd unless only the Greeter's own files changed; `just deploy-watch` runs it on every save. [The test VM](vm.md#edit-and-see-it-live) says what reloads by itself.
- `just rollback` restores the VM's previous display manager and greetd config; `--purge` also removes the development root. From a text console in the VM, `sudo /var/lib/modalityos-dev-deploy/remote.sh rollback` does the same.
- `just install <prefix>` installs the files under a prefix without a VM, for a package build or to inspect the layout.

**User checks.** Each ticket that builds visual work has a **User check**: the result matches its design. Tests cannot prove looks, so these stay open for you. Tick each one in its ticket where you see the piece shown (the VM or the preview scene) before merging.

**`/signoff`.** The last stage before you merge a PR. You run the PR in the VM or preview and say what is not right; the agent fixes each finding on the PR's branch, test-first where a test can prove it, and ticks each User check you confirm.

## CI

The **Tests** workflow (`.github/workflows/tests.yml`) runs on every pull request, drafts included, and on every push to `main`. It runs in an Arch Linux container, matching the development machines' Qt; Ubuntu's Qt is too old for `MultiEffect`. It has three jobs, each one `just` recipe:

| Job | Recipe |
|---|---|
| QML tests | `just test` |
| Imports and lint | `just lint` |
| Test coverage | `just coverage` |

A branch with no `tests/` directory passes each job with "no tests". CI runs the three recipes as separate jobs, so a failure on a PR names its kind; `just check` is the local way to run all three.

**Line coverage** has no free tool for QML, so the coverage check stays file-level. When Rust crates land, a Rust coverage job will add a line-coverage bar with `cargo llvm-cov --fail-under-lines <percent>`.

The **Sign-off gate** workflow (`.github/workflows/signoff-gate.yml`) fails while an issue the PR closes still has an unticked box, such as an open User check. It runs when a PR is opened, edited, updated or marked ready (drafts are skipped), and again when a closed issue's boxes are edited.

**Required on `main`:** the repository's `signoff-gate` ruleset requires four checks: **Tickets signed off**, **QML tests**, **Imports and lint** and **Test coverage**. The organisation's ruleset adds a squash merge, linear history and an approving review.
