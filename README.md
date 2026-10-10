# ModalityOS

An Arch-based Linux OS with its own Shell, Greeter and Apps. It aims for a beautiful look and feel, inspired by the best of macOS, Windows, HarmonyOS and other OSes.

**Status:** pre-alpha. The first piece, the Greeter (the login screen), is being built. Nothing is ready for everyday use.

<!-- Screenshot of the Greeter goes here once it is built, e.g.
![The ModalityOS Greeter](docs/images/greeter.png)
-->

## Stack

- Arch Linux base
- greetd with a Quickshell Greeter, hosted by Cage as the Greeter compositor
- KWin, then Hyprland, as Session compositors
- Quickshell for the Shell
- Qt 6 and CXX-Qt for Apps

The words used here (Greeter, Session, Shell, Token, Control) are defined in [`GLOSSARY.md`](GLOSSARY.md).

## Requirements

You need an Arch Linux host.

To build and test:

```sh
sudo pacman -S just qt6-declarative python librsvg imagemagick inter-font
```

- `just` runs the project's commands.
- `qt6-declarative` gives QML, `qmltestrunner` and `qmllint`.
- `python` runs the coverage check.
- `librsvg` and `imagemagick` render the wallpapers when you install a build.
- `inter-font` is the UI font.

For visual testing in a VM, also:

```sh
sudo pacman -S libvirt virt-manager qemu-full edk2-ovmf dnsmasq watchexec
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt "$USER"   # then log out and back in
```

`watchexec` runs `just deploy-watch`, which syncs your edits into the VM as you save.

[`docs/vm.md`](docs/vm.md) has the full VM setup.

## Quick start

```sh
git clone https://github.com/modalityos/modality.git
cd modality
just --list     # every recipe, with a one-line description
just check      # lint, tests and coverage, with a summary
just preview    # open the Control states sheet
```

In the preview, T switches light and dark, and R switches Reduce transparency.

## Testing

`just check` runs lint, the QML tests and the coverage check. Run it before you push. CI runs the same recipes on every pull request.

- `just test` runs the full QML suite, offscreen.
- `just test-one tests/tst_button.qml` runs one file.
- `just lint` and `just coverage` run the other two checks alone.

[`docs/testing.md`](docs/testing.md) explains what is tested and why, how to read a failure, and what CI runs.

## Visual testing in a VM

Tests cannot prove how things look, or how the Greeter behaves in a real boot. For that, use a test VM.

- `just vm-create` builds a reproducible VM named `modality-dev` at a fixed IP address. It writes the VM's SSH target to `.env`, which `just` loads, so no export is needed ([docs/vm.md](docs/vm.md)).
- `just deploy` installs a development build into the VM and makes greetd its login manager.
- `just rollback` restores the VM's previous login.
- `just vm-destroy` removes the VM.

[`docs/vm.md`](docs/vm.md) covers setup, options and troubleshooting.

## Documentation

| Where | What it is | Who it is for |
|---|---|---|
| [`docs/testing.md`](docs/testing.md) | How the tests work, how to run them, what CI checks | Contributors |
| [`docs/vm.md`](docs/vm.md) | Setting up and using the test VM | Contributors |
| [`docs/adr/`](docs/adr/) | Architecture decision records: hard-to-reverse choices and why | Anyone asking "why is it like this?" |
| [`GLOSSARY.md`](GLOSSARY.md) | The project's words and what each one means | Everyone |
| [`design/README.md`](design/README.md) | Shared context for design work; each piece has its own folder | Designers, and anyone building a screen |
| [`CODING_STANDARDS.md`](CODING_STANDARDS.md) | Rules for Rust, QML, comments, tests and naming | Contributors |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | How work flows from issue to merge | Contributors |

`docs/` holds the docs written for people. [`CLAUDE.md`](CLAUDE.md), `.claude/` and `docs/agents/` hold instructions for the coding agent. You can read them, but you do not need them to contribute.

## Repository layout

Each directory is created when something first lands in it.

```
crates/          Rust crates: pure service crates and their QML wrapper crates
daemons/         Background services
cli/             The modalityctl command-line tool
apps/            Apps (Settings, Files, ...)
qml/             Shared QML modules imported as Modality.<Name>, and the preview scene
shell/           The Shell (Quickshell)
greeter/         The Greeter (Quickshell)
session/         Session definitions and startup, greetd and polkit config
data/            Defaults and other files installed to the system
packaging/arch/  Arch packages (PKGBUILDs)
iso/             Installer ISO profile
tests/           QML tests, stubs, helpers and checks
tools/           Developer scripts: install, deploy to the test VM
design/          Design briefs, design snapshots and design specs
docs/            Docs for people, architecture decision records and agent docs
```

## Contributing

Read [`CONTRIBUTING.md`](CONTRIBUTING.md) before you open an issue or a pull request.

## License

MIT. See [`LICENSE`](LICENSE).
