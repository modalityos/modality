#!/usr/bin/env bash
# Sign-off gate: fails while any issue the PR closes has an unticked box in its body.
# Issue boxes are the record, so the check reads them live instead of trusting a flag.
set -euo pipefail

pr="${1:?usage: tools/check-boxes.sh <pr-number>}"
repo="${GITHUB_REPOSITORY:-$(gh repo view --json nameWithOwner --jq .nameWithOwner)}"

# GitHub's own list of issues the PR closes: keywords in the body and sidebar links alike.
issues=$(gh api graphql -F owner="${repo%/*}" -F name="${repo#*/}" -F pr="$pr" -f query='
  query($owner: String!, $name: String!, $pr: Int!) {
    repository(owner: $owner, name: $name) {
      pullRequest(number: $pr) {
        closingIssuesReferences(first: 100) { nodes { number } }
      }
    }
  }' --jq '.data.repository.pullRequest.closingIssuesReferences.nodes[].number')

if [[ -z "$issues" ]]; then
  echo "PR #$pr closes no issues; nothing to check."
  exit 0
fi

open=0
for n in $issues; do
  # Boxes inside fenced code blocks are examples, not criteria.
  unticked=$(gh issue view "$n" --repo "$repo" --json body --jq .body |
    awk '/^[[:space:]]*```/ { fenced = !fenced; next } !fenced' |
    grep -E '^[[:space:]]*[-*] \[ \]' || true)
  if [[ -n "$unticked" ]]; then
    open=1
    echo "#$n has unticked boxes:"
    printf '%s\n' "$unticked"
  else
    echo "#$n: every box ticked."
  fi
done

exit "$open"
