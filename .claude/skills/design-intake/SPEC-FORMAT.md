# Design spec format

Every `design/<slug>/spec.md` starts with the shared head, then the sections for its kind, then the shared tail. Use `GLOSSARY.md` terms throughout. An implementer builds from the design spec without opening `handoff/`, so every value, name and file is in it.

## Shared head

```markdown
# <Piece name>: design spec

**Kind:** <kind> · **Brief:** brief.md · **Artifact:** <link> · **Source:** handoff/ (<version id>, <date of this intake>)
**Built by:** not yet built. Implementing replaces this with the spec issue, `#<number>`; from then on the code is the source of truth.

## Tokens
| Token | Light | Dark | Code name | Note |
|---|---|---|---|---|
One row per Token the design uses: for the Foundations every Token in `tokens.json`; for other kinds each `var(--…)` the design reads, or each palette colour an SVG or image uses. One value in Light for a Token with no theme. Code name is the Token name in camelCase: surface-raised → surfaceRaised, motion-duration-fast → motionDurationFast. Note marks Tokens new in this design. `None` if the design uses no Tokens.

## Raw values
Values the design uses outside a Token, each with why it stays raw. `None` if every value is a Token.
```

## Foundations

```markdown
## Type
| Style | Family | Size | Line height | Weight | Letter spacing | Code name |
|---|---|---|---|---|---|---|
One row per type style, plus each font family with its fallback stack and the Arch package that ships it.

## Themes
The theme ids, which one is the default where, and what changes between them.

## Usage rules
The design system's README rules, kept as rules an implementer applies: which Token for which job.
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
|---|---|---|---|
One row per icon from the brief. Extract each SVG to assets/<name>.svg, exactly as drawn.
```

## Illustration or logo

```markdown
## Files
| File | Variant | Size or resolution | Use |
|---|---|---|---|
One row per delivered file, extracted to assets/.

## Usage rules
Which variant goes on which background; for logos, clear space and minimum size.
```

## Other

The deliverables the brief listed, one section each, at the same precision as the kinds above.

## Shared tail

```markdown
## Changes from the brief
Each change from the brief that the user accepted, and why. `None` if there were none.

## Settled at intake
Each gap the design left open, and how it was settled: by research, or by the user's answer. `None` if there were none.
```
