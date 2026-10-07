# Design spec format

Every `design/<slug>/spec.md` starts with the shared head, then the sections for its kind, then the shared tail. Use `GLOSSARY.md` terms throughout. An implementer builds from the spec without opening `handoff/`, so every value, name and file is in it.

## Shared head

```markdown
# <Piece name>: design spec

**Kind:** <kind> · **Brief:** brief.md · **Source:** handoff/ (<date of this intake>)
**Built by:** not yet built. Implementing replaces this with the spec issue, `#<number>`; from then on the code is the source of truth.

## Tokens
| Token | Value | Code name | Note |
One row per token the design uses: each CSS custom property, or each palette colour an SVG or image uses. Code name is the token in camelCase: --color-surface-raised → colorSurfaceRaised. Note marks tokens new in this design. `None` if the design uses no tokens.

## Raw values
Values the CSS uses outside a token, each with why it stays raw. `None` if every value is a token, or there is no CSS.
```

## Screen or component

```markdown
## Components
The tree, top down, one line per node: data-component name, QML type (RowLayout, Rectangle, Text, Image, ListView, ...), and the tokens and sizes that place it. Name existing components to reuse instead of rebuilding them.

## States
One subsection per state from the brief: what triggers it, and only what differs from the default state.

## Interaction and motion
Every input (pointer, keyboard, focus order) and what it does. Every animation: property, from, to, duration and easing token, with the Qt easing type that matches the cubic-bezier (Easing.OutCubic, ...) or the bezier itself.

## Assets
Each image or SVG the mockup uses, extracted to assets/, with where it is used.

## Build notes
Each costly or unmapped mockup feature (design/README.md lists them), with its QML approach. Shell surfaces: name any compositor effect needed, such as background blur.
```

## Icon set

```markdown
## Grid
Grid size, stroke width, corner radius, colour handling (currentColor or fixed palette).

## Icons
| Name | Meaning | File | Sizes |
One row per icon from the brief. Extract each SVG to assets/<name>.svg, exactly as drawn.
```

## Illustration or logo

```markdown
## Files
| File | Variant | Size or resolution | Use |
One row per delivered file, extracted to assets/.

## Usage rules
Which variant goes on which background; for logos, clear space and minimum size.
```

## Other

The deliverables the brief listed, one section each, at the same precision as the kinds above.

## Shared tail

```markdown
## Changes from the brief
Each change Claude Design made that the user accepted, and why. `None` if there were none.

## Settled at intake
Each gap the design left open, and how it was settled: by research, or by the user's answer. `None` if there were none.
```
