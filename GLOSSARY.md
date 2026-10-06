# ModalityOS

An Arch-based Linux OS with its own desktop shell, login screen and apps, aiming for a macOS-like look and feel.

## Language

### Login

**Greeter**:
The login screen the user sees before a Session starts: password entry, user and Session choice.
_Avoid_: Display manager, login manager, DM

**Greeter compositor**:
The compositor that hosts the Greeter and nothing else; Cage at first.
_Avoid_: Display manager

**Session**:
What runs after a successful login: one Session compositor plus the Shell on top of it.
_Avoid_: Desktop, environment

### Desktop

**Session compositor**:
The compositor a Session runs on, chosen at login; KWin first, Hyprland later.
_Avoid_: Window manager, WM, DE

**Shell**:
The always-present desktop UI drawn over the Session compositor: panels, dock, widgets, overlays.
_Avoid_: Desktop, bar, theme

**App**:
A standalone program with its own windows, such as Settings or Files, that is not part of the Shell.
_Avoid_: Application window, client, program

### Settings

**Defaults**:
The ModalityOS settings every machine starts with, shipped with the OS and never edited in place.
_Avoid_: Dotfiles, presets

**Admin overrides**:
Machine-wide changes to the Defaults made by the machine's administrator; they apply to every user and to the Greeter.
_Avoid_: System settings, global config

**User settings**:
One user's own changes on top of the Defaults and Admin overrides; they win over both and never apply to the Greeter.
_Avoid_: Preferences, profile, dotfiles
