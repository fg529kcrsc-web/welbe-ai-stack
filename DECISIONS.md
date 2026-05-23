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
