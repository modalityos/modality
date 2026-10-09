---
name: design-brief
description: Brief the visual work a grill settled as design/<slug>/brief.md, then create its claude.ai design artifact and draft the first design in it.
disable-model-invocation: true
---

Turn the visual work in this conversation into a **brief** per piece, then design it in a **design artifact**: a claude.ai artifact you create and draft from this session, and the user reviews and iterates on. The brief is the agreed record in the repo; the artifact is where the design lives until `/design-intake` reads it back. `design/README.md` carries what every piece shares.

## 1. List the pieces

From the grill in this conversation, or the user's arguments, list each **piece** of visual work still to design and its kind: foundations, screen, component, icon set (one icon is a set of one), illustration (wallpapers too), logo (brand marks too), or a kind you add to `design/README.md` in step 4. One piece is one design artifact and one folder, `design/<slug>/`. The slug names the piece, prefixed by where it lives: `greeter-login`, `shell-dock`, `icons-settings`, `wallpaper-default`; the Foundations are `foundations`.

A piece that already has a `design/<slug>/spec.md` is designed: leave it off the list and name it separately as a design the change builds from, so `/to-spec` cites it. It goes on the list only when the user says that design is to be replaced; then it keeps its slug.

Every piece other than the Foundations is designed with the Foundations' Tokens. With no `design/foundations/spec.md` yet, the Foundations come first: brief and finish them, through `/design-intake`, before briefing any other piece.

Put the list, the slugs and the designs built from to the user. Done when the user agrees them.

Steps 2 to 5 run once per piece; step 6 once for them all.

## 2. Gather the facts

Dispatch subagents for these in parallel:

- What the piece replaces or sits beside: UI under `qml/`, `shell/`, `greeter/` and `apps/`; shipped assets under `data/`.
- Earlier designs under `design/` that it must match.
- `GLOSSARY.md` terms it touches, and ADRs in its area. For a screen, ADR 0003 decides which modules a Shell surface can use versus an App.
- The **Artifact** link and **Tokens** table of `design/foundations/spec.md`.

Copy each source file the design must match into `design/<slug>/refs/`. When the piece changes something that already runs, ask the user to save screenshots of it into `refs/` too: you can't run the Shell, Greeter or Apps; they can.

Done when each fact above is found or known to be absent, and every screenshot you asked for is in `refs/`. Wait for them.

## 3. Settle the gaps

Every brief section below needs a concrete answer. For each one the conversation hasn't settled (a state nobody named, a size, real copy), run the `grilling` skill on those gaps.

Done when every section has a concrete answer or `None`, with every deliverable named one by one.

## 4. Write the brief

Write `design/<slug>/brief.md`:

```markdown
# <Piece name>: design brief

**Kind:** <a kind listed in design/README.md> · **Artifact:** <filled in step 5>

## Purpose
Who sees it, when, and what it does for them. Two or three sentences.

## Decisions
What the grill already decided. Fixed: design within these.

## Terms
Each GLOSSARY.md term the piece uses, with its definition, copied as written.

## What to design
- Foundations: every Token group, one bullet each, with what it covers; every specimen.
- Screen or component: every component, named; every state, one bullet each (empty, loading, error, hover, pressed, focused, disabled, and the piece's own states), with what triggers it.
- Icon set: every icon, one bullet each: name, what it means, where it appears.
- Illustration or logo: every variant, one bullet each (light, dark, single-colour, ...), with where it is used.
- Other: each deliverable, one bullet each.

## Canvas and sizes
Canvas for screens; grid, stroke width and every size for icons; every resolution for illustrations; minimum size for logos; whatever bounds another kind, or None.

## Content
What the piece shows: real copy and sample data for screens, including the longest realistic case; the subject and mood for illustrations and logos; None where nothing applies.

## Reuse
Existing components, designs and Tokens to match, each with what to keep from it. Name each file in refs/ and what it shows.

## Constraints
Anything beyond design/README.md: performance, accessibility (keyboard path, contrast), where the piece is shown.

## Out of scope

## Hand back
The checklist the design must satisfy before intake: every deliverable above, one line each.
```

Done when every section is filled or `None`, **Hand back** lists every deliverable, and **Kind** is one listed in `design/README.md`.

A kind missing from `design/README.md` gets its entry there first (under **What happens to your design** and **By kind**), since that file is what every later piece shares; the brief then only fills in the details.

Then put the brief to the user in a few lines (the Decisions, the states, anything you assumed) and ask whether there is anything to add before you draft. Done when the user says go; fold in anything they add first.

On a redesign, delete the piece's old `spec.md`, `handoff/` and `assets/` in the same commit as the new brief. The last commit keeps them, and a piece with no `spec.md` is one still to design. Draft the redesign in the piece's existing artifact.

## 5. Create the artifact and draft the design

List the artifact types (Artifact `list`, scope `types`) and create the piece's artifact from the type its kind names in `design/README.md`, titled `ModalityOS <Piece name>`, with `auto_open: "after_first_write"`. Follow the instructions the creation returns for that type's files, plus these, learned the hard way:

- **Design System** (Foundations): list `react` and `react-dom` 18 in the index's `libraries` and ship a `components/bundle.js` that assigns `window.<namespace>`; without them every preview is a static picture that ignores the Light/Dark switch. Colour values are hex or `rgba()`; motion goes in its own families (`durations`, `easings`), since the type has no motion family. Fonts are hosted faces with no files: every preview links them from Google Fonts itself, or it renders in a fallback font.
- **Design** (everything else): use the ModalityOS Foundations design system, by the **Artifact** link in `design/foundations/spec.md`, and its Tokens by name; propose a missing Token for the Foundations rather than a raw value.

Draft the whole first design from the brief and `design/README.md`. Before publishing, check every text and boundary colour pair the design uses with a script, in every theme, compositing translucent colours over their ground, against the floors in **Constraints** and `design/README.md`; fix failures before the user sees them.

Fill the brief's **Artifact** line with the link.

Done when the artifact is published with every **Hand back** item drafted, the contrast check passes, and the brief holds the link.

## 6. Commit and hand off

Commit the briefs, `refs/` and any `design/README.md` change: `docs(design): brief <slug>[, <slug>]`.

Open each artifact for the user, then tell them, for each piece, with its link:

1. Review it on its page, in both themes.
2. Ask for changes here, or in a comment on the page sent to Claude, which reaches this session. They can also edit Tokens on the page, or iterate in a claude.ai session of the ModalityOS project with ModalityOS Foundations ticked under **+ → Design system**.
3. When it looks right, run `/design-intake <slug>`.

Artifacts don't belong to claude.ai projects; offer once to pin each one.

Until the user runs `/design-intake`, revise the artifact on request. Read each file before changing it, since the user or another session may have edited it on the page, and keep the contrast check passing.

Then stop.
