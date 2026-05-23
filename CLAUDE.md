# Welbe AI Stack — Claude Code Configuration

## Project Overview

Local AI inference stack using Apple Silicon MLX framework with Qwen models.

## Stack

- **Runtime**: MLX on Apple Silicon (macOS)
- **Models**: Qwen2.5-7B-Instruct (fast), Qwen2.5-Coder-32B-Instruct (deep reasoning)
- **Server**: mlx_lm.server (OpenAI-compatible API on port 8080)
- **Venv**: ~/mlx_env

## Rules

- Do what has been asked; nothing more, nothing less
- NEVER create files unless absolutely necessary
- NEVER create documentation files unless explicitly requested
- ALWAYS read a file before editing it
- NEVER commit secrets, credentials, or .env files
- Keep files under 500 lines

## Quick Commands

```bash
# Activate environment
source ~/mlx_env/bin/activate

# Start Qwen 7B server
mlx_lm.server --model mlx-community/Qwen2.5-7B-Instruct-4bit --port 8080

# Start Qwen Coder 32B server
mlx_lm.server --model mlx-community/Qwen2.5-Coder-32B-Instruct-4bit --port 8080

# Test inference
python3 -c "
import urllib.request, json
data = json.dumps({'model':'qwen','messages':[{'role':'user','content':'Hello'}],'max_tokens':50}).encode()
req = urllib.request.Request('http://localhost:8080/v1/chat/completions', data=data, headers={'Content-Type':'application/json'})
print(urllib.request.urlopen(req).read().decode())
"
```

## Model Paths

| Model | HuggingFace ID | Size |
|-------|---------------|------|
| Qwen 7B | mlx-community/Qwen2.5-7B-Instruct-4bit | ~4.3GB |
| Qwen Coder 32B | mlx-community/Qwen2.5-Coder-32B-Instruct-4bit | ~18GB |

## Commands

Slash commands for structured AI-assisted development. Each enforces a specific phase of the workflow.

### /start
**Purpose**: Orient at session start. Load context, identify next action.
**How to use**: Run at the beginning of every session.
- Reads TASKS.md, DECISIONS.md, DEPLOYMENT.md, SECURITY.md
- Identifies highest-priority incomplete task
- States what it will do next and asks for confirmation

### /brainstorm
**Purpose**: Generate options before committing to a path.
**How to use**: Run when you have a problem but no clear solution.
- Generates 3–5 distinct approaches with tradeoffs
- Forces a decision, offer, or task at the end — never leaves options open
- Output: one chosen direction with rationale

### /plan
**Purpose**: Define scope before any code is written.
**How to use**: Run after /brainstorm, before /build.
- Defines: files to change, risks, test cases, rollback steps
- Produces explicit checklist that /build will follow
- No code written during this phase

### /build
**Purpose**: Execute the approved plan. Keep changes small and focused.
**How to use**: Run after /plan is approved.
- Implements only what the plan specifies — nothing more
- Commits in small, atomic units
- Stops and reports if it encounters ambiguity

### /review
**Purpose**: Audit the diff for correctness, security, and quality.
**How to use**: Run after /build, before merging or shipping.
- Checks: bugs, missing tests, security issues, AI-generated slop
- Flags hardcoded secrets, missing error handling, untested paths
- Output: list of issues or "LGTM"

### /test
**Purpose**: Run full test suite across all layers.
**How to use**: Run before /ship or after any significant change.
- Runs: lint, TypeScript typecheck, unit tests, integration tests, Playwright E2E
- Reports pass/fail per layer
- Blocks /ship if any layer fails

### /security
**Purpose**: Scan for secrets, vulnerabilities, and auth/billing gaps.
**How to use**: Run before any deployment or after touching auth/billing code.
- Tools: Gitleaks (secrets), Semgrep (SAST)
- Checks: auth flows, billing logic, Supabase RLS policies, env var exposure
- Output: findings with severity or "CLEAN"

### /handoff
**Purpose**: Write current state before stopping work.
**How to use**: Run at end of session or before switching context.
- Writes to TASKS.md: what's done, what's next, blockers
- Writes to DECISIONS.md: any architectural choices made this session
- Leaves repo in a state where anyone (or Claude) can resume cleanly

### /ship
**Purpose**: Final verification before production deployment.
**How to use**: Run after /test and /security pass.
- Verifies: all tests green, security clean, deploy config correct
- Checks: env vars set, rollback plan exists, release notes written
- Only proceeds if every gate passes

### /retro
**Purpose**: Extract learning from what just happened.
**How to use**: Run after completing a feature, fixing a bug, or finishing a session.
- Records: what worked, what failed, surprising discoveries
- Converts findings into one of: new rule, new skill, new test, new command
- Output written to DECISIONS.md or skills/ directory

## References

- See TASKS.md for current work
- See DECISIONS.md for architecture choices
- See DEPLOYMENT.md for server setup
