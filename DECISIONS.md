# Architecture Decisions

## ADR-001: MLX as inference runtime

**Date**: 2026-05-23
**Status**: Accepted

**Context**: Need local LLM inference on Apple Silicon Mac.

**Decision**: Use Apple MLX framework via mlx-lm.

**Reasons**:
- Native Metal GPU acceleration on Apple Silicon
- No CUDA dependency
- Unified memory = no VRAM bottleneck (shares system RAM)
- mlx-community has pre-quantized models ready to use
- OpenAI-compatible server built-in (mlx_lm.server)

**Alternatives considered**:
- Ollama: simpler but less control, slower on Apple Silicon
- llama.cpp: good but MLX faster on M-series chips
- Core ML: harder model conversion pipeline

---

## ADR-002: Qwen2.5 as primary model family

**Date**: 2026-05-23
**Status**: Accepted

**Context**: Choose base models for inference stack.

**Decision**: Qwen2.5-7B-Instruct (fast tasks) + Qwen2.5-Coder-32B-Instruct (complex reasoning/code).

**Reasons**:
- Qwen2.5 top-tier on benchmarks for size
- Coder variant strong on code tasks
- Both available as 4-bit MLX pre-quantized from mlx-community
- Good multilingual support

**Alternatives considered**:
- Llama 3.1: slightly lower benchmarks at same size
- Mistral: fewer parameters at equivalent quality
- Phi-3: smaller but less capable on complex tasks

---

## ADR-003: 4-bit quantization

**Date**: 2026-05-23
**Status**: Accepted

**Context**: Balance model quality vs memory usage.

**Decision**: Use 4-bit quantized models from mlx-community.

**Reasons**:
- 7B 4-bit fits in ~4.3GB unified memory
- 32B 4-bit fits in ~18GB (within 32GB+ M-series RAM)
- Quality loss minimal for instruction-following tasks
- mlx-community maintains quality-checked conversions

---

## ADR-004: Python 3 virtualenv isolation

**Date**: 2026-05-23
**Status**: Accepted

**Decision**: Use ~/mlx_env dedicated virtualenv.

**Reasons**:
- Isolates mlx/mlx-lm from system Python
- Prevents dependency conflicts
- Easy to nuke and recreate if broken

---

## ADR-005: Use Ollama for model serving (not MLX directly)

**Date**: 2026-05-23
**Status**: Accepted

**Context**: Initial stack used mlx_lm.server directly. Need simpler, more portable model serving with better model management.

**Decision**: Shift to Ollama as the primary model server. MLX remains the underlying inference engine on Apple Silicon via Ollama's backend.

**Why Ollama over direct MLX**:
- Single command to pull, run, and manage models (`ollama pull`, `ollama run`)
- Built-in model library with versioned tags
- OpenAI-compatible API on port 11434 — same integration interface
- Background daemon handles server lifecycle (no manual start/stop)
- Easier for n8n and other tools to integrate — one stable endpoint
- Model switching without restarting server

**When to use Ollama**:
- All local inference for automation workflows
- n8n HTTP Request nodes pointing to `http://localhost:11434/api`
- Testing and evaluation runs

**Models and ports**:
- Endpoint: `http://localhost:11434`
- API: `/api/generate` (streaming), `/api/chat`, `/v1/chat/completions` (OpenAI compat)
- Pull models: `ollama pull qwen3:8b`, `ollama pull qwen3-coder:30b`

**Alternatives rejected**:
- Direct mlx_lm.server: requires manual venv activation, no model management CLI
- LM Studio: GUI-only, harder to script
- llama.cpp server: more setup, no model registry

---

## ADR-006: Use n8n for workflow automation

**Date**: 2026-05-23
**Status**: Accepted

**Context**: Need to automate roofing business workflows (lead intake, follow-up, scheduling, reporting) using local AI without cloud API costs.

**Decision**: Use n8n as the workflow automation engine, self-hosted locally or on a small VPS.

**Why n8n**:
- Visual workflow builder — non-developers can read and modify flows
- 400+ native integrations (Gmail, Slack, Airtable, Twilio, webhooks)
- HTTP Request node connects directly to Ollama API for local AI inference
- Trigger-based: webhooks, cron, email, form submissions
- Self-hostable: no per-workflow cost, data stays local
- JavaScript Code nodes for custom logic when needed

**Integration approach**:
- n8n → HTTP Request → Ollama (`http://localhost:11434/v1/chat/completions`)
- Webhooks receive inbound leads → AI classifies/responds → CRM updated
- Cron triggers for daily summaries, follow-up reminders
- Credentials stored in n8n credential vault (not in repo)

**Skills**: See `skills/n8n-workflow-builder.md` for workflow design checklist.

---

## ADR-007: Model assignment by task complexity

**Date**: 2026-05-23
**Status**: Accepted

**Context**: Two models available locally via Ollama. Need clear routing rules to balance speed vs quality.

**Decision**:
- **Qwen 3:8b** → autocomplete, classification, short summaries, routing decisions
- **Qwen3-Coder:30b** → code generation, complex reasoning, multi-step analysis, customer discovery synthesis

**Why this split**:
- Qwen 3:8b: fast (~200 tok/s on M-series), fits in 8GB RAM, good enough for yes/no and fill-in tasks
- Qwen3-Coder:30b: slower but significantly better on code and multi-step reasoning; worth the latency for generation tasks
- Keeps inference cost near-zero (local) while maintaining quality where it matters

**Routing rules**:
| Task | Model |
|------|-------|
| Autocomplete suggestions | qwen3:8b |
| Lead classification (hot/warm/cold) | qwen3:8b |
| Short reply drafting | qwen3:8b |
| Code generation / debugging | qwen3-coder:30b |
| Full email/proposal generation | qwen3-coder:30b |
| Customer discovery synthesis | qwen3-coder:30b |
| Multi-document analysis | qwen3-coder:30b |

**Port**: Both served via Ollama on `http://localhost:11434`. Switch model via `model` field in API request body.
