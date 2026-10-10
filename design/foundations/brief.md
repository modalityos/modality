# Foundations: design brief

**Kind:** foundations · **Artifact:** https://claude.ai/artifact/EhfWd8k9vnN7nGN7jH6BU2

## Purpose
The Foundations are the Tokens every part of ModalityOS takes its look from: the Shell, the Greeter and every App. Nobody sees them as a screen; everyone sees them in every screen. This is the first ModalityOS design, and the first screen built on it is the Greeter, the login screen.

## Decisions
- **Direction:** macOS is the main reference: the look and feel of its login screen and System Settings (Sonoma and later). Windows and HarmonyOS only where macOS has no answer. Take the feel, never the assets: no Apple colours, fonts, icons or window controls, nothing mistakable for a macOS screenshot.
- **Light and dark:** every colour, material and shadow Token has a light and a dark value. The Greeter defaults to dark.
- **Accent:** a macOS-style blue, close to but not Apple's system blue. Structure it as a small set of Tokens (fill, hover, pressed, subtle background, text on accent, accent as text) so a later accent picker swaps the whole set at once. No alternative accents yet.
- **Neutrals:** slightly warm greys. Text, fills and separators are translucent black (light) or white (dark), so they take on the colour beneath them. Dark mode is near-black, not blue-grey.
- **Fonts:** Inter for the interface, JetBrains Mono for code and terminal text. IBM Plex Sans with IBM Plex Mono is the alternative to compare; the user picks, and Inter wins if they don't. Noto Sans is the fallback for scripts the main font lacks. No other fonts.
- **Base size:** 13 px body text at 1×, with compact Controls 24 to 28 px tall. If 13 px reads too small, it goes back to 14 px.
- **Spacing:** a 4 px grid.
- **Corner radius:** about 8 px for Controls, 12 px for cards, 16 px for panels and windows, plus a fully rounded pill. Adjust if the design needs it.
- **Translucency and wallpaper:** the look rests on frosted materials over a colourful wallpaper. Every translucent surface Token comes with a blur amount and a solid fallback colour, and the design must look right with the fallback alone: the Greeter's compositor can't blur, and blur elsewhere becomes a compositor effect. The Greeter shows a colourful gradient wallpaper made from Tokens.
- **Motion:** calm and quick. Three durations, roughly 100, 200 and 300 ms; standard, ease-in and ease-out curves; one gentle spring for small physical feedback such as a wrong-password shake.
- **Accessibility:** text meets WCAG AA contrast in both themes (4.5:1 for body text, 3:1 for large text and for UI boundaries), measured with translucent colours composited over their ground. The focus ring has its own Tokens and stays clearly visible on every surface.

## Terms
- **Token**: A named visual value, such as a colour, corner radius, spacing step, font, shadow or motion curve, that every piece of the UI takes its look from.
- **Foundations**: The base set of Tokens that the Shell, the Greeter and every App share.
- **Control**: A reusable piece of UI, such as a button, password field or avatar, shared by the Shell, the Greeter and Apps.
- **Shell**: The always-present desktop UI drawn over the Session compositor: panels, dock, widgets, overlays.
- **Greeter**: The login screen the user sees before a Session starts: password entry, user and Session choice.
- **App**: A standalone program with its own windows, such as Settings or Files, that is not part of the Shell.

## What to design
A Design System artifact: every Token in `tokens.json`, a README of usage rules, and these specimens:

- **Grounds and surfaces:** window background; surfaces at raised, sunken and overlay levels; translucent fills for Control backgrounds; separators and Control borders.
- **Text:** primary, secondary, tertiary, disabled, text on accent.
- **Accent set:** fill, hover, pressed, subtle background, text on accent, accent as text.
- **Status colours:** success, warning, danger and info, each with a foreground and a subtle background.
- **Scrim:** the dimming layer behind modal overlays.
- **Wallpaper:** the gradient stops of the default wallpaper, light and dark.
- **Materials:** at least three translucent surfaces (panel, popover, sidebar), each with tint, blur and solid fallback, shown over the wallpaper and as the fallback.
- **Type:** the font families (sans, mono, fallback, and the alternative pair), and each role in the scale (caption, footnote, body, body strong, headline, titles, a large display size for clocks) with size, line height, weight and letter spacing.
- **Sizes:** Control heights (regular and small) and sidebar row height.
- **Spacing:** the 4 px scale.
- **Radius:** Control, card, panel and window, pill.
- **Shadows:** a few elevation levels (resting, raised, floating, modal), in both themes.
- **Focus ring:** colour, width and offset.
- **Motion:** each duration and easing curve, with a replay button; the spring shown as a short shake.
- **Palette in use:** the surfaces stacked as layers with every text level on each, the accent as buttons in their states, and status colours as messages; light and dark side by side.
- **Scene, Settings:** a Settings window over the wallpaper: frosted sidebar with a search field and a selected row, toolbar, title, grouped rows with toggles, pop-up buttons and a slider, primary and secondary buttons, one focused element.
- **Scene, Login:** a login screen over the wallpaper: large clock and date, avatar with name, password field with a submit button, Caps Lock hint, Sleep / Restart / Shut Down at the bottom.
- **Font pairing:** the same short passage and a Settings group in Inter with JetBrains Mono and in IBM Plex Sans with IBM Plex Mono.

## Canvas and sizes
Scenes at 1× logical pixels: the Settings window about 760 × 500, the Login screen at 960 × 540 (a scaled 1920 × 1080). Sizes on the 4 px grid.

## Content
Real-looking copy. Settings: sidebar items Wi-Fi, Bluetooth, Network, Appearance, Displays, Sound, Notifications, Users, Privacy; the Appearance page with Theme, Accent colour, Show scroll bars, Reduce transparency, Text size. Login: user "John Doe", time `09:41`, date "Friday 9 October". Include one long line that wraps.

## Reuse
None. This is the first design, so there are no earlier Tokens or Controls to match.

## Constraints
- Keep the number of shadow levels small: each shadow is an extra render pass.
- Mark every Token that only makes sense with blur, so it can be built as a compositor effect or fall back.
- Window controls in the Settings scene are ModalityOS's own, not coloured traffic lights.

## Out of scope
- Final Controls: the buttons, fields, toggles and avatar in the scenes show the Tokens at work; the Controls themselves are designed with the Greeter.
- The final default wallpaper artwork, icons and logos.
- Alternative accent colours and a high-contrast theme.

## Hand back
- [x] Grounds, surfaces, fills, separator and border colours, light and dark
- [x] Text colours, light and dark, each passing its contrast floor on every ground
- [x] Accent set: fill, hover, pressed, subtle background, text on accent, accent as text
- [x] Status colours: success, warning, danger, info, each foreground and subtle background
- [x] Scrim colour
- [x] Wallpaper gradient stops, light and dark
- [x] At least three materials, each with tint, blur and solid fallback
- [x] Font family Tokens: sans, mono, fallback, alternative pair
- [x] Type scale, every role with size, line height, weight and letter spacing
- [x] Control and row heights
- [x] Spacing scale on the 4 px grid
- [x] Radius Tokens: Control, card, panel and window, pill
- [x] Shadow levels, light and dark
- [x] Focus ring Tokens: colour, width, offset
- [x] Motion Tokens: three durations, standard, ease-in and ease-out curves, one spring
- [x] Palette in use, light and dark side by side
- [x] Settings scene and Login scene, following the Light/Dark switch
- [x] Font pairing specimen, and the user's pick recorded in the README
