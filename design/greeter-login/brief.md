# Greeter Login: design brief

**Kind:** screen · **Artifact:** https://claude.ai/artifact/HcWha4trdzGPenb7DhymTz

## Purpose
The Greeter is the first thing anyone sees after boot: the login screen. It shows who can log in, takes their password, and starts their Session, or lets them sleep, restart or shut down. It should feel calm and familiar, like the macOS login screen, and never in the way.

## Decisions
- **Foundations:** built only from the ModalityOS Foundations Tokens (`design/foundations/spec.md`); `SceneLogin` there is the starting point.
- **Wallpaper and glass:** the machine-wide wallpaper (`wallpaper-default`, an Admin override; showing a user's own wallpaper is a later Settings opt-in) fills the screen. Cage cannot blur, so the Greeter blurs its own wallpaper behind the password field, Notices, Menu and buttons, using the Foundations' material tints and blur; the `*-fallback` colours are only for Reduce transparency.
- **Theme:** dark by default, light possible. The theme and the clock format are machine-wide settings (Defaults plus Admin overrides), set at install or later in Settings by an admin, and read by the Greeter at start; a user's own settings never reach it.
- **Users:** every human account, from AccountsService; no system accounts, no "Other…". Up to four users: a row of avatars, the selected one larger and carrying the password field. Five or more: only the last user, large, with a **Switch user** button that opens a frosted grid of everyone. The last user to log in is selected in advance. A "Name and password" mode with no avatars is a later admin option, not designed now.
- **Avatars:** the user's own picture, else a built-in avatar. The built-in set is its own later piece (`avatars-default`, our own illustrations); here, use three or four temporary sample avatars in that style (an animal, a flower, a ball, a landscape).
- **Sessions:** a machine default Session (KWin for now, an Admin override) is used. The choice is hidden behind an **Options** icon button at the bottom-left, which opens a Menu of Sessions; it shows only when more than one Session is installed, and a pick is remembered for that user only.
- **Power:** Sleep, Restart and Shut Down at the bottom centre, with no confirmation step.
- **Clock:** 24-hour by default (`09:41`), date as "Friday 9 October".
- **Keyboard:** ← and → switch users; typing goes straight into the password field; Enter submits; Esc clears the field; Tab moves through password, Options, Sleep, Restart, Shut Down.

## Terms
- **Greeter**: The login screen the user sees before a Session starts: password entry, user and Session choice.
- **Session**: What runs after a successful login: one Session compositor plus the Shell on top of it.
- **Session compositor**: The compositor a Session runs on, chosen at login; KWin first, Hyprland later.
- **Greeter compositor**: The compositor that hosts the Greeter and nothing else; Cage at first.
- **Token**: A named visual value, such as a colour, corner radius, spacing step, font, shadow or motion curve, that every piece of the UI takes its look from.
- **Foundations**: The base set of Tokens that the Shell, the Greeter and every App share.
- **Control**: A reusable piece of UI, such as a button, password field or avatar, shared by the Shell, the Greeter and Apps.
- **Defaults**: The ModalityOS settings every machine starts with, shipped with the OS and never edited in place.
- **Admin overrides**: Machine-wide changes to the Defaults made by the machine's administrator; they apply to every user and to the Greeter.

## What to design
Components, each named and each a reusable Control unless marked:
- **Clock** (screen part): date above a large time.
- **UserRow** (screen part): the row of up to four users; selected and unselected avatars with names.
- **UserGrid** (screen part): the Switch user panel, a frosted grid of every user.
- **Avatar** (Control): picture or placeholder in a circle, at large (selected) and small (row) sizes.
- **PasswordField** (Control): pill field with placeholder and a submit button inside.
- **Button** (Control): primary and secondary, used for Try again.
- **IconButton** (Control): round button with a label under it, for Options and the power buttons.
- **Menu** (Control): the Sessions menu, with the current Session checked.
- **Notice** (Control): a small pill message, in warning and danger tones.

States, one artboard each, dark first, then the main ones in light:
- **Ready:** one user, selected, empty field focused.
- **Several users:** three users in a row, one selected; five users as the last user plus Switch user.
- **Switch user open:** the frosted grid of eight users, one highlighted.
- **Typing:** password dots in the field.
- **Caps Lock on:** warning Notice under the field.
- **Checking:** spinner replaces the submit arrow; field disabled.
- **Wrong password:** field shakes (`motion-easing-spring`), clears, danger Notice "Wrong password" under it for three seconds.
- **Session failed:** danger Notice "Couldn't start the session." with a Try again Button.
- **Login unavailable:** greetd cannot be reached; message "Login is unavailable. Restart the computer or switch to a text console." in place of the field.
- **Options open:** the Sessions Menu open over the bottom-left Options button, KWin checked, Hyprland listed.
- **Starting:** the screen fading out (`motion-duration-slow`), shown as a mid-fade frame.
- **Control states:** hover, pressed, focused and disabled for Avatar, PasswordField, Button and IconButton, on one sheet.

## Canvas and sizes
1920 × 1080 at 1× for every state; one extra artboard of Ready at 1366 × 768 to check it fits.

## Content
- Users: "John Doe" (default), "Alexandria Montgomery-Fitzwilliam" (longest name), "Sam Lee", "Priya Shah", "Tom Okafor"; for overflow add "Mia Chen", "Leo Rossi", "Ana Silva".
- Clock `09:41`, date "Friday 9 October".
- Placeholder "Enter password"; Notices "Caps Lock is on", "Wrong password", "Couldn't start the session."; button "Try again".
- Power labels "Sleep", "Restart", "Shut Down"; Options label "Options"; Sessions "KWin", "Hyprland".

## Reuse
- `design/wallpaper-default/spec.md`: the default wallpaper, designed first.
- The ModalityOS Foundations design system and its Tokens, by name.
- `refs/scene-login.html`: the Foundations' login scene. Keep its layout (date and clock top centre, user bottom centre, power row at the bottom) and its proportions; replace its blurred materials with the solid fallbacks.

## Constraints
- Contrast floors from `design/README.md` hold over the wallpaper as well as on Controls: text on the wallpaper needs a solid backing or must pass against every point of the gradient.
- Every focusable element shows the `focus-ring`; the whole screen works by keyboard alone.
- No Apple assets or window controls; nothing mistakable for the macOS login screen.

## Out of scope
- The built-in avatar set (`avatars-default`), designed later.
- Multi-monitor layouts: Cage shows the Greeter on one output.
- Fingerprint login, accessibility menu, keyboard-layout switcher.
- The lock screen and the boot splash.

## Hand back
- [ ] Clock, UserRow, Avatar, PasswordField, Button, IconButton, Menu and Notice, each named
- [ ] Ready, dark and light
- [ ] Several users, three and five
- [ ] Switch user open
- [ ] Typing
- [ ] Caps Lock on
- [ ] Checking
- [ ] Wrong password
- [ ] Session failed
- [ ] Login unavailable
- [ ] Options open, dark and light
- [ ] Starting
- [ ] Control states sheet
- [ ] Ready at 1366 × 768
- [ ] Contrast passing on every state, including text over the wallpaper
