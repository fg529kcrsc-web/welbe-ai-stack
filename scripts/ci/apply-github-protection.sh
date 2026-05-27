#!/usr/bin/env bash
set -euo pipefail

repo="${1:-$(gh repo view --json nameWithOwner --jq '.nameWithOwner')}"
branch="${2:-main}"

required_checks=(
  "Repository policy"
  "Markdown quality"
  "Actionlint"
  "Dependency review"
  "Gitleaks"
)

contexts_json="$(
  printf '%s\n' "${required_checks[@]}" |
    jq -R . |
    jq -s .
)"

jq -n \
  --argjson contexts "$contexts_json" \
  '{
    required_status_checks: {
      strict: true,
      contexts: $contexts
    },
    enforce_admins: true,
    required_pull_request_reviews: {
      dismiss_stale_reviews: true,
      require_code_owner_reviews: true,
      required_approving_review_count: 1
    },
    restrictions: null,
    required_linear_history: true,
    allow_force_pushes: false,
    allow_deletions: false,
    block_creations: false,
    required_conversation_resolution: true,
    lock_branch: false
  }' |
  gh api \
    --method PUT \
    "repos/${repo}/branches/${branch}/protection" \
    --input -

gh api \
  --method POST \
  "repos/${repo}/branches/${branch}/protection/required_signatures" \
  >/dev/null

echo "Applied branch protection to ${repo}:${branch}."
