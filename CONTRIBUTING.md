# Contributing to ModalityOS

Thanks for helping. This page says how work moves from an idea to a merged change. It links to the detailed docs rather than repeating them.

Read [`GLOSSARY.md`](GLOSSARY.md) first. Issues, code and tests all use its words: Greeter, Session, Shell, Token, Control.

## How work flows

Every change moves through the same stages, in order. Each stage leaves a written record, so the next one starts from a file or an issue, not from memory.

1. **Issue.** Open one with a template: [bug](.github/ISSUE_TEMPLATE/bug.md) or [feature or task](.github/ISSUE_TEMPLATE/feature-task.md). Fill in every section; write `None` where one does not apply.
2. **Grill.** The idea is questioned until it is clear. New terms go into `GLOSSARY.md`; hard-to-reverse decisions become ADRs in [`docs/adr/`](docs/adr/).
3. **Design**, when the change has something people will see that is not yet designed. Each piece gets a brief and a design spec under `design/<slug>/`. [`design/README.md`](design/README.md) explains how.
4. **Spec.** One issue that describes the whole change.
5. **Tickets.** The spec is split into small issues, each one buildable and testable on its own.
6. **Implement.** Each ticket is built test-first. One pull request carries the whole spec.
7. **Sign-off.** The owner runs the pull request in the test VM or the preview scene, and says what is not right. Each finding is fixed on the pull request's branch. See [User checks and sign-off](#user-checks-and-sign-off).
8. **Merge.** Only the owner merges.

Much of this is done with a coding agent. Its version of these rules is in [`CLAUDE.md`](CLAUDE.md). You do not need to read it, but where this page and `CLAUDE.md` disagree, `CLAUDE.md` wins.

## Branches

Never commit to `main`. Work on a branch named `<type>/<issue>-<short-description>`:

- `<type>` is a Conventional Commits type: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, and so on.
- `<issue>` is the GitHub issue number. With no issue, leave it out.
- `<short-description>` is kebab-case.

Examples: `feat/42-session-export`, `fix/57-caps-lock-notice`, `chore/agent-setup`.

## Commit messages

Use [Conventional Commits](https://www.conventionalcommits.org/): `<type>(<scope>): <description>`.

- Write the description in the imperative, lower-case, with no full stop.
- The scope is optional. Use it when the change sits in one clear area.
- Mark a breaking change with `!` after the type or scope, and explain it in a `BREAKING CHANGE:` footer: what breaks and how to migrate.
- When the commit belongs to an issue, add a `Refs #123` footer.

```
fix(greeter): clear the password field on Esc

Refs #10
```

```
feat(theme)!: rename the surface Tokens

BREAKING CHANGE: surfaceRaised is now surface-raised; update every use.
```

Good: `fix(auth): handle expired tokens`. Not: `Fixed expired tokens.`

## Tests

**Test-first by default.** New behaviour and bug fixes start with a failing test, then the code that makes it pass, in Rust and QML alike.

- The failing test must fail for the reason you expect. A compile error or a crash in setup does not count.
- Never weaken a failing test to make it pass. If a test cannot pass, say so in the issue or pull request.
- Write tests after the code only for existing QML that has no tests yet, or for pure visual layout.
- Name each test after the behaviour it checks, in the words of `GLOSSARY.md`.

Run `just check` before you push. It runs lint, the tests and the coverage check, then prints one line per check. [`docs/testing.md`](docs/testing.md) covers the seams, the shared stubs and how to read a failure.

## Coding standards

[`CODING_STANDARDS.md`](CODING_STANDARDS.md) has the rules for Rust, QML, comments, tests and naming. Code review checks them on every branch.

## Opening a pull request

- Fill in every section of the [pull request template](.github/pull_request_template.md). Write `None` where one does not apply.
- Title it as a Conventional Commit. It becomes the squash commit on `main`.
- Under **Related issues**, write `Closes #123` for each issue the pull request completes, so merging closes it. Write a plain `#123` for issues it only relates to.
- For visual work, say that the User checks are the owner's, before merging.

### Checks required on `main`

A pull request can merge only when these four checks pass:

| Check | What it means |
|---|---|
| **Tickets signed off** | Every issue the pull request closes has all its boxes ticked, including each User check. It is skipped on drafts and runs again when you mark the pull request ready. |
| **QML tests** | `just test` passes: the whole QML suite. |
| **Imports and lint** | `just lint` passes: the shared modules import only what they may, and `qmllint` finds no warning. |
| **Test coverage** | `just coverage` passes: every Greeter and shared-module QML or JS file is loaded by at least one test. |

The last three run on every pull request, drafts too. `just check` runs the same three locally. The repository also requires a squash merge, a linear history and an approving review. [`docs/testing.md`](docs/testing.md#ci) has more.

## User checks and sign-off

Tests cannot prove how something looks. So each ticket that builds visual work has a **User check**: "the result matches the design". Only the owner ticks it, after seeing the piece in the test VM or the preview scene.

Sign-off is the last stage before merging. The owner runs the pull request (`just deploy` into the test VM, or `just preview`) and lists what is not right. Each finding is fixed on the pull request's own branch, test-first where a test can prove it, until the owner calls it ready. [`docs/vm.md`](docs/vm.md) explains the test VM.

## Merging

Only the owner merges pull requests. Do not merge your own, even if every check is green.

## This repository is public

Keep local paths, hostnames, usernames and other machine details out of issues, pull requests and commit messages.

## License

By contributing, you agree that your contribution is licensed under the [MIT License](LICENSE).
