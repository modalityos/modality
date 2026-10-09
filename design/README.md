# ModalityOS design context

Read this first, before any brief: whoever designs a piece reads it, whether Claude Code drafting the design artifact or Claude in a claude.ai session iterating on it. It holds what every piece of ModalityOS design work shares. Each piece has its own folder here, `<slug>/`, and its `brief.md` says what to design. Where the brief and this file disagree, the brief wins.

## The product

ModalityOS is an Arch-based Linux OS with its own Shell, Greeter and Apps. It aims for a beautiful look and feel, taking inspiration from the best parts of macOS, Windows, HarmonyOS and other OSes: calm, spacious, legible, with depth from light shadows and translucency rather than heavy chrome.

Inspired by, never copied. Use no assets, fonts, icons, sounds or product names from Apple, Microsoft, Huawei or any other OS, and make nothing a person could mistake for a screenshot of another OS.

The words that matter are defined in each brief's **Terms** section. Use each one exactly as the brief writes it: the desktop UI is the "Shell", the login screen is the "Greeter".

## What happens to your design

Each piece lives in a claude.ai design artifact until `/design-intake` snapshots it into `<slug>/handoff/`. Each brief names its **kind**, and the kind decides the artifact type and what your work becomes:

- **Foundations** (a **Design System** artifact): your Token values are what ships. Claude Code copies every Token in `tokens.json` into the OS's token module under the same name; the specimens never ship.
- **Screen or component** (a **Design** artifact): your design is a mockup. It never ships. Claude Code rebuilds it by hand in QML, so design with what QML builds well (next section) and say plainly where you go beyond it.
- **Icon set, illustration, logo** (a **Design** artifact): the files you produce are what ships, moved into the OS as they are. Make them clean and complete, at every size or variant the brief lists.

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

A **Token** is a named visual value: a colour, material, radius, spacing step, font, shadow, focus ring or motion curve. The Foundations define them, in the ModalityOS Foundations design system, and every other piece uses them:

- **The Foundations** keep every Token in `tokens.json`, with a light and a dark value for each colour and shadow, and a usage note naming where it is used.
- **Every other piece** uses the Foundations' Tokens by name (`var(--surface-raised)`), never raw values. Claude Code reads those names to build the code, so a raw value is a value that gets lost. Where the design needs a Token the Foundations lack, propose it for the Foundations.
- **SVG and images** take colours from the Token palette; name the Token each colour is in the piece's notes.

## Accessibility

Text holds WCAG AA contrast in every theme: 4.5:1 for body text, 3:1 for large text and for Control boundaries, focus rings and meaningful icons. Every focusable element shows the focus ring.

## By kind

Produce what the brief's kind needs:

- **Foundations:** every Token in `tokens.json`, in light and dark; a README of usage rules that name Tokens; specimen previews for what the Token views don't show (materials over a busy background with their solid fallbacks, motion demos you can replay); the palette in use, light and dark side by side; and one or two scenes the brief names (a Settings window, a login screen), built only from the Tokens, so the look is judged in context rather than as swatches.
- **Screen or component:** every state the brief lists, each reachable in the mockup (a state switcher, or one artboard per state). Give each component the name the brief uses. Show hover, focus and keyboard states.
- **Icon set** (one icon is a set of one): one SVG per icon, named as the brief names it. Draw on the grid the brief gives, with strokes on whole pixels. Use `currentColor` for single-colour (symbolic) icons. Show each icon at every size the brief lists, on light and dark backgrounds.
- **Illustration** (wallpapers too): SVG where it can be; otherwise PNG at every resolution the brief lists. Wallpapers need a light and a dark variant unless the brief says one.
- **Logo** (brand marks too): SVG, in full-colour and single-colour versions, with clear space and minimum size shown.

## When it's done

Check the design against the brief's **Hand back** list. Say plainly what is missing, which Decision you changed and why, and any question you could not settle, so the user can decide before running `/design-intake`.
