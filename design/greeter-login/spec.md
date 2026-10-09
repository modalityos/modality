# Greeter Login: design spec

**Kind:** screen · **Brief:** brief.md · **Artifact:** https://claude.ai/artifact/HcWha4trdzGPenb7DhymTz · **Source:** handoff/ (1791542555-0a47, 2026-10-09)
**Built by:** not yet built. Implementing replaces this with the spec issue, `#<number>`; from then on the code is the source of truth.

The design is the "Other users" layout: only the last user to log in shows, large, with an **Other users** pill when there are more. The mockup's code also holds a row layout and a list layout (`layout="row"`, `layout="list"`); both were set aside in the brief and are not part of this spec.

## Tokens
Every `var(--…)` the screen and the Control states sheet read, plus the type styles and motion Tokens the behaviour uses. Values are as in `design/foundations/spec.md`; the snapshot's `tokens.css` matches them. `focusRingOffset` (now 2px), `footnoteMedium` and `footnoteStrong` were changed or added in the Foundations at this intake; no other Token is new.

| Token | Light | Dark | Code name | Note |
|---|---|---|---|---|
| `bg` | `#efeeec` | `#1f1e1d` | `bg` | Root ground under the wallpaper Image (shows only if the wallpaper fails to load) |
| `surface-overlay` | `#fbfbfa` | `#2f2e2c` | `surfaceOverlay` | Options IconButton while its Menu is open; hover fill of PasswordField and IconButton |
| `surface-sunken` | `#e6e5e3` | `#181716` | `surfaceSunken` | Pressed fill of IconButton |
| `fill` | `rgba(0, 0, 0, 0.05)` | `rgba(255, 255, 255, 0.08)` | `fill` | Button secondary (Cancel); disabled Button primary |
| `fill-strong` | `rgba(0, 0, 0, 0.1)` | `rgba(255, 255, 255, 0.14)` | `fillStrong` | Highlighted UserPanel cell; Button secondary hover and pressed; spinner track |
| `scrim` | `rgba(0, 0, 0, 0.28)` | `rgba(0, 0, 0, 0.5)` | `scrim` | Full-screen layer behind the UserPanel |
| `text-primary` | `rgba(0, 0, 0, 0.86)` | `rgba(255, 255, 255, 0.88)` | `textPrimary` | Clock, name, field text, labels, panel text |
| `text-secondary` | `rgba(0, 0, 0, 0.64)` | `rgba(255, 255, 255, 0.64)` | `textSecondary` | Menu heading "Session"; spinner arc |
| `text-tertiary` | `rgba(0, 0, 0, 0.58)` | `rgba(255, 255, 255, 0.56)` | `textTertiary` | Placeholder "Enter password" (browser default in the mockup; use this Token) |
| `text-disabled` | `rgba(0, 0, 0, 0.26)` | `rgba(255, 255, 255, 0.26)` | `textDisabled` | Disabled Button, IconButton, Menu item |
| `accent` | `#1c6ee8` | `#366bfc` | `accent` | Submit button, Try again, highlighted Menu item |
| `accent-hover` | `#1862d0` | `#2f62ee` | `accentHover` | Button primary hover |
| `accent-pressed` | `#1455b8` | `#2858dc` | `accentPressed` | Button primary and Menu item pressed |
| `on-accent` | `#ffffff` | `#ffffff` | `onAccent` | Text and glyphs on `accent` |
| `warning` | `#7a4e00` | `#f5b83d` | `warning` | Caps Lock Notice |
| `danger` | `#a8231f` | `#ff8f87` | `danger` | Wrong password and Session failed Notices; Login unavailable icon |
| `focus-ring` | `#1c6ee8` | `#8cbcff` | `focusRing` | Outer ring of every focused element |
| `material-popover-tint` | `rgba(251, 251, 250, 0.82)` | `rgba(32, 32, 34, 0.9)` | `materialPopoverTint` | Every frosted element: field, Notices, pill, IconButtons, Menu, UserPanel |
| `material-popover-fallback` | `#fbfbfa` | `#2f2e2c` | `materialPopoverFallback` | Reduce transparency fill; the focus ring's halo |
| `material-popover-blur` | `24px` | — | `materialPopoverBlur` | Blur radius of the wallpaper behind each frosted element |
| `material-saturation` | `1.6` | — | `materialSaturation` | Saturation applied with the blur |
| `shadow-raised` | `0 0 0 0.5px rgba(0, 0, 0, 0.1), 0 2px 6px rgba(0, 0, 0, 0.1)` | `0 0 0 0.5px rgba(255, 255, 255, 0.1), 0 2px 6px rgba(0, 0, 0, 0.5)` | `shadowRaised` | IconButtons, Other users pill, panel avatars, Button default and hover |
| `shadow-floating` | `0 0 0 0.5px rgba(0, 0, 0, 0.12), 0 10px 30px rgba(0, 0, 0, 0.16)` | `0 0 0 0.5px rgba(255, 255, 255, 0.12), 0 10px 30px rgba(0, 0, 0, 0.55)` | `shadowFloating` | Large Avatar, PasswordField, Session failed Notice, Login unavailable card, Menu |
| `shadow-modal` | `0 0 0 0.5px rgba(0, 0, 0, 0.14), 0 22px 60px rgba(0, 0, 0, 0.28)` | `0 0 0 0.5px rgba(255, 255, 255, 0.14), 0 22px 60px rgba(0, 0, 0, 0.65)` | `shadowModal` | UserPanel; Avatar hover |
| `radius-small` | `6px` | — | `radiusSmall` | Menu items |
| `radius-control` | `8px` | — | `radiusControl` | Button secondary (Cancel) |
| `radius-card` | `12px` | — | `radiusCard` | Menu, Login unavailable card, UserPanel cells |
| `radius-panel` | `16px` | — | `radiusPanel` | UserPanel |
| `radius-pill` | `9999px` | — | `radiusPill` | Avatars, PasswordField, submit button, Notices, Other users pill, IconButtons, Try again |
| `control-height` | `28px` | — | `controlHeight` | Button (Cancel) |
| `control-height-small` | `24px` | — | `controlHeightSmall` | Other users pill, Try again |
| `control-height-large` | `32px` | — | `controlHeightLarge` | PasswordField |
| `row-height` | `28px` | — | `rowHeight` | Menu items |
| `avatar-size-large` | `96px` | — | `avatarSizeLarge` | The shown user's Avatar |
| `focus-ring-width` | `3px` | — | `focusRingWidth` | Outer ring of the two-tone focus ring |
| `focus-ring-offset` | `2px` | — | `focusRingOffset` | Halo between element and ring, in `materialPopoverFallback`. Changed in the Foundations at this intake (was `1px`) |
| `motion-duration-fast` | `100ms` | — | `motionDurationFast` | Hover and press |
| `motion-duration-normal` | `200ms` | — | `motionDurationNormal` | Menu and UserPanel open and close; Notice in and out |
| `motion-duration-slow` | `300ms` | — | `motionDurationSlow` | Starting fade; shake runs `2 x` this |
| `motion-easing-in` | `cubic-bezier(0.4, 0, 1, 1)` | — | `motionEasingIn` | Starting fade; closing Menu and UserPanel |
| `motion-easing-out` | `cubic-bezier(0, 0, 0.2, 1)` | — | `motionEasingOut` | Opening Menu and UserPanel; Notice in |
| `motion-easing-spring` | `cubic-bezier(0.34, 1.56, 0.64, 1)` | — | `motionEasingSpring` | Wrong-password shake |
| `font-sans` | `Inter, "Noto Sans", system-ui, sans-serif` | — | `fontSans` | All text |
| `title-1` | 22px / 28px / 600 / -0.01em | — | `title1` | Date |
| `display` | 96px / 100px / 600 / -0.03em | — | `display` | Clock time, tabular figures |
| `title-2` | 17px / 22px / 600 | — | `title2` | "Choose a user" |
| `headline` | 15px / 20px / 600 | — | `headline` | User name under the large Avatar |
| `body` | 13px / 16px / 400 | — | `body` | Password text and placeholder; Menu items |
| `body-medium` | 13px / 16px / 500 | — | `bodyMedium` | Button labels (Try again, Cancel) |
| `footnote` | 11px / 14px / 400 | — | `footnote` | Login unavailable message |
| `footnote-medium` | 11px / 14px / 500 | — | `footnoteMedium` | Notices, Other users pill, IconButton labels, UserPanel names. New in the Foundations at this intake |
| `footnote-strong` | 11px / 14px / 600 | — | `footnoteStrong` | Menu heading "Session". New in the Foundations at this intake |

## Raw values
Values the design uses outside a Token.

| Value | Where | Why it stays raw, or recommendation |
|---|---|---|
| `240px` width | PasswordField | Recommend Token `passwordFieldWidth`. |
| `280px` width, `236px` min height, `12px` gap | User column (Avatar, name, field, Notice, pill) | Screen layout. Width caps the longest name ("Alexandria Montgomery-Fitzwilliam" wraps to two lines, centred); min height stops the column jumping when a Notice appears. Gap is `space3`: use the Token. |
| `64px` | Small Avatar (UserPanel cells, sheet) | Recommend Token `avatarSizeSmall` beside `avatarSizeLarge`. |
| `40px` circle | IconButton (Options, Sleep, Restart, Shut Down) | Recommend Token `iconButtonSize`. |
| `16px` glyph, stroke `1.5` | IconButton icons | Icon drawing size; stays with the icons. |
| `24px` circle, `12px` arrow glyph stroke `1.6` | Submit button inside the PasswordField | Equals `controlHeightSmall`: use that Token for the circle. Glyph stays raw. |
| `18px` spinner, stroke `2`, radius `7` | Checking spinner, in a 24px box | Drawing size. |
| Padding `0 4px 0 16px`, gap `8px` | PasswordField | Right `4px` centres the 24px submit in the 32px field. `16px` is `space4`, `8px` is `space2`: use the Tokens. |
| `letter-spacing: 0.08em` | Password text (dots) | Spaces the dots; no Token. |
| `112px` top / `56px` at 1366 × 768 | Clock block from the top edge | Screen layout. Rule: `56px` when the screen is under 900px tall. |
| `176px` bottom / `96px` small | User column bottom from the bottom edge | Screen layout, same rule. |
| `40px` bottom / `28px` small | Power row and Options from the bottom edge | Screen layout, same rule. `40px` is `space10`. |
| `40px` right | Options IconButton and its Menu from the right edge | `space10`. |
| `powerBottom + 72px` (`112px` / `100px` small) | Menu bottom edge | Places the Menu above the Options button and label. |
| `4px` gap | Date to time | `space1`. |
| `32px` gap | Between power IconButtons | `space8`. |
| `6px` gap | IconButton to its label; Notice icon to text; pill icon to text | Sub-grid; matches the Foundations' draft login scene. Keep raw. |
| Notice padding `4px 12px`, `10px` glyph | Caps Lock and Wrong password Notices | Small pill sizing; `12px` is `space3`. |
| Session failed Notice padding `6px 6px 6px 14px`, gap `12px` | Notice with a Try again Button inside | `6px` centres the 24px button in the 36px pill. |
| Try again padding `0 12px` | Button inside the Session failed Notice | `space3`. |
| Unavailable card max width `320px`, padding `12px 16px`, gap `10px`, `16px` icon offset `1px` down | Login unavailable | Screen layout. |
| Other users pill padding `0 12px`, `12px` glyph | Other users pill | `space3`. |
| Menu width `220px`, padding `4px`, item gap `2px`, item padding `0 10px`, unchecked item left padding `30px`, check glyph `12px`, heading padding `6px 10px 4px` | Session Menu | `30px` = 10 + 12 glyph + 8 gap, so labels align. Recommend Tokens if Menu is reused in the Shell; for now keep raw. |
| `640px` width, padding `24px`, gap `20px` | UserPanel | Screen layout. Padding is `space6`, gap is `space5`. |
| 4-column grid (`min(users, 4)` columns, equal width), row gap `20px`, column gap `12px` | UserPanel grid | Build as `GridLayout { columns: Math.min(count, 4) }` with equal-width cells. |
| Cell padding `10px 4px`, gap `8px` | UserPanel cell | Sub-grid. |
| Cancel padding `0 16px` | UserPanel Cancel button | `space4`. |
| Opacity `0.7` | PasswordField while Checking | Recommend Token `opacityBusy`. |
| Opacity `0.35` | Content mid-fade in the Starting frame | One frame of the 1 → 0 fade, not a resting value. |
| Opacity `0.4` / `0.5` | Disabled Avatar / disabled PasswordField and IconButton | Two disabled opacities. Recommend one Token `opacityDisabled`. |
| `scale(1.04)` / `scale(0.96)` | Avatar hover / pressed (sheet) | Hover and press feedback. |
| `scale(0.95)` | IconButton pressed (sheet) | Press feedback. |
| `translateX(-8px)` | PasswordField in the Wrong password frame | One frame of the shake. Keyframes are in Interaction and motion. |
| `200px` label column, `40px 64px` padding, `24px` row gap | Control states sheet | Sheet layout only; not built. |

## Components
Controls are reusable and live in `Modality.Controls`, built only from `Modality.Theme` Tokens: **Avatar, PasswordField, Button, IconButton, Menu, Notice**. Everything else is a screen part of the Greeter. Every frosted element below is "Glass": `materialPopoverTint` over the blurred wallpaper (see Build notes).

- **Greeter** (screen part, root): `Item` filling the output; `Rectangle` in `bg` underneath.
  - **Wallpaper**: `Image`, `fillMode: Image.PreserveAspectCrop`, anchors fill; Silk light or dark by theme (see Assets). Also the blur source for every Glass element.
  - **Content** (`Item`, anchors fill): everything below except the UserPanel; its `opacity` drives Starting.
    - **Clock** (screen part): `ColumnLayout`, horizontally centred, top `112px` (`56px` on short screens), spacing `space1`, colour `textPrimary`, text on the wallpaper with no backing.
      - Date `Text`, `title1`, "Friday 9 October" (`dddd d MMMM`).
      - Time `Text`, `display`, "09:41", tabular figures; 24-hour by default, format from the machine-wide setting.
    - **UserColumn** (screen part): `ColumnLayout`, width `280px`, min height `236px`, spacing `space3`, centred, bottom `176px` (`96px` on short screens), items centred.
      - **Avatar** (Control), large: `avatarSizeLarge` circle (`radiusPill`), image cropped to cover, `shadowFloating`. Not focusable here.
      - Name `Text`, `headline`, `textPrimary`, centred, wraps within 280px.
      - **PasswordField** (Control): `Rectangle` `240px` × `controlHeightLarge`, `radiusPill`, Glass, `shadowFloating`; `RowLayout` padding `0 4 0 16`, spacing `space2`:
        - `TextInput`, `echoMode: TextInput.Password`, `body`, `textPrimary`, letter spacing 0.08em; placeholder "Enter password" in `textTertiary`.
        - Submit: round `24px` button (`radiusPill`, `accent`), right arrow glyph in `onAccent`; accessible name "Log in". While Checking it is replaced by the spinner.
        - Focused: focus ring (Build notes) plus `shadowFloating`.
      - **Notice** (Control), pill: `RowLayout` padding `4 12`, spacing `6px`, `radiusPill`, Glass, no shadow; `10px` glyph plus `footnoteMedium` text, both in the tone colour. Tones: `warning` (Caps Lock, up-arrow glyph), `danger` (Wrong password, cross glyph).
      - **Notice with action** (Notice variant, Session failed): padding `6 6 6 14`, spacing `space3`, `radiusPill`, Glass, `shadowFloating`; text `footnoteMedium` in `danger`, then a **Button** primary in pill form.
      - **UnavailableMessage** (screen part, in place of the field): `RowLayout` max width `320px`, padding `12 16`, spacing `10px`, `radiusCard`, Glass, `shadowFloating`; `16px` danger circle-with-bang icon, `footnote` text in `textPrimary`, wrapping.
      - **OtherUsersPill** (screen part, a Glass pill Button): height `controlHeightSmall`, padding `0 12`, spacing `6px`, `radiusPill`, Glass, `shadowRaised`; `12px` two-people glyph and "Other users" in `footnoteMedium`, `textPrimary`. Shown only when there is more than one user.
    - **OptionsButton**: **IconButton** (Control) at right `40px`, bottom `40px` (`28px` short), label "Options", gear glyph. Shown only when more than one Session is installed.
    - **PowerRow** (screen part): `RowLayout` centred, bottom `40px` (`28px` short), spacing `space8`, three **IconButton**s: Sleep (moon), Restart (circular arrow), Shut Down (power).
      - **IconButton** (Control): `ColumnLayout` spacing `6px`: a `40px` circle (`radiusPill`, Glass, `shadowRaised`, `16px` glyph in `textPrimary`), then its label `Text` in `footnoteMedium`, `textPrimary`, on the wallpaper with no backing.
    - **SessionMenu**: **Menu** (Control), see Options open.
  - **UserPanel** (screen part, overlay): `Rectangle` filling the screen in `scrim` (the Content stays at full opacity under it); a centred `Rectangle` `640px` wide, padding `space6`, `radiusPanel`, Glass, `shadowModal`; `ColumnLayout` spacing `space5`, colour `textPrimary`:
    - Title `Text` "Choose a user", `title2`, centred.
    - `GridLayout`, columns `min(count, 4)`, equal widths, row spacing `20px`, column spacing `space3`; one cell per user, in a `Repeater` over the AccountsService users (last user included).
      - Cell: focusable button, `ColumnLayout` padding `10 4`, spacing `space2`, `radiusCard`, transparent; **Avatar** small (`64px`, `shadowRaised`) and name `Text` `footnoteMedium`, centred, wrapping. Highlighted cell: `fillStrong` fill plus the two-tone focus ring.
    - Cancel: **Button** secondary, centred, `controlHeight`, padding `0 16`, `radiusControl`, `fill`, `bodyMedium` `textPrimary`.

### Controls as drawn on the Control states sheet
The sheet matches the screen.
- **Avatar**: circle, image cover. Sizes: `avatarSizeLarge` (96) and small `64px`.
- **PasswordField**: as above, `240px` with the submit button.
- **Button**: two variants, both `bodyMedium`. Primary: pill, `controlHeightSmall`, padding `0 12`, `radiusPill`, `accent` / `onAccent`, `shadowRaised` (Try again). Secondary: `controlHeight`, padding `0 16`, `radiusControl`, `fill` / `textPrimary`, no shadow (Cancel).
- **IconButton**: as above.
- **Menu**: as in Options open; Menu items take the focus ring.
- **Notice**: as above, `warning` and `danger` tones.

## States
The default state is **Ready, dark**, one user, 1920 × 1080. Each state lists only what differs.

### Ready (dark and light)
Trigger: the Greeter starts and greetd is reachable. The last user to log in is shown; the PasswordField is empty and focused (ring shown). Light: theme `light` swaps every colour Token and the wallpaper variant; layout is identical.

### Several users: three and five
Trigger: AccountsService lists more than one human account. Identical to Ready plus the **OtherUsersPill** under the field (the last element in the UserColumn). Three and five users look the same: only the shown user, never a row.

### Other users open: three and eight
Trigger: the OtherUsersPill is activated. A full-screen `scrim` layer covers the screen and the UserPanel opens centred on it. The grid lists every user, the shown user included, in AccountsService order: three users in one row of three columns; eight in two rows of four. One cell is highlighted (keyboard focus, `fillStrong` plus ring), the third in the mockup. Picking a cell closes the panel and makes that user the shown user, with an empty focused field. Cancel or Esc closes it with no change.

### Typing
Trigger: any printable key while the field is focused (typing goes straight in, whatever has focus). The field shows password dots; ring stays.

### Caps Lock on
Trigger: Caps Lock is on while the field is focused (checked on focus and on each key). A `warning` Notice "Caps Lock is on" appears under the field. The field keeps its dots and ring. Hidden when Caps Lock goes off.

### Checking
Trigger: Enter or the submit button with a non-empty field, until greetd answers. Field disabled, opacity `0.7`, no ring (focus is held but not drawn), dots kept. The submit button is replaced by a spinner: an `18px` circle track in `fillStrong` with a quarter arc in `textSecondary`, rotating. Caps Lock Notice hidden.

### Wrong password
Trigger: greetd rejects the password. The field shakes (Interaction and motion), then is cleared; it stays enabled and focused with the ring. A `danger` Notice "Wrong password" shows under the field for three seconds, then fades out. Typing again hides it early. The mockup shows the shake frame at `translateX(-8px)`.

### Session failed
Trigger: authentication succeeded but the Session did not start (greetd `start_session` error, or the Session exits at once). The field is shown empty and unfocused (no ring, `shadowFloating`). Under it, the Notice with action: "Couldn't start the session." in `danger` and a primary pill Button "Try again". Focus moves to Try again (ring shown), so Enter retries. Try again retries the same Session for the same user.

### Login unavailable
Trigger: the greetd socket cannot be reached at start, or the connection drops. The PasswordField, Notices and OtherUsersPill are removed; the UnavailableMessage takes their place under the name: "Login is unavailable. Restart the computer or switch to a text console." The Avatar, name, Clock, Options and power row stay; the power IconButtons still work.

### Options open (dark and light)
Trigger: the Options IconButton (bottom-right) is activated. The Options circle turns `surfaceOverlay` (no blur). The **Menu** opens above it: right `40px`, bottom `112px` (`100px` short), width `220px`, padding `4px`, spacing `2px`, `radiusCard`, Glass, `shadowFloating`.
- Heading "Session" in `footnoteStrong`, `textSecondary`, padding `6 10 4`.
- One `rowHeight` item per installed Session (`radiusSmall`, padding `0 10`, `body`, `textPrimary`, transparent): the current one, KWin, has a `12px` check glyph and spacing `space2`; the others, Hyprland, have left padding `30px` so the labels align.
- The item under the pointer: `accent` fill, `onAccent` text (Hyprland in the mockup). The item with keyboard focus: transparent with the two-tone focus ring.
Picking a Session closes the Menu and remembers it for this user only.

### Starting
Trigger: greetd accepts the login and the Session starts. The wallpaper stays; everything above it (the Content) fades from 1 to 0 over `motionDurationSlow`; the mockup shows the mid-fade frame at opacity `0.35`. When the fade ends the Greeter exits.

### Control states
The sheet (1600 × 900, over the wallpaper, dark). Each Control in default, hover, pressed, focused and disabled:

| Control | Default | Hover | Pressed | Focused | Disabled |
|---|---|---|---|---|---|
| Avatar (64px) | `shadowFloating` | `shadowModal`, scale 1.04 | `shadowRaised`, scale 0.96 | ring plus `shadowFloating` | opacity 0.4, no shadow |
| PasswordField | Glass, `shadowFloating` | `surfaceOverlay`, `shadowFloating` | `surfaceOverlay`, `shadowRaised` | Glass, ring plus `shadowFloating` | Glass, opacity 0.5, no shadow |
| Button primary (pill) | `accent`, `shadowRaised` | `accentHover`, `shadowRaised` | `accentPressed`, no shadow | `accent`, ring | `fill`, `textDisabled`, no shadow |
| Button secondary | `fill`, no shadow | `fillStrong` | `fillStrong` | `fill`, ring | `fill`, `textDisabled` |
| IconButton | Glass, `shadowRaised` | `surfaceOverlay`, `shadowFloating` | `surfaceSunken`, scale 0.95, no shadow | Glass, ring | Glass, glyph `textDisabled`, opacity 0.5, no shadow |
| Menu item | transparent, `textPrimary` | `accent`, `onAccent` | `accentPressed`, `onAccent` | transparent, ring | transparent, `textDisabled` |

"Ring" is the two-tone focus ring (Build notes). The sheet's last row shows the Notice in both tones and the Session Menu, as on the screen. Hover and pressed fills of the PasswordField and IconButton are opaque (`surfaceOverlay`, `surfaceSunken`) and drop the blur.

### Ready at 1366 × 768
Trigger: an output under 900px tall. Clock top `56px`, UserColumn bottom `96px`, power row and Options bottom `28px`; everything else unchanged. The Clock and the UserColumn do not overlap at 768px.

## Interaction and motion

### Keyboard
- **Typing** any printable character puts it in the PasswordField, wherever focus is (except inside the UserPanel or Menu).
- **Enter** in the field submits (ignored when empty). On a focused button, Enter or Space activates it.
- **Esc**: in the field, clears it; in the Menu, closes it and returns focus to Options; in the UserPanel, closes it and returns focus to the OtherUsersPill.
- **← / →** do nothing on the main screen (one user shows). Inside the UserPanel they move between users (↑ / ↓ move between grid rows); Enter picks; Esc closes.
- **↑ / ↓** in the Menu move the highlight; Enter picks.
- **Tab order**: PasswordField → Try again (Session failed only) → OtherUsersPill (when shown) → Options (when shown) → Sleep → Restart → Shut Down, then back to the field. Shift+Tab reverses. Options comes before the power IconButtons in Tab order although it sits bottom-right.
- Focus starts on the PasswordField. Every focusable element shows the focus ring.

### Pointer
- Click the field to focus it; click submit to submit.
- Click OtherUsersPill to open the UserPanel; click a cell to pick; click Cancel or outside the panel to close.
- Click Options to toggle the Menu; click an item to pick; click outside to close.
- Sleep, Restart, Shut Down act at once, with no confirmation.
- Hover and press states per the Control states table, animated over `motionDurationFast` with `motionEasingStandard`.

### Animations
| What | Property | From → to | Duration | Easing | Qt |
|---|---|---|---|---|---|
| Wrong-password shake | PasswordField `x` offset (a `Translate` transform) | keyframes `0, -8, 8, -6, 4, 0` px at 0/20/40/60/80/100% | `2 x motionDurationSlow` (600ms) | `motionEasingSpring` per segment | `SequentialAnimation` of five `NumberAnimation`s of 120ms each, `Easing.BezierCurve` `[0.34, 1.56, 0.64, 1, 1, 1]` (or `Easing.OutBack`) |
| Field clear after shake | text | — | at shake end | — | — |
| Wrong password Notice | `opacity` | 0 → 1, hold 3s, 1 → 0 | `motionDurationNormal` each way | in `motionEasingOut`, out `motionEasingIn` | `Easing.BezierCurve` `[0, 0, 0.2, 1, 1, 1]` / `[0.4, 0, 1, 1, 1, 1]` |
| Caps Lock Notice | `opacity` | 0 ↔ 1 | `motionDurationNormal` | `motionEasingOut` in, `motionEasingIn` out | as above |
| Starting fade | Content `opacity` | 1 → 0 | `motionDurationSlow` | `motionEasingIn` | `Easing.BezierCurve` `[0.4, 0, 1, 1, 1, 1]` |
| Menu open / close | `opacity` 0 → 1, `y` +4px → 0 | | `motionDurationNormal` | open `motionEasingOut`, close `motionEasingIn` | as above |
| UserPanel open / close | scrim layer and panel `opacity` 0 → 1, panel `scale` 0.98 → 1 | | `motionDurationNormal` | open `motionEasingOut`, close `motionEasingIn` | as above |
| Spinner | `rotation` | 0 → 360, loop | 800ms | linear | `RotationAnimator`, `loops: Animation.Infinite` |
| Hover, press | fill colour, `scale` | per Control states | `motionDurationFast` | `motionEasingStandard` | `Easing.BezierCurve` `[0.2, 0, 0, 1, 1, 1]` |

The Menu `y` offset, the panel scale 0.98, and the spinner's 800ms period are not in the mockup (it shows static frames); they are recommendations.

## Assets
| File | Where it is | Used for |
|---|---|---|
| `wallpaper-silk-dark` | `design/wallpaper-default/assets/wallpaper-silk-dark.svg`, shipped as the packaged PNG render (3840 × 2160, or 3840 × 2400 on 16:10) | Greeter wallpaper, dark theme |
| `wallpaper-silk-light` | `design/wallpaper-default/assets/wallpaper-silk-light.svg`, shipped as the PNG render | Greeter wallpaper, light theme |
| `avatar-cat.png`, `avatar-flower.png`, `avatar-ball.png`, `avatar-landscape.png` (192px) | `handoff/assets/`; SVG sources in `refs/sample-avatars/` | **Temporary** sample avatars for the built-in fallback, until `avatars-default` is designed. Not a Hand back deliverable, so not copied to `assets/`. |

The wallpaper is the machine-wide one (Admin override), Silk by default; the theme setting picks light or dark.

Icons are inline SVG in the mockup; there is no icon set yet. All are stroked with `currentColor`, `fill="none"`, round caps where noted:

| Icon | Box | Stroke | Path data |
|---|---|---|---|
| Submit arrow | 12 | 1.6 | `M2 6h8M6.5 2.5L10 6l-3.5 3.5` |
| Caps Lock | 10 | 1.3 | `M5 1L1.5 5H3.5v2.5h3V5h2zM3.5 9h3` |
| Cross (Wrong password) | 10 | 1.4 | `M2.5 2.5l5 5M7.5 2.5l-5 5` |
| Alert (Unavailable) | 16 | 1.5, `danger` | circle `cx 8 cy 8 r 6.5`; `M8 4.5v4.2M8 11v.5` |
| Other users | 12 | 1.3 | circle `cx 4.5 cy 4 r 1.8`; `M1.5 10a3 3 0 0 1 6 0`; circle `cx 8.5 cy 4.5 r 1.5`; `M8 7.3a2.6 2.6 0 0 1 3 2.7` |
| Check (Menu) | 12 | 1.6 | `M2 6.5l2.5 2.5L10 3` |
| Options (gear) | 16 | 1.5 | circle `cx 8 cy 8 r 2.2`; `M8 1.5v2M8 12.5v2M1.5 8h2M12.5 8h2M3.4 3.4l1.4 1.4M11.2 11.2l1.4 1.4M3.4 12.6l1.4-1.4M11.2 4.8l1.4-1.4` |
| Sleep | 16 | 1.5 | `M12.5 10A5.5 5.5 0 0 1 6 3.5a5.5 5.5 0 1 0 6.5 6.5z` |
| Restart | 16 | 1.5 | `M13 8a5 5 0 1 1-1.5-3.6M13 2.5v3h-3` |
| Shut Down | 16 | 1.5 | `M8 1.5v6M4.5 3.8a5 5 0 1 0 7 0` |
| Spinner | 18 | 2, round cap | track circle `cx 9 cy 9 r 7` in `fillStrong`; arc `M9 2a7 7 0 0 1 7 7` in `textSecondary` |

Build them as `Shape`/`PathSvg` or ship them as SVG files in the Greeter's resources, coloured from the Token.

## Build notes
- **Frosted glass.** Cage cannot blur, so the Greeter blurs its own wallpaper (ADR 0001). For each Glass element: a `ShaderEffectSource` of the Wallpaper `Image` with `sourceRect` set to the element's rectangle in screen coordinates, fed to a `MultiEffect` with `blurEnabled: true`, `blurMax` and `blur` set to give a `materialPopoverBlur` (24px) radius, `saturation: materialSaturation - 1` (0.6; MultiEffect saturation runs -1..1 with 0 as unchanged, so this approximates CSS `saturate(1.6)`), masked to the element's shape (`maskEnabled` with a rounded-rect mask), with a `Rectangle` in `materialPopoverTint` on top. Simpler and cheaper: blur the whole wallpaper once into one `MultiEffect` layer (it never moves) and show it through each element's rounded clip; prefer this.
- **Reduce transparency.** When on, skip the blur and draw each Glass element in `materialPopoverFallback`. Every text Token holds contrast on it.
- **Focus ring.** The same two-tone outline on every focusable element (field, Try again, pill, IconButtons, Menu items, UserPanel cells, Cancel): a halo of `focusRingOffset` (2px) in `materialPopoverFallback`, then a ring of `focusRingWidth` (3px) in `focusRing`, both following the element's radius. Build it once in `Modality.Controls` as two `Rectangle`s with `color: "transparent"` and `border.width` of `focusRingOffset` and `focusRingWidth`, sized `2 × focusRingOffset` and `2 × (focusRingOffset + focusRingWidth)` larger than the element, radius grown to match (pill stays pill). The halo is what lets the ring hold 3:1 over any part of the wallpaper.
- **Shadows.** Each shadow Token is a hairline plus a soft shadow: a 1px border at half the hairline's alpha, plus a `MultiEffect` with `shadowEnabled`, `shadowVerticalOffset`, `shadowBlur` and `shadowColor` from the Token. One pass per element: the large Avatar, the field, the pill, four IconButtons, the Menu, the UserPanel, its avatars. Share one shadow component in `Modality.Controls`.
- **Clock.** `font.features: { "tnum": 1 }` on the time so digits do not shift; update once a minute, aligned to the minute.
- **Avatars.** Image clipped to a circle: `MultiEffect` with a circular mask, or `Image` inside a `Rectangle` with `clip` plus `layer.effect`. Source: the AccountsService icon file, else a built-in avatar.
- **Opacity groups.** Content opacity (Starting) on one `Item` with `layer.enabled` during the animation, so overlapping children fade as one.
- **Text on the wallpaper.** The Clock, the name and the IconButton labels have no backing. All pass on Silk (see Settled at intake); a different machine-wide wallpaper must be measured again.
- **Options visibility.** Options shows only when more than one Session is installed; with one, the bottom-right corner is empty. The canvas assumes two.
- **CSS grid.** The UserPanel grid and the Control states sheet use CSS grid; the panel becomes `GridLayout`, the sheet is not built.

## Changes from the brief
- Options and its Session Menu sit bottom-right, not bottom-left: the Options label failed contrast over the dark wallpaper at bottom-left (4.42:1); bottom-right measures 9.3:1. Accepted by the user.
- Tab order adds the Other users pill after the password field: password, Other users, Options, Sleep, Restart, Shut Down. Accepted by the user.

## Settled at intake
- Options shows only when more than one Session is installed; the canvas assumes two (KWin, Hyprland).
- ← and → do nothing on the main screen (one user shows); in the Choose a user panel they move between users, Enter picks, Esc closes.
- Session failed: focus moves to Try again.
- Starting: the wallpaper stays; everything above it fades out over `motionDurationSlow`.
- Text over the wallpaper outside the centre band, measured on Silk (light / dark): date and clock 8.2 / 5.2; power labels 5.2 / 5.1; Options label bottom-right 8.9 / 9.3. All pass.
- Saturation: QML `MultiEffect` `saturation` = `materialSaturation − 1` (0.6), as an approximation.
- `focusRingOffset` is `2px` and `footnoteMedium` / `footnoteStrong` exist, changed in the Foundations at this intake.
