# ModalityOS design context

Read this first, before any brief. It holds what every piece of ModalityOS design work shares. Each piece has its own folder here, `<slug>/`, and its `brief.md` says what to design. Where the brief and this file disagree, the brief wins.

## The product

ModalityOS is an Arch-based Linux OS with its own Shell, Greeter and Apps. It aims for a beautiful look and feel, taking inspiration from the best parts of macOS, Windows and other OSes: calm, spacious, legible, with depth from light shadows and translucency rather than heavy chrome.

Inspired by, never copied. Use no assets, fonts, icons, sounds or product names from Apple, Microsoft or any other OS, and make nothing a person could mistake for a screenshot of another OS.

The words that matter are defined in each brief's **Terms** section. Use each one exactly as the brief writes it: the desktop UI is the "Shell", the login screen is the "Greeter".

## What happens to your design

Each brief names its **kind**. The kind decides what your work becomes:

- **Screen or component:** your HTML is a mockup. It never ships. Claude Code rebuilds it by hand in QML, so design with what QML builds well (next section) and say plainly where you go beyond it.
- **Icon set, illustration, logo:** the files you export are what ships, moved into the OS as they are. Export them clean and complete, at every size the brief lists.

## Screens and components

The Shell and the Greeter run in Quickshell on Wayland; panels and docks are layer-shell surfaces anchored to screen edges. Apps are ordinary Qt 6 windows. All of it is QML.

Design at 1× logical pixels. The brief names the canvas; a full screen is 1920×1080 unless it says otherwise. Keep sizes on a 4 px grid.

**Maps cleanly to QML:**

- Boxes with fill, border and corner radius; linear and radial gradients.
- Flexbox rows and columns (they become `RowLayout` / `ColumnLayout`), fixed sizes, absolute positioning.
- Text with one font, size, weight and colour per run; images and SVG.
- Opacity, scale, rotation and translation.
- Animations with a stated duration and easing curve (`cubic-bezier(...)` values are fine).

**Costs something; use with intent and say where:**

- Drop shadows and blur of the element's own content. Each one is an extra render pass.
- Blur of what sits behind a panel or window (`backdrop-filter`). A Shell surface can't see the windows below it; only the compositor can blur them. Mark every use, so it can be built as a compositor effect or dropped.
- Many animations running at once, or animating layout size.

**Has no direct QML equivalent; avoid, or flag each use:**

- CSS grid template areas, `mix-blend-mode`, chained `filter`s, complex `clip-path`, text effects such as gradient-filled text.

## Tokens

A **token** is a named visual value: a colour, radius, spacing step, font, shadow or motion curve. Tokens are what carries across pieces, so every piece uses them:

- **In CSS:** put every token as a custom property in one `:root` block, grouped by prefix: `--color-*`, `--radius-*`, `--space-*`, `--font-*`, `--shadow-*`, `--motion-*` (durations and easings). Then use only the variables in the rest of the CSS. Claude Code reads that block to name the tokens in code, so a raw value is a value that gets lost.
- **In SVG and images:** take colours from the token palette, and name in the chat which token each colour is.

Reuse the tokens earlier designs defined, and extend them; propose new ones where the design needs them. **Token sets**, one design spec per line (read each one's **Tokens** table):

- None yet.

## By kind

Produce what the brief's kind needs:

- **Screen or component:** every state the brief lists, each reachable in the mockup (a state switcher on one page, or one page per state). Give each component the name the brief uses, as a `data-component="<Name>"` attribute on its root element. Show hover, focus and keyboard states.
- **Icon set** (one icon is a set of one): one SVG per icon, named as the brief names it. Draw on the grid the brief gives, with strokes on whole pixels. Use `currentColor` for single-colour (symbolic) icons. Show each icon at every size the brief lists, on light and dark backgrounds.
- **Illustration** (wallpapers too): SVG where it can be; otherwise PNG at every resolution the brief lists. Wallpapers need a light and a dark variant unless the brief says one.
- **Logo** (brand marks too): SVG, in full-colour and single-colour versions, with clear space and minimum size shown.

## Handing back

When the user says the design is done:

1. Check it against the brief's **Hand back** list, and name each item that is still missing from the design.
2. In the chat, list each decision you changed from the brief and why, and any open question you could not settle.
