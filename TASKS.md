# Tasks

## Status Legend
- [ ] TODO
- [x] DONE
- [~] IN PROGRESS
- [!] BLOCKED

---

## Day 1 — Foundation

- [x] Create mlx_env virtualenv
- [x] Install mlx + mlx-lm
- [x] Verify mlx_lm.server --help works
- [~] Download Qwen2.5-7B-Instruct-4bit
- [ ] Download Qwen2.5-Coder-32B-Instruct-4bit
- [ ] Test inference Qwen 7B
- [ ] Test inference Qwen Coder 32B
- [x] Create welbe-ai-stack GitHub repo
- [x] Create 7 memory files
- [x] Push to GitHub

## Day 2 — API Layer

- [ ] Set up mlx_lm.server as launchd service (auto-start on boot)
- [ ] Configure OpenAI-compatible endpoint
- [ ] Test with curl / Python client
- [ ] Document API endpoints in DEPLOYMENT.md

## Day 3 — Integration

- [ ] Connect to n8n workflows
- [ ] Connect to memory system (sadakov_memory_api.py)
- [ ] Set up model routing (7B fast path / 32B deep path)

## Backlog

- [ ] Fine-tuning pipeline with mlx_lm
- [ ] Evaluate models (see EVALS.md)
- [ ] Add authentication to server
- [ ] Multi-model load balancing
