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
- PR bodies: the `pr` skill's format matches `pull_request_template.md`; when using it, add the template's **Related issues** section too.

## Testing

- **TDD by default** for new behaviour and bug fixes, in Rust and QML alike: use `mattpocock-skills:tdd`.
- **Seams:** a seam named in the spec's Testing Decisions or in the ticket counts as confirmed. An unattended implementer uses only those; if it needs a new seam, it stops that ticket and reports.
- **Red must fail for the expected reason** — a compile error or setup crash isn't red. **Never weaken a failing test** to make it pass; report the gap and stop.
- **Test-after** only for existing untested QML (coverage gaps) or pure visual layout: use `qt-qml-test`.
- **Rust:** `cargo test`; lint with the clippy command in `CODING_STANDARDS.md`.
- **QML:** Qt Quick Test, `tst_*.qml` in `tests/`, run with `QT_QPA_PLATFORM=offscreen /usr/lib/qt6/bin/qmltestrunner -import tests/stubs -input tests`.
- **Quickshell** types can't load under `qmltestrunner`: stub the ones you use in `tests/stubs/Quickshell/`, and keep logic in plain QML/JS outside the thin Quickshell layer.

## Workflow — IMPORTANT

Every change moves through these stages, in order. Each stage writes only its own output, then ends with a **hand-off**: name the next stage and stop. The user starts every stage; "go", "agreed" or "yes" inside a stage closes that stage only.

| Stage | Writes | Hand-off |
|---|---|---|
| `/grill-with-docs` | `GLOSSARY.md`, `docs/adr/` | `/to-spec` |
| `/to-spec` | the spec issue | `/to-tickets` |
| `/to-tickets` | ticket issues | `/implement` per ticket (`/clear` between), or `/implement-spec` |
| `/implement`, `/implement-spec` | code, tests, the PR | the user merges |

Repo files (code, config, `.gitignore`, `README.md`, `LICENSE`) are written in `/implement` or `/implement-spec`. Create the branch or worktree before `/grill-with-docs`, since it writes `GLOSSARY.md` and ADRs.

- Tickets from one spec: each in its own worktree branched from the spec (grill) branch, merged back locally when done; one PR per spec. Merge commits get a Conventional Commits message and `Refs` footers too (`git merge --no-ff -m "chore: merge #<ticket> <title>" -m "Refs #<spec>"`).
- `/implement-spec`: the integration branch is the branch created before `/grill-with-docs` (it already holds the glossary and ADRs). Implementer worktrees branch from it and merge back one at a time.
- `/code-review`: default fixed point is `main`.

## Working rules

- **Coding standards:** see `CODING_STANDARDS.md` (enforced by `/code-review`).
- **Prove it:** don't claim a UI fix works until it is seen in running Quickshell or covered by a passing test. Agent environments can't run Quickshell, so for unattended runs a passing test is the proof.

## Agent skills

### Issue tracker

Issues live in GitHub Issues on `modalityos/modality`, managed with the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

Default label vocabulary. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.
