---
name: signoff
description: Check a ready PR with the user before they merge it, fixing what they find on the PR's branch.
argument-hint: "<PR number>"
disable-model-invocation: true
---

The last stage before the user merges. Agents built and reviewed the PR; now the user sees it run (the test VM through the deploy tool, a preview scene, the app) and says what isn't right. Each **finding** is fixed here, in this session, with the user in the loop, as commits on the PR's own branch, until the user calls it ready.

The user tests and judges; you diagnose, fix and verify. Heavy reads still go to subagents; the fixes and the decisions stay in this session.

## 1. Load the PR

Read the PR (`gh pr view <pr>`), the spec and tickets its `Closes` lines name, and the **User checks** still open in those tickets. Work in the worktree of the PR's head branch.

Open the **sign-off record**, `.scratch/signoff-<short-description>.md` (the short description from the branch name), or create it: the PR number, then one line per open User check.

Give the user the **test plan**, from the PR body and the repo's docs (`README.md` and the testing doc it links, `just --list`): how to see the result (deploy and rollback commands, preview command, how to start the app), and where to check each open User check (the VM, a preview scene, the app). Put it in the record.

Done when the record names every open User check and where to check it, and the user has the test plan.

## 2. Work each finding

For each thing the user reports:

1. Add it to the record as a numbered finding, in the user's words.
2. Find the cause; reach for `mattpocock-skills:diagnosing-bugs` when it isn't plain. Tell the user the cause and the fix in a few lines. When the fix departs from the spec or a design spec, or has more than one fair answer, get the user's pick first; otherwise go ahead.
3. Fix it test-first where a test can prove it (`mattpocock-skills:tdd`, under the Testing rules in `CLAUDE.md`). Run the full suite.
4. Commit onto the PR's branch (Conventional Commits, `Refs #<spec>` and the ticket's number) and push.
5. Tell the user how to see it (the redeploy or preview command), then wait for their verdict. The finding is fixed when the user confirms it; on "not yet", keep working it.

When the user confirms a **User check**, tick it in its ticket's issue body and mark it in the record.

**The design is the source of truth.** Before fixing a finding, check it against the spec, its tickets and every design spec they name (`design/<slug>/spec.md`). A fix that makes the build match them belongs here. Anything they don't ask for, or that contradicts them, is new behaviour, even when the user suggests it: it becomes a new **Feature** issue (or an **Idea**, if the user is unsure), linked from the record, and stays out of this PR. Say which line of which spec decided it.

Update the record after every step: it is what survives a `/clear` or a compaction.

Done for a finding when the user confirms it fixed, or it has moved to an issue.

## 3. Close the sign-off

When the user's testing is done, offer the built-in `/code-review` for a last pass on correctness bugs (`/mattpocock-skills:code-review`, the spec and standards review, already ran in `/implement-spec`). The user runs it or declines. Each finding the user wants fixed becomes a finding in step 2.

When the user calls it ready:

- Re-read the record and check every finding, by number: fixed and confirmed, or moved to an issue.
- Run `tools/check-boxes.sh <pr>` until it passes: every box in every issue the PR closes is ticked. Name any open one to the user: tick it on their word, or move it to an issue. The **Sign-off gate** check on the PR re-runs by itself when an issue is edited; confirm it is green (`gh pr checks <pr>`).
- Update the PR body (the `pr` skill format): a **Sign-off** list under Evidence, one line per finding with its fix commit or issue; bring the rest of the body up to date with what changed.
- Tell the user the User checks and the merge are theirs.
- Move the record to `.scratch/archive/`.
