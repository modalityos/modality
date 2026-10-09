# ModalityOS Foundations: design spec

**Kind:** foundations · **Brief:** brief.md · **Artifact:** https://claude.ai/artifact/EhfWd8k9vnN7nGN7jH6BU2 · **Source:** handoff/ (1791541273-07dc, 2026-10-09)
**Built by:** not yet built. Implementing replaces this with the spec issue, `#<number>`; from then on the code is the source of truth.

## Tokens
Every Token in `tokens.json` except type styles (see Type). One value in Light for a Token with no theme; Dark is `—`. Font families are not in this table (see Type). Values are CSS strings as the design gives them: colours are `#rrggbb` or `rgba(r, g, b, a)`, shadows are CSS `box-shadow` lists, easings are CSS `cubic-bezier(x1, y1, x2, y2)`. Note marks Tokens that only make sense with a compositor blur ("blur only"): build them as a compositor effect or use the matching `*Fallback`. All Tokens are new in this design (it is the first).

| Token | Light | Dark | Code name | Note |
|---|---|---|---|---|
| `bg` | `#efeeec` | `#1f1e1d` | `bg` | Window ground |
| `surface-raised` | `#ffffff` | `#2b2a28` | `surfaceRaised` | Cards, grouped boxes |
| `surface-sunken` | `#e6e5e3` | `#181716` | `surfaceSunken` | Wells, code blocks |
| `surface-overlay` | `#fbfbfa` | `#2f2e2c` | `surfaceOverlay` | Opaque menus, dialogs |
| `fill` | `rgba(0, 0, 0, 0.05)` | `rgba(255, 255, 255, 0.08)` | `fill` | Quiet Control background |
| `fill-strong` | `rgba(0, 0, 0, 0.1)` | `rgba(255, 255, 255, 0.14)` | `fillStrong` | Hover, pressed, toggle off |
| `separator` | `rgba(0, 0, 0, 0.1)` | `rgba(255, 255, 255, 0.1)` | `separator` | Row dividers, decorative only |
| `border-strong` | `rgba(0, 0, 0, 0.48)` | `rgba(255, 255, 255, 0.42)` | `borderStrong` | Unfilled Control edge, 3:1 |
| `text-primary` | `rgba(0, 0, 0, 0.86)` | `rgba(255, 255, 255, 0.88)` | `textPrimary` | Body and titles |
| `text-secondary` | `rgba(0, 0, 0, 0.64)` | `rgba(255, 255, 255, 0.64)` | `textSecondary` | Labels, metadata |
| `text-tertiary` | `rgba(0, 0, 0, 0.58)` | `rgba(255, 255, 255, 0.56)` | `textTertiary` | Placeholders, hints |
| `text-disabled` | `rgba(0, 0, 0, 0.26)` | `rgba(255, 255, 255, 0.26)` | `textDisabled` | Disabled Controls only |
| `accent` | `#1c6ee8` | `#366bfc` | `accent` | Primary fill, selection, switch on |
| `accent-hover` | `#1862d0` | `#2f62ee` | `accentHover` | Accent under pointer |
| `accent-pressed` | `#1455b8` | `#2858dc` | `accentPressed` | Accent while pressed |
| `accent-subtle` | `rgba(28, 110, 232, 0.14)` | `rgba(80, 150, 255, 0.2)` | `accentSubtle` | Unfocused selected row |
| `on-accent` | `#ffffff` | `#ffffff` | `onAccent` | Text on accent |
| `accent-text` | `#1255b8` | `#8cbcff` | `accentText` | Links, accent text |
| `success` | `#17652f` | `#4fd27a` | `success` | Success text, icons |
| `success-subtle` | `rgba(30, 160, 70, 0.14)` | `rgba(79, 210, 122, 0.16)` | `successSubtle` | Success message background |
| `warning` | `#7a4e00` | `#f5b83d` | `warning` | Warning text, icons |
| `warning-subtle` | `rgba(240, 160, 0, 0.16)` | `rgba(245, 184, 61, 0.16)` | `warningSubtle` | Warning message background |
| `danger` | `#a8231f` | `#ff8f87` | `danger` | Error, destructive |
| `danger-subtle` | `rgba(230, 50, 40, 0.12)` | `rgba(255, 125, 116, 0.12)` | `dangerSubtle` | Danger message background |
| `info` | `#1255b8` | `#8cbcff` | `info` | Info text, icons |
| `info-subtle` | `rgba(28, 110, 232, 0.12)` | `rgba(120, 176, 255, 0.12)` | `infoSubtle` | Info message background |
| `focus-ring` | `#1c6ee8` | `#8cbcff` | `focusRing` | Keyboard focus ring |
| `scrim` | `rgba(0, 0, 0, 0.28)` | `rgba(0, 0, 0, 0.5)` | `scrim` | Dims behind modals |
| `wallpaper-1` | `#6f9dff` | `#1f45c0` | `wallpaper1` | Silk key colour 1; gradient stop 1 where no wallpaper image |
| `wallpaper-2` | `#a98cff` | `#5530b0` | `wallpaper2` | Silk key colour 2; gradient stop 2 |
| `wallpaper-3` | `#ff9fbf` | `#a0306e` | `wallpaper3` | Silk key colour 3; gradient stop 3 |
| `material-panel-tint` | `rgba(246, 245, 243, 0.72)` | `rgba(40, 40, 40, 0.68)` | `materialPanelTint` | Shell panels, docks; blur only, tint over blur |
| `material-panel-fallback` | `#f3f2f0` | `#272624` | `materialPanelFallback` | Shell panels, docks; solid when no blur |
| `material-popover-tint` | `rgba(251, 251, 250, 0.82)` | `rgba(50, 50, 50, 0.8)` | `materialPopoverTint` | Menus, popovers, login card; blur only, tint over blur |
| `material-popover-fallback` | `#fbfbfa` | `#2f2e2c` | `materialPopoverFallback` | Menus, popovers, login card; solid when no blur |
| `material-sidebar-tint` | `rgba(236, 234, 231, 0.68)` | `rgba(30, 30, 30, 0.62)` | `materialSidebarTint` | App sidebars; blur only, tint over blur |
| `material-sidebar-fallback` | `#e9e8e5` | `#242321` | `materialSidebarFallback` | App sidebars; solid when no blur |
| `shadow-resting` | `0 0 0 0.5px rgba(0, 0, 0, 0.08), 0 1px 2px rgba(0, 0, 0, 0.05)` | `0 0 0 0.5px rgba(255, 255, 255, 0.08), 0 1px 2px rgba(0, 0, 0, 0.4)` | `shadowResting` | Grouped boxes, cards |
| `shadow-raised` | `0 0 0 0.5px rgba(0, 0, 0, 0.1), 0 2px 6px rgba(0, 0, 0, 0.1)` | `0 0 0 0.5px rgba(255, 255, 255, 0.1), 0 2px 6px rgba(0, 0, 0, 0.5)` | `shadowRaised` | Filled buttons, dock, knob |
| `shadow-floating` | `0 0 0 0.5px rgba(0, 0, 0, 0.12), 0 10px 30px rgba(0, 0, 0, 0.16)` | `0 0 0 0.5px rgba(255, 255, 255, 0.12), 0 10px 30px rgba(0, 0, 0, 0.55)` | `shadowFloating` | Menus, popovers, login card |
| `shadow-modal` | `0 0 0 0.5px rgba(0, 0, 0, 0.14), 0 22px 60px rgba(0, 0, 0, 0.28)` | `0 0 0 0.5px rgba(255, 255, 255, 0.14), 0 22px 60px rgba(0, 0, 0, 0.65)` | `shadowModal` | Windows, dialogs |
| `space-1` | `4px` | — | `space1` | Icon to its label |
| `space-2` | `8px` | — | `space2` | Gaps inside a Control |
| `space-3` | `12px` | — | `space3` | Gaps between related Controls |
| `space-4` | `16px` | — | `space4` | Padding inside grouped boxes |
| `space-5` | `20px` | — | `space5` | Padding of popovers and the login card |
| `space-6` | `24px` | — | `space6` | Gap between groups in a window |
| `space-8` | `32px` | — | `space8` | Padding of dialogs and window content |
| `space-10` | `40px` | — | `space10` | Gap between sections |
| `space-12` | `48px` | — | `space12` | Large layout gaps |
| `space-16` | `64px` | — | `space16` | Screen-level margins |
| `radius-small` | `6px` | — | `radiusSmall` | Segments, pop-ups, icon tiles |
| `radius-control` | `8px` | — | `radiusControl` | Buttons, text fields, sidebar rows, menu |
| `radius-card` | `12px` | — | `radiusCard` | Grouped boxes, cards, popovers |
| `radius-panel` | `16px` | — | `radiusPanel` | Windows, dialogs, Shell panels, the logi |
| `radius-pill` | `9999px` | — | `radiusPill` | Pills, toggles, the password field, avat |
| `control-height` | `28px` | — | `controlHeight` | Regular buttons, pop-up buttons, text fields |
| `control-height-small` | `24px` | — | `controlHeightSmall` | Small buttons and fields in dense rows and toolbar |
| `row-height` | `28px` | — | `rowHeight` | Sidebar rows and menu items |
| `control-height-large` | `32px` | — | `controlHeightLarge` | Large fields: Greeter password |
| `row-height-large` | `44px` | — | `rowHeightLarge` | Grouped-box items (min) |
| `toolbar-height` | `52px` | — | `toolbarHeight` | Window toolbar |
| `avatar-size-large` | `96px` | — | `avatarSizeLarge` | The selected user's avatar on the Greeter |
| `material-panel-blur` | `30px` | — | `materialPanelBlur` | Shell panels, docks; blur only, compositor effect (blur only) |
| `material-popover-blur` | `24px` | — | `materialPopoverBlur` | Menus, popovers, login card; blur only, compositor effect (blur only) |
| `material-sidebar-blur` | `40px` | — | `materialSidebarBlur` | App sidebars; blur only, compositor effect (blur only) |
| `material-saturation` | `1.6` | — | `materialSaturation` | Saturate with blur (blur only) |
| `wallpaper-angle` | `135deg` | — | `wallpaperAngle` | Wallpaper gradient angle |
| `wallpaper-mid-stop` | `55%` | — | `wallpaperMidStop` | Wallpaper middle stop position |
| `focus-ring-width` | `3px` | — | `focusRingWidth` | Ring stroke |
| `focus-ring-offset` | `1px` | — | `focusRingOffset` | Gap element to ring |
| `motion-duration-fast` | `100ms` | — | `motionDurationFast` | Hover, press |
| `motion-duration-normal` | `200ms` | — | `motionDurationNormal` | Most transitions |
| `motion-duration-slow` | `300ms` | — | `motionDurationSlow` | Panels, dialogs, fade to Session |
| `motion-easing-standard` | `cubic-bezier(0.2, 0, 0, 1)` | — | `motionEasingStandard` | Moves within screen |
| `motion-easing-in` | `cubic-bezier(0.4, 0, 1, 1)` | — | `motionEasingIn` | Leaving screen |
| `motion-easing-out` | `cubic-bezier(0, 0, 0.2, 1)` | — | `motionEasingOut` | Arriving |
| `motion-easing-spring` | `cubic-bezier(0.34, 1.56, 0.64, 1)` | — | `motionEasingSpring` | Overshoot: wrong-password shake |

The two font families live in `tokens.json` `type.families` (the previews read them as `var(--font-sans)` and `var(--font-mono)`): code names `fontSans` and `fontMono`, stacks in Type.

## Raw values
Values the previews use outside a Token. An implementer needs these to match the design.

| Value | Where | Why it stays raw |
|---|---|---|
| `2px` gaps and padding | Sidebar row gap, segmented-control padding and gap, help text top margin, nav button gap, toggle knob inset | Sub-grid spacing inside one Control. |
| `1px` borders | `separator` lines (toolbar bottom, sidebar right edge, row dividers); `border: 1px solid danger` on the shake specimen | Hairline line width. |
| `0.5px` hairline | Inside the shadow Tokens | Already in the shadow Tokens. |
| `216px` sidebar width, `760 x 500` window, `840 x 580` frame, `960 x 540` login canvas | Scenes | Scene layout, not Foundations. |
| Avatar gradient `160deg` from `accentHover` to `accentPressed`; initials `34px` / 600 | Login avatar | Placeholder avatar, designed with the Greeter. |
| Password field `240px` wide, `4px` right padding; go button `24px` circle; Caps hint padding `4px 12px`, gap `6px`; power buttons `40px` circles, label gap `6px`, bottom `20px`; date top margin `48px`, avatar block bottom margin `64px` | Login scene | Draft Controls and layout, designed with the Greeter. |
| Toggle `32 x 18` with `14px` knob; slider track `140 x 4px`, thumb `18px`; accent pop-up dot `10px` | Settings scene | Draft Controls. |
| `20px` sidebar icon tile, `12px` glyph; `24px` window-control circles, `10px` glyph | Settings scene | Draft Controls; the window controls are ModalityOS's own. |
| Text outside the scale: `11px` / `14px` / 600 uppercase, `0.04em` spacing (palette heading); `12px` / `16px` sans (material labels); `15px` for the large "A"; `11px` / 500 (Caps hint, power labels: `footnote` at weight 500) | Scenes and specimens | Specimen labels and draft Controls. |
| Shake keyframes: x offsets `0, -8, 8, -6, 4, 0` px at 0/20/40/60/80/100% of `2 x motionDurationSlow` (600ms) with `motionEasingSpring` | Wrong-password shake | One animation; copy exactly. |

## Type
`Size`, `Line height` and `Letter spacing` are CSS values at 1x. Letter spacing `0` means none is set.

| Style | Family | Size | Line height | Weight | Letter spacing | Code name |
|---|---|---|---|---|---|---|
| `caption` | sans | 10px | 13px | 500 | 0.01em | `caption` |
| `footnote` | sans | 11px | 14px | 400 | 0 | `footnote` |
| `body` | sans | 13px | 16px | 400 | 0 | `body` |
| `body-medium` | sans | 13px | 16px | 500 | 0 | `bodyMedium` |
| `body-strong` | sans | 13px | 16px | 600 | 0 | `bodyStrong` |
| `headline` | sans | 15px | 20px | 600 | 0 | `headline` |
| `title-3` | sans | 15px | 20px | 500 | 0 | `title3` |
| `title-2` | sans | 17px | 22px | 600 | 0 | `title2` |
| `title-1` | sans | 22px | 28px | 600 | -0.01em | `title1` |
| `large-title` | sans | 26px | 32px | 700 | -0.015em | `largeTitle` |
| `display` | sans | 96px | 100px | 600 | -0.03em | `display` |
| `mono` | mono | 12px | 16px | 400 | 0 | `mono` |

Use of each: caption, tiny labels under icons and badges. footnote, helper text and metadata. body, default text. bodyMedium, buttons, sidebar rows and labels needing weight 500. bodyStrong, emphasis and Settings group headings. headline, user names and popover titles. title3, section titles inside a window. title2, window and page titles in the toolbar. title1, dialog titles and the Greeter date. largeTitle, hero titles. display, large clocks, set with tabular figures. mono, code, terminal text and file paths.

| Family | Code name | Stack | Arch package |
|---|---|---|---|
| Sans (interface) | `fontSans` | `Inter, "Noto Sans", system-ui, sans-serif` | `inter-font` |
| Mono (code, terminal) | `fontMono` | `"JetBrains Mono", "Noto Sans Mono", monospace` | `ttf-jetbrains-mono` |
| Fallback sans | in `fontSans` | `Noto Sans`, for scripts Inter lacks | `noto-fonts` |
| Fallback mono | in `fontMono` | `Noto Sans Mono` | `noto-fonts` |

No other fonts. IBM Plex was the alternative pair and was dropped when Inter and JetBrains Mono were chosen.

## Themes
Theme ids: `light` and `dark`. The Greeter defaults to `dark`. Every colour, shadow and material Token (tint and fallback) has a Light and a Dark value. Spacing, radius, size, blur amounts, focus ring width and offset, durations and easings are the same in both. Both themes use slightly warm greys; dark is near-black. Text, fills and separators are translucent black (light) or white (dark), so they take the colour beneath them: composite them over the ground when measuring contrast. The accent, status colours and `focusRing` change hue and lightness between themes, not just opacity. `onAccent` is white in both.

## Usage rules
- Ground windows on `bg`. Grouped settings and cards go on `surfaceRaised`; wells on `surfaceSunken`; opaque menus and dialogs on `surfaceOverlay`.
- Set text in `textPrimary`, supporting text in `textSecondary`, hints and placeholders in `textTertiary`. All three hold 4.5:1 on every ground, fill and material fallback, in both themes. `textDisabled` is for disabled Controls only, never content.
- Give quiet Controls (secondary buttons, segmented controls, search fields) a `fill` background; `fillStrong` when hovered or pressed and for toggles that are off. Draw the edge of an unfilled Control with `borderStrong`; `separator` is decoration only, never the sole boundary of a Control.
- Spend `accent` sparingly: one primary button per view, the selected sidebar row, switches that are on. Put `onAccent` text on it; use `accentHover` and `accentPressed` for its states. Links and accent text use `accentText`; quiet selection uses `accentSubtle`.
- Status colours (`success`, `warning`, `danger`, `info`) always come with a word or icon, on any ground or on their own `*Subtle` background, never colour alone.
- Dim behind dialogs with `scrim`.
- The default wallpaper is a diagonal gradient through `wallpaper1`, `wallpaper2`, `wallpaper3`. The Greeter shows it behind everything.
- Materials: `materialPanel*` for Shell panels and docks, `materialPopover*` for menus, popovers and the Greeter's login controls, `materialSidebar*` for App sidebars. Each is a tint over a background blurred by its `*Blur`, a compositor effect. Where blur is missing (the Greeter in Cage) use the solid `*Fallback`; the design must look right with the fallback alone. Every text Token holds contrast on it.
- Type: `fontSans` for the interface, `fontMono` for code. Body text is `body` (13px); titles step up through `headline`, `title3`, `title2`, `title1`, `largeTitle`; small text steps down through `footnote` and `caption`. `display` is for large clocks (Greeter, lock screen). Sentence case for titles, buttons and menu items.
- Size and space: `controlHeight` (28px) for buttons, pop-up buttons and fields; `controlHeightSmall` (24px) in dense rows and toolbars; `rowHeight` for sidebar rows and menu items; `avatarSizeLarge` (96px) for the Greeter avatar. Lay everything on the 4px grid, `space1` to `space16`; pad grouped boxes with `space4`, windows and dialogs with `space8`.
- Shape: `radiusControl` for Controls and sidebar rows; `radiusCard` for grouped boxes and popovers; `radiusPanel` for windows, dialogs, Shell panels and the login card; `radiusPill` for pills, toggles, the password field and avatars.
- Elevation: four levels only, each a 0.5px hairline plus a soft shadow: `shadowResting` (grouped boxes), `shadowRaised` (filled buttons, switch knobs, the dock), `shadowFloating` (menus, popovers, the login card), `shadowModal` (windows, dialogs). Each shadow is a render pass.
- Focus: every focusable element shows a `focusRing` stroke of `focusRingWidth`, `focusRingOffset` outside it, 3:1 on every ground. Never remove it; style it.
- Motion: `motionDurationFast` for hover and press, `motionDurationNormal` for most transitions, `motionDurationSlow` for windows, dialogs and the fade from the Greeter into a Session. Arrivals use `motionEasingOut`, exits `motionEasingIn`, moves within the screen `motionEasingStandard`. `motionEasingSpring` is only for small physical feedback such as the wrong-password shake. Animate opacity and position, not layout size.
- Accessibility: WCAG AA (4.5:1 body, 3:1 large text and UI boundaries), measured with translucent colours composited over their ground.

## Scenes
Reference for the later Greeter design. Not a build target; the Controls in them are drafts. Both follow the Light/Dark switch and are built only from Tokens.

**SceneSettings** (760 x 500 window, `radiusPanel`, `shadowModal`, over the wallpaper in an 840 x 580 frame). Left a 216px frosted sidebar (`materialSidebarTint` with blur, `separator` right edge): a search field (`fill`, `controlHeight`, `radiusControl`) then rows (`rowHeight`, `radiusControl`) for Wi-Fi, Bluetooth, Network, Appearance (selected: `accent` fill, `onAccent` text), Displays, Sound, Notifications, Users, Privacy, each with a 20px coloured icon tile. Right a `toolbarHeight` toolbar (back and forward, title "Appearance" in `title2`, three plain window controls on `fill` circles), then the page on `bg`: group "Look" (Theme segmented Light / Dark / Auto; Accent colour as a single "Blue" pop-up; Show scroll bars pop-up "When scrolling") and group "Accessibility" (Reduce transparency toggle with a wrapping help line in `footnote`; Tint windows with the wallpaper toggle on; Text size slider), grouped boxes on `surfaceRaised`, `radiusCard`, `shadowResting`, items `space4` padding with `separator` between. Footer: secondary "Restore defaults" (shows the focus ring) and primary "Apply".

**SceneLogin** (960 x 540 over the wallpaper). Top centre: date "Friday 9 October" in `title1`, clock "09:41" in `display`. Lower centre: 96px avatar "JD" (`avatarSizeLarge`, `radiusPill`, `shadowFloating`), name "John Doe" in `headline`, a pill password field (`controlHeightLarge`, `materialPopoverTint` with blur, `shadowFloating`, focus ring shown) with an accent round submit button, and a Caps Lock hint pill ("Caps Lock is on", `warning`, `footnote`-size). At the bottom, Sleep, Restart and Shut Down as 40px round popover-material buttons with `footnote`-size labels. In the Greeter the materials use their `*Fallback`.

## Changes from the brief
- Fonts: IBM Plex Sans and Plex Mono removed, and the font-pairing specimen with them, after the user chose Inter with JetBrains Mono during design. Noto Sans stays as the fallback inside each stack.
- Added Tokens the brief did not list: `avatarSizeLarge`, `radiusSmall`, `controlHeightLarge`, `rowHeightLarge`, `toolbarHeight`, `materialSaturation`, `wallpaperAngle`, `wallpaperMidStop`, `bodyMedium`; each covers a value the scenes needed.
- The Settings scene shows the accent as a single "Blue" pop-up, not a row of alternatives, matching "no alternative accents yet".

## Settled at intake

- `wallpaper-1` to `wallpaper-3` follow the Silk default wallpaper's key colours (`design/wallpaper-default/spec.md`), changed at that piece's intake; the Foundations artifact was updated to match.
- The spring is a cubic-bezier with overshoot, as decided ("one gentle spring curve"); in QML use `Easing.BezierCurve` with the same control points, or `Easing.OutBack` where a bezier is impractical.
- Translucent colours become Qt colours with alpha (`Qt.rgba` or `#AARRGGBB`); the code module stores them as given.
- Easings become `Easing.BezierCurve` with the four control points.
- Shadows: the 0.5px hairline is a 1px border at half opacity (or a 0.5px border on high-DPI); the soft shadow is a `MultiEffect` shadow with the same offset, blur and colour.
- Blur and `materialSaturation` are compositor effects; where unavailable, the `*Fallback` colour is used. The Greeter always uses fallbacks (Cage cannot blur).
- Font families live in `tokens.json` `type.families`, not as colour-style Tokens; code names `fontSans` and `fontMono`.
- Dark mode greys are warm, matching "slightly warm greys".
