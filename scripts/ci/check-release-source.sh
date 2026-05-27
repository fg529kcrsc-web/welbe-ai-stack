#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${GITHUB_REPOSITORY:-}" || -z "${VERSION:-}" ]]; then
  echo "GITHUB_REPOSITORY and VERSION are required." >&2
  exit 1
fi

if [[ -z "${APPROVED_PR:-}" ]]; then
  echo "APPROVED_PR is required for reviewed releases." >&2
  exit 1
fi

if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "VERSION must match vMAJOR.MINOR.PATCH." >&2
  exit 1
fi

tag_ref_json="$(gh api "repos/${GITHUB_REPOSITORY}/git/ref/tags/${VERSION}")"
tag_ref_type="$(jq -r '.object.type' <<<"$tag_ref_json")"
tag_object_sha="$(jq -r '.object.sha' <<<"$tag_ref_json")"

if [[ "$tag_ref_type" != "tag" ]]; then
  echo "Release ${VERSION} must be an annotated signed tag, not a lightweight tag." >&2
  exit 1
fi

tag_json="$(gh api "repos/${GITHUB_REPOSITORY}/git/tags/${tag_object_sha}")"
tag_verified="$(jq -r '.verification.verified' <<<"$tag_json")"
tag_target_sha="$(jq -r '.object.sha' <<<"$tag_json")"

if [[ "$tag_verified" != "true" ]]; then
  echo "Release tag ${VERSION} is not verified by GitHub." >&2
  exit 1
fi

pr_json="$(gh pr view "$APPROVED_PR" --json baseRefName,mergeCommit,mergedAt,reviewDecision,state)"

state="$(jq -r '.state' <<<"$pr_json")"
merged_at="$(jq -r '.mergedAt // empty' <<<"$pr_json")"
review_decision="$(jq -r '.reviewDecision // empty' <<<"$pr_json")"
base_ref="$(jq -r '.baseRefName' <<<"$pr_json")"
merge_sha="$(jq -r '.mergeCommit.oid // empty' <<<"$pr_json")"

if [[ "$state" != "MERGED" || -z "$merged_at" ]]; then
  echo "PR #${APPROVED_PR} must be merged before release." >&2
  exit 1
fi

if [[ "$review_decision" != "APPROVED" ]]; then
  echo "PR #${APPROVED_PR} must have an approved review decision." >&2
  exit 1
fi

if [[ "$base_ref" != "main" ]]; then
  echo "PR #${APPROVED_PR} must merge into main." >&2
  exit 1
fi

if [[ "$merge_sha" != "$tag_target_sha" ]]; then
  echo "Release SHA must match PR #${APPROVED_PR} merge commit." >&2
  exit 1
fi

if [[ -n "${GITHUB_ENV:-}" ]]; then
  echo "RELEASE_SHA=${tag_target_sha}" >> "$GITHUB_ENV"
fi

echo "Release source checks passed."
