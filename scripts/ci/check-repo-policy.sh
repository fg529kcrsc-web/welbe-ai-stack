#!/usr/bin/env bash
set -euo pipefail

required_files=(
  ".github/CODEOWNERS"
  ".github/dependabot.yml"
  ".github/workflows/ci.yml"
  ".github/workflows/release.yml"
  ".github/workflows/secret-scan.yml"
  ".gitleaks.toml"
  ".markdownlint-cli2.jsonc"
  "renovate.json"
  "scripts/ci/apply-github-protection.sh"
)

for file in "${required_files[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "Missing required governance file: $file" >&2
    exit 1
  fi
done

if grep -RIn --exclude-dir=.git --include='*.md' -E '(sk-[A-Za-z0-9_-]{20,}|ghp_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,}|xox[baprs]-[A-Za-z0-9-]{20,})' .; then
  echo "Potential secret-shaped token found in Markdown." >&2
  exit 1
fi

if grep -RIn --exclude-dir=.git --include='*.yml' --include='*.yaml' -E 'uses: [^@]+@(main|master|latest)$' .github/workflows; then
  echo "GitHub Actions must not pin actions to main, master, or latest." >&2
  exit 1
fi

if ! grep -RIn --include='*.yml' --include='*.yaml' '^permissions:' .github/workflows >/dev/null; then
  echo "At least one workflow must declare explicit permissions." >&2
  exit 1
fi

if ! grep -q '@fg529kcrsc-web' .github/CODEOWNERS; then
  echo "CODEOWNERS must require review from @fg529kcrsc-web." >&2
  exit 1
fi

if grep -q 'allow_fork_syncing' scripts/ci/apply-github-protection.sh; then
  echo "Branch protection must not set allow_fork_syncing unless the branch is locked." >&2
  exit 1
fi

if ! grep -q 'lock_branch: false' scripts/ci/apply-github-protection.sh; then
  echo "Branch protection must keep main unlocked for reviewed PR merges." >&2
  exit 1
fi

for check in "Repository policy" "Markdown quality" "Actionlint" "Dependency review" "Gitleaks"; do
  if ! grep -q "\"$check\"" scripts/ci/apply-github-protection.sh; then
    echo "Branch protection must require check: $check" >&2
    exit 1
  fi
done

echo "Repository policy checks passed."
