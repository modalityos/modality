The Foundations are the Tokens every part of ModalityOS takes its look from: the Shell, the Greeter and every App. Build every screen and Control from these Tokens, never from raw values.

## Character

macOS-first: calm, clear and quietly polished. Frosted glass floats over a colourful wallpaper; warm neutral greys carry the interface; one blue `accent` is the only colour with a voice. Text is compact and crisp, corners soft, motion quick and quiet. Inspired by, never copied: no Apple colours, fonts, icons or window controls.

## Colour

- Ground windows on `bg`. Put grouped settings and cards on `surface-raised`; sink wells to `surface-sunken`; put opaque menus and dialogs on `surface-overlay`.
- Text, fills and separators are translucent, so they take on the colour beneath them. Set text in `text-primary`, supporting text in `text-secondary`, hints and placeholders in `text-tertiary`: all three hold 4.5:1 on every ground, fill and material fallback, in both themes. `text-disabled` is for disabled Controls only.
- Give quiet Controls (secondary buttons, segmented controls, search fields) a `fill` background, `fill-strong` when hovered or pressed and for toggles that are off. Draw the edge of an unfilled Control with `border-strong`; `separator` is decoration only.
- Spend `accent` sparingly: one primary button per view, the selected sidebar row, switches that are on. Put `on-accent` text on it. Links and accent-coloured text use `accent-text`; quiet selection uses `accent-subtle`.
- Status colours (`success`, `warning`, `danger`, `info`) always come with a word or an icon, on any ground or their own `*-subtle` background.
- Dim behind dialogs with `scrim`.
- Every colour has a light and a dark value. The Greeter defaults to dark.

## Wallpaper and materials

- The default wallpaper is a gradient at `wallpaper-angle` through `wallpaper-1`, `wallpaper-2` (at `wallpaper-mid-stop`) and `wallpaper-3`. The Greeter shows it behind everything.
- Three frosted materials sit over it: `material-panel-*` for Shell panels and docks, `material-popover-*` for menus, popovers and the Greeter's login controls, `material-sidebar-*` for App sidebars. Each is a tint over a blurred, saturated background (`material-*-blur`, `material-saturation`), a compositor effect. Where blur is missing, or Reduce transparency is on, use the solid `*-fallback`, which holds every text contrast. The Greeter has no compositor blur, so it blurs its own wallpaper behind its glass.

## Type

- Inter for the interface (`sans`), JetBrains Mono for code and terminal text (`mono`); Noto Sans covers scripts they lack. Chosen over IBM Plex Sans and Plex Mono for being the closest open match to the macOS feel. No other fonts.
- Body text is `body`, 13 px; `body-medium` for button labels, sidebar rows and status messages. Titles step up through `headline`, `title-3`, `title-2`, `title-1` and `large-title`; small text steps down to `footnote` (with `footnote-medium` for labels and `footnote-strong` for small headers) and `caption`.
- `display` is for large clocks (Greeter, lock screen); set clocks and changing numbers with tabular figures.
- Use sentence case for titles, buttons and menu items.

## Size, space and shape

- Keep Controls compact: `control-height` (28 px) for buttons, pop-up buttons and fields, `control-height-small` (24 px) in dense rows and toolbars, `control-height-large` (32 px) for a prominent single field such as the Greeter's password. Sidebar rows and menu items are `row-height`, grouped Settings rows `row-height-large`, window toolbars `toolbar-height`.
- Lay everything on the 4 px grid, `space-1` (4 px) to `space-16` (64 px). Pad grouped boxes with `space-4`, windows and dialogs with `space-8`.
- Round small parts inside a Control (segments, pop-up buttons, icon tiles) with `radius-small`, Controls and sidebar rows with `radius-control`, grouped boxes and popovers with `radius-card`, windows, dialogs and panels with `radius-panel`. Pills, toggles, the password field and avatars use `radius-pill`.

## Elevation

Four levels, each a hairline plus a soft shadow: `shadow-resting` (grouped boxes), `shadow-raised` (filled buttons, switch knobs, the dock), `shadow-floating` (menus, popovers, the login card), `shadow-modal` (windows and dialogs). Keep to these: every shadow costs a render pass.

## Focus

Every focusable element shows a two-tone focus ring: a `focus-ring-offset` halo in the surface colour it sits on, then a `focus-ring` of `focus-ring-width`, so it holds 3:1 over any ground or wallpaper. Never remove it; style it.

## Motion

- `motion-duration-fast` for hover and press, `motion-duration-normal` for most transitions, `motion-duration-slow` for windows, dialogs and the fade from the Greeter into a Session.
- Arrivals use `motion-easing-out`, exits `motion-easing-in`, moves within the screen `motion-easing-standard`.
- `motion-easing-spring` is for small physical feedback only, such as the wrong-password shake.
- Animate opacity and position, not layout size.

## Scenes

SceneSettings and SceneLogin show the Tokens at work in a Settings window and on a login screen, following the Light/Dark switch. They are for judging the look; the Controls in them are drafts, designed properly with the Greeter.
