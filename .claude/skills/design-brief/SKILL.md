---
name: design-brief
description: Brief Claude Design on the visual work a grill settled, as design/<slug>/brief.md, ready to take to claude.ai/design.
disable-model-invocation: true
---

Turn the visual work in this conversation into a **brief** per piece: a self-contained document Claude Design designs from. Claude Design can't see this conversation or the repo, only the files the user attaches. So each brief, with its `refs/`, carries everything its design depends on, and `design/README.md` carries what every brief shares.

## 1. List the pieces

From the grill in this conversation, or the user's arguments, list each **piece** of visual work and its kind: screen, component, icon set (one icon is a set of one), illustration (wallpapers too), logo, or a kind you add to `design/README.md` in step 4. One piece is one Claude Design project and one folder, `design/<slug>/`. The slug names the piece, prefixed by where it lives: `greeter-login`, `shell-dock`, `icons-settings`, `wallpaper-default`. A redesign of an existing piece reuses its slug.

Put the list and slugs to the user. Done when the user agrees the list.

Steps 2 to 4 run once per piece; step 5 once for them all.

## 2. Gather the facts

Facts are your job; dispatch subagents for them in parallel:

- What the piece replaces or sits beside: UI under `qml/`, `shell/`, `greeter/` and `apps/`; shipped assets under `data/`.
- Earlier designs under `design/` that it must match.
- `GLOSSARY.md` terms it touches, and ADRs in its area. For a screen, ADR 0003 decides which modules a Shell surface can use versus an App.
- The token sets listed in `design/README.md`.

Copy each source file the design must match into `design/<slug>/refs/`, so the attached files hold it. When the piece changes something that already runs, ask the user to save screenshots of it into `refs/` too: you can't run the Shell, Greeter or Apps; they can.

Done when each fact above is found or known to be absent, and every screenshot you asked for is in `refs/`. Wait for them.

## 3. Settle the gaps

Every brief section below needs a concrete answer. For each one the conversation hasn't settled (a state nobody named, a size, real copy), run the `grilling` skill on those gaps. Decisions are the user's.

Done when every section has a concrete answer or `None`: every deliverable named, with no "etc.".

## 4. Write the brief

Write `design/<slug>/brief.md`:

```markdown
# <Piece name>: design brief

**Kind:** <screen | component | icon set | illustration | logo | a kind listed in design/README.md> · **Branch:** <current git branch>

## Purpose
Who sees it, when, and what it does for them. Two or three sentences.

## Decisions
What the grill already decided. Fixed: design within these.

## Terms
Each GLOSSARY.md term the piece uses, with its definition, copied as written.

## What to design
- Screen or component: every state, one bullet each (empty, loading, error, hover, pressed, focused, disabled, and the piece's own states), with what triggers it.
- Icon set: every icon, one bullet each: name, what it means, where it appears.
- Illustration or logo: every variant, one bullet each (light, dark, single-colour, ...), with where it is used.
- Other: each deliverable, one bullet each.

## Canvas and sizes
Canvas for screens; every size for icons; every resolution for illustrations; minimum size for logos; whatever bounds another kind, or None.

## Content
What the piece shows: real copy and sample data for screens, including the longest realistic case; the subject and mood for illustrations and logos; None where nothing applies.

## Reuse
Existing components, designs and tokens to match, each with what to keep from it. Name each file in refs/ and what it shows.

## Constraints
Anything beyond design/README.md: performance, accessibility (keyboard path, contrast), where the piece is shown.

## Out of scope

## Hand back
The checklist the handoff must satisfy: every deliverable above, one line each.
```

A kind missing from `design/README.md` gets its entry there first (under **What happens to your design** and **By kind**), since that file is what every later brief shares; the brief then only fills in the details.

On a redesign, delete the piece's old `spec.md`, `handoff/` and `assets/` in the same commit as the new brief. The last commit keeps them, and a piece with no `spec.md` is one still to design.

## 5. Commit and hand off

Commit the briefs, `refs/` and any `design/README.md` change: `docs(design): brief <slug>[, <slug>]`.

Then give the user these steps, filled in for each piece. They are the whole manual hand-off, so give all of them every time:

1. Open claude.ai/design and start a new project named `<slug>`. If it asks what to make, pick whatever fits the piece's kind.
2. Attach the repo's `design/` folder (Import → local directory), so earlier designs and their tokens come along. If that import is refused or missing, attach the files instead: `design/README.md`, everything in `design/<slug>/`, and each spec listed under **Token sets** in the README.
3. Paste this prompt:

   ```
   Among the attached files, read README.md first, then the brief at
   <slug>/brief.md. Design what the brief asks for, following README.md.
   Ask me before changing anything under Decisions.
   ```

4. Iterate there. When it looks right, say "the design is done": README.md tells Claude Design to check the brief's Hand back list and report what changed.
5. Export → **Hand off to Claude Code** → **Send to local coding agent**, and copy the whole prompt it gives. If that option is missing, Export → **Download as .zip** instead and note where it was saved.
6. Back in this session, run `/design-intake` and paste the prompt (or the `.zip` path) after it. Context: keep this session open meanwhile, so `/to-spec` still has the grill; `/compact` if it must end.

Then stop.
