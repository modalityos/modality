# ModalityOS

An Arch-based Linux OS with its own Shell, Greeter and Apps, aiming for a beautiful look and feel, inspired by the best of macOS, Windows, HarmonyOS and other OSes.

**Status:** pre-alpha. Nothing runs yet.

## Stack

- Arch Linux base
- greetd with a Quickshell Greeter, hosted by Cage as the Greeter compositor
- KWin, then Hyprland, as Session compositors
- Quickshell for the Shell
- Qt 6 and CXX-Qt for Apps

## Layout

Each directory is created when something first lands in it.

```
crates/          Rust crates: pure service crates and their QML wrapper crates
daemons/         Background services
cli/             The modalityctl command-line tool
apps/            Apps (Settings, Files, ...)
qml/             Shared QML modules imported as Modality.<Name>
shell/           The Shell (Quickshell)
greeter/         The Greeter (Quickshell)
session/         Session definitions and startup
data/            Defaults and other files installed to the system
packaging/arch/  Arch packages (PKGBUILDs)
iso/             Installer ISO profile
tools/           Developer scripts
design/          Design briefs, Claude Design handoffs and design specs
docs/            Architecture decision records and agent docs
```

## More

- [`GLOSSARY.md`](GLOSSARY.md): the project's language.
- [`docs/adr/`](docs/adr/): architecture decisions.
