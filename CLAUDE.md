# CLAUDE.md

## Git and GitHub — IMPORTANT

### Branches

**Never commit or push directly to `main`** — always work on a branch named `<type>/<issue>-<short-description>`:

- `<type>`: a Conventional Commits type (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`, …).
- `<issue>`: the GitHub issue number. If there is no issue, leave it out entirely — no `no-ticket` placeholder.
- `<short-description>`: kebab-case.

Examples: `feat/42-session-export`, `chore/agent-setup`.

Local branches that agents create for their own worktrees (e.g. `/implement-spec` implementers) and never push are exempt from this naming, as are `research/<slug>` and `prototype/<slug>` branches from `/wayfinder` and `/prototype`.

Before starting work that needs a branch, confirm its name if the user is present; otherwise name it by the convention and report it. Create it as a worktree with `wt`.

### Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/): `<type>(<scope>): <description>`.

- Description: imperative mood, lower-case, no trailing period — `fix(auth): handle expired tokens`, not `Fixed expired tokens.`
- Scope is optional; use it when the change sits in one clear area.
- Breaking changes: `!` after the type/scope (`feat(api)!: drop v1 routes`) and/or a `BREAKING CHANGE:` footer explaining what breaks and how to migrate.
- When the commit belongs to an issue, add a `Refs #123` footer.

### Issues and PRs

- Use the `.github/` templates (`ISSUE_TEMPLATE/bug.md`, `ISSUE_TEMPLATE/feature-task.md`, `pull_request_template.md`) and fill in every section; write `None` where one doesn't apply.
- Exception: issues created by skills — `/to-spec` specs, `/to-tickets` tickets, `/triage` briefs, wayfinder maps and tickets — use the skill's own body format, not these templates.
- This repo is public: no local paths, hostnames or machine details in issue, PR or commit text.
- In a PR, use `Closes #123` for each issue it completes, so merging closes it; use a plain `#123` for issues it only relates to. This tracker closes work through PRs.
- PR titles follow Conventional Commits; they become the squash commit title on `main`.
- Write issue and PR bodies to `.scratch/<name>.md` and pass `--body-file`; never inline `--body` or a heredoc.
- Never merge PRs to `main`; the user merges.
- Write every PR body with the `pr` skill (its format matches `pull_request_template.md`), then add the template's **Related issues** section.

## Testing

- **TDD by default** for new behaviour and bug fixes, in Rust and QML alike: use `mattpocock-skills:tdd`.
- **Seams:** a seam named in the spec's Testing Decisions or in the ticket counts as confirmed. An unattended implementer uses only those; if it needs a new seam, it stops that ticket and reports.
- **Red must fail for the expected reason** — a compile error or setup crash isn't red. **Never weaken a failing test** to make it pass; report the gap and stop.
- **Test-after** only for existing untested QML (coverage gaps) or pure visual layout: use `qt-qml-test`.
- **Rust:** `cargo test`; lint with the clippy command in `CODING_STANDARDS.md`.
- **QML:** Qt Quick Test, `tst_*.qml` in `tests/`, run with `QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qmltestrunner -import tests/stubs -input tests`.
- **Quickshell** types can't load under `qmltestrunner`: stub the ones you use in `tests/stubs/Quickshell/`, and keep logic in plain QML/JS outside the thin Quickshell layer.

## Workflow — IMPORTANT

Every change moves through these stages, in order. Each stage writes only its own output, then ends with a **hand-off**: name the next stage and what to do to the context **before starting it** (the Before-next column), then stop. The hand-off's last line is the context reminder, on its own and in bold: **You can `/clear` now:** with the files or issues that hold this stage's work, or **Don't `/clear` yet:** with why. The user starts every stage; "go", "agreed" or "yes" inside a stage closes that stage only.

| Stage | Writes | Hand-off | Before next |
|---|---|---|---|
| `/grill-with-docs` | `GLOSSARY.md`, `docs/adr/`; the grill record | `/design-brief` if the change has visual work still to design, else `/to-spec` | `/clear`: the grill record holds the rest |
| `/design-brief` | `design/<slug>/brief.md` and `refs/`, `design/README.md`; the design artifact, drafted | the user reviews the artifact and asks for changes, then `/design-intake <slug>` | Keep the session open while designing; if it closed, `claude --resume` it. `/clear` once the user runs `/design-intake` |
| `/design-intake` | `design/<slug>/handoff/`, `assets/` and `spec.md` | `/design-brief` for pieces that waited on the Foundations, `/design-intake` for the next piece, then `/to-spec` | `/clear` |
| `/to-spec` | the spec issue | `/to-tickets #<spec>` | `/clear`: the spec holds everything |
| `/to-tickets` | ticket issues | `/implement #<ticket>` per ticket, or `/implement-spec #<spec>` | `/clear`: the issues hold everything |
| `/implement` | code, tests; the PR after the last ticket | the next ticket's `/implement`; after the last, the user merges | `/clear` |
| `/implement-spec` | code, tests, the PR | the user merges | None |

**Why:** a long session gets slow and careless well before the window fills. So every stage leaves a written record and the next stage starts from a clear context that reads it, never from old chat.

**Before telling the user to `/clear`,** in any session, write everything agreed that no file or issue holds yet (including a plan for later work, such as a PR to make next) to `.scratch/<name>.md`, and name that file in the hand-off, so the next session starts by reading it. Never say something is saved until it is written; name where.

### The grill record

<important if="you are running /grill-with-docs, /design-brief, /design-intake or /to-spec, or the user adds a decision between those stages">

The **grill record**, `.scratch/grill-<short-description>.md` in the change's worktree (the short description from the branch name), carries what the grill settled into the stages after it. The glossary and ADRs keep only terms and hard-to-reverse decisions, and the rest would otherwise live only in the chat.

- **`/grill-with-docs`** writes it before its hand-off: the change and its branch; every question settled, one line each, with the answer and any ADR or glossary entry it went to; research facts found, with their sources; questions left open; whether the change has visual work still to design, and the next stage. Done when a fresh session could run the next stage from it alone.
- **Every later stage up to `/to-spec`** reads it first. `/design-brief` adds each piece's slug. Anything the user decides between stages goes in it at once, not only into the chat.
- **`/to-spec`** writes the spec from the grill record, `GLOSSARY.md`, the ADRs, and every `design/<slug>/brief.md` and `spec.md` the record names, plus anything said in its own session. Where the skill says "from the conversation", read "from these files". Once the spec issue exists, the grill record is spent.
- **Heavy reads go to subagents.** A stage that must read something large (a design snapshot, an artifact type's instructions, many source files) hands it to a subagent and takes back a short report, so its own context stays small. The design skills say how for their stages.
- **`/compact` is the fallback,** for a stage that has to run long; before compacting, write anything decided to the grill record or the stage's own files.
</important>

Repo files (code, config, `.gitignore`, the root `README.md`, `LICENSE`) are written in `/implement` or `/implement-spec`. Create the branch or worktree before `/grill-with-docs`, since it writes `GLOSSARY.md` and ADRs, and the design stages write `design/`.

- Tickets from one spec: each in its own worktree branched from the spec (grill) branch, merged back locally when done; one PR per spec. Merge commits get a Conventional Commits message and `Refs` footers too (`git merge --no-ff -m "chore: merge #<ticket> <title>" -m "Refs #<spec>"`).
- `/implement-spec`: the integration branch is the branch created before `/grill-with-docs` (it already holds the glossary and ADRs). Implementer worktrees branch from it and merge back one at a time.
- `/mattpocock-skills:code-review` (not the built-in `/code-review`): default fixed point is `main`.

### Visual work

<important if="a /grill-with-docs session is ending, or you are running /to-spec, /to-tickets, /implement, /implement-spec or /prototype on a change that has visual work, or opening or readying a PR for one">

**Visual work** is anything a person sees that is designed before it is built: the Foundations, a screen, a component, an icon set, an illustration or wallpaper, a logo, or a kind not yet named. A change has visual work when it designs some, or builds some from a design spec. **Visual work still to design** is a new piece with no `design/<slug>/spec.md` yet, or a redesign of a built one; that is what goes to `/design-brief`. When unsure at the end of a grill, name both hand-offs and your pick.

- **Designing** happens in a claude.ai design artifact that `/design-brief` creates and drafts through a subagent; the user reviews it there and asks for changes. The Foundations are a Design System artifact designed before any other piece; every other piece is a Design artifact built on them. `/prototype` is for logic and state questions; take "what should this look like?" to `/design-brief`.
- **`/to-spec`:** the change's design specs are those of the pieces the grill record names, plus any existing `design/<slug>/spec.md` the change builds from. Read each first, and cite each by path in the spec issue's Implementation Decisions. An implementer uses the design spec its ticket names.
- **`/to-tickets`:** each ticket that builds visual work names its `design/<slug>/spec.md` and the sections it builds. Its acceptance criteria cover what a test can prove (states, inputs, token and component names; for assets, the files present at their names and sizes), plus one marked **User check:** the result matches the design (its artifact, linked in `design/<slug>/spec.md`; the snapshot in `design/<slug>/handoff/` if the artifact has moved on). Tokens and Controls new or changed by the change get their own ticket, which blocks every ticket that uses them: the one deliberate horizontal slice, since they are shared by every screen and testable on their own.
- **Paths:** `design/<slug>/` paths are the one exception to the no-file-paths rule in `/to-spec` and `/to-tickets`.
- **Implementing:** the design spec, `design/<slug>/spec.md`, is the build target; use its token and component names. Tokens live in `Modality.Theme` under the spec's code names, Controls in `Modality.Controls`; both sit in `qml/Modality/` and import only Qt and other pure-QML `Modality.*` modules, so the Shell, the Greeter and Apps can all load them and nothing they import depends on a screen. Files in `design/<slug>/assets/` are copied to where they ship (`data/`, a QML module's resources), and code loads them from there. Passing tests close the ticket's criteria; each **User check** stays open for the user, who ticks it where the piece is shown, before merging.
- **The PR**, whoever opens or readies it, on either path: its body says the User checks are the user's, before merging; and before it is marked ready for review, each built design spec's **Built by** line is set to the spec issue, `#<number>`.
- **Built designs:** `design/` stays on `main`. A design spec whose **Built by** names an issue is history, and the code is the source of truth, until `/design-brief` replaces it in a redesign.
</important>

## Working rules

- **Conflicting instructions:** when a skill conflicts with this file, this file wins; otherwise follow the stricter rule, note it, and carry on.
- **Coding standards:** see `CODING_STANDARDS.md` (enforced by `/mattpocock-skills:code-review`).
- **Prove it:** don't claim a UI fix works until it is seen in running Quickshell or covered by a passing test. Agent environments can't run Quickshell, so for unattended runs a passing test is the proof.

## Agent skills

### Issue tracker

Issues live in GitHub Issues on `modalityos/modality`, managed with the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default label vocabulary. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
