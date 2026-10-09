# Foundations: design brief

**Kind:** foundations · **Artifact:** https://claude.ai/artifact/EhfWd8k9vnN7nGN7jH6BU2

## Purpose
The Foundations are the Tokens every part of ModalityOS takes its look from: the Shell, the Greeter and every App. Nobody sees them as a screen; everyone sees them in every screen. This is the first ModalityOS design, and the first screen built on it is the Greeter, the login screen.

## Decisions
- **Mood:** calm neutral greys and generous spacing (macOS); tinted, translucent surfaces (Windows 11's Mica material); large, soft corners and clean, confident type (HarmonyOS). Take the feel, never the assets.
- **Light and dark:** every colour, material and shadow Token has a light and a dark value. The Greeter defaults to dark.
- **Accent:** one default accent colour, which you propose. Not Apple's system blue. Structure the accent as a small set of Tokens (base, hover, pressed, subtle background, text on accent) so a later accent picker swaps the whole set at once. No alternative accents yet.
- **Fonts:** Inter for the interface, JetBrains Mono for code and terminal text. IBM Plex Sans with IBM Plex Mono is the alternative to compare in the proof strip; the user picks in this project, and Inter wins if they don't. Noto Sans is the fallback for scripts the main font lacks. No other fonts.
- **Base size:** 14 px body text at 1×. Propose the full type scale around it.
- **Spacing:** a 4 px grid.
- **Corner radius:** about 8 px for Controls, 12 px for cards, 16 px for panels and windows, plus a fully rounded pill. Adjust if the design needs it.
- **Translucency:** every translucent surface Token comes with a blur amount and a solid fallback colour, and the design must look right with the fallback alone. The Greeter's compositor can't blur, and blur elsewhere becomes a compositor effect.
- **Motion:** calm and quick. Three durations, roughly 100, 200 and 300 ms; standard, ease-in and ease-out curves; one gentle spring for small physical feedback such as a wrong-password shake.
- **Accessibility:** text meets WCAG AA contrast in both themes (4.5:1 for body text, 3:1 for large text and for UI boundaries). The focus ring has its own Tokens and stays clearly visible on every surface.

## Terms
- **Token**: A named visual value, such as a colour, corner radius, spacing step, font, shadow or motion curve, that every piece of the UI takes its look from.
- **Foundations**: The base set of Tokens that the Shell, the Greeter and every App share.
- **Control**: A reusable piece of UI, such as a button, password field or avatar, shared by the Shell, the Greeter and Apps.
- **Shell**: The always-present desktop UI drawn over the Session compositor: panels, dock, widgets, overlays.
- **Greeter**: The login screen the user sees before a Session starts: password entry, user and Session choice.
- **App**: A standalone program with its own windows, such as Settings or Files, that is not part of the Shell.

## What to design
One HTML token sheet, every Token in the `:root` blocks, each group shown as a specimen:

- **Background and surfaces:** window background; surfaces at raised, sunken and overlay levels; separators and borders.
- **Text:** primary, secondary, tertiary, disabled, and text on accent; each with its contrast ratio against the surfaces it sits on.
- **Accent set:** base, hover, pressed, subtle background, text on accent.
- **Status colours:** success, warning, danger and info, each with a foreground and a subtle background.
- **Scrim:** the dimming layer behind modal overlays.
- **Materials:** at least three translucent surfaces (panel, popover, sidebar), each with tint, opacity, blur and solid fallback, shown over a busy background and as the fallback.
- **Type:** the font families (sans, mono, fallback), and each role in the scale (caption, footnote, body, body strong, headline, titles, a large display size for things like a clock) with size, line height, weight and letter spacing.
- **Spacing:** the 4 px scale as a ruler.
- **Radius:** Control, card, panel and window, pill.
- **Shadows:** a few elevation levels (resting, raised, floating, modal), in both themes.
- **Focus ring:** colour, width and offset, shown on light and dark surfaces and on the accent.
- **Motion:** each duration and easing curve, with a replay button; the spring shown as a short shake.
- **Proof strip:** a plain card holding a heading, body text, secondary text, a primary and a secondary button, and one focused element, built only from the Tokens. Show it twice, in Inter with JetBrains Mono and in IBM Plex Sans with IBM Plex Mono, in both themes.

## Canvas and sizes
One scrolling page, 1440 px wide, at 1× logical pixels. Sizes on the 4 px grid.

## Content
No real copy needed. Use plain sample text in the specimens and the proof strip, including one long line that wraps and the numbers `09:41` and `100%` to show figure widths. Mood: calm, spacious, legible, with depth from light shadows and translucency rather than heavy chrome.

## Reuse
None. This is the first design, so there are no earlier Tokens or Controls to match.

## Constraints
- Keep the number of shadow levels small: each shadow is an extra render pass.
- Mark every Token that only makes sense with blur, so it can be built as a compositor effect or fall back.

## Out of scope
- Controls (buttons, fields, avatars, menus) beyond the plain card and buttons in the proof strip. They are designed with the Greeter.
- Screens, icons, wallpapers and logos.
- Alternative accent colours and a high-contrast theme.

## Hand back
- [ ] The token sheet HTML, every Token defined in `:root` and overridden in `:root[data-theme="dark"]`, grouped by prefix
- [ ] Background, surface, separator and border colours, light and dark
- [ ] Text colours with contrast ratios, light and dark
- [ ] Accent set: base, hover, pressed, subtle background, text on accent
- [ ] Status colours: success, warning, danger, info, each foreground and subtle background
- [ ] Scrim colour
- [ ] At least three materials, each with tint, opacity, blur and solid fallback
- [ ] Font family Tokens: sans, mono, fallback
- [ ] Type scale, every role with size, line height, weight and letter spacing
- [ ] Spacing scale on the 4 px grid
- [ ] Radius Tokens: Control, card, panel and window, pill
- [ ] Shadow levels, light and dark
- [ ] Focus ring Tokens: colour, width, offset
- [ ] Motion Tokens: three durations, standard, ease-in and ease-out curves, one spring
- [ ] Proof strip in both font pairings and both themes
- [ ] The chosen font pairing, stated in `HANDBACK.md`
