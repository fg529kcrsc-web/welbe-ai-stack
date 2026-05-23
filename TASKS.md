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

## Day 4 — First Demo Workflow

- [x] Create WORKFLOW_SPEC.md (roofing estimate workflow spec)
- [x] Build "Roofing Estimate Demo v1" in n8n (6 nodes: Webhook → Validate → Ollama → Parse → Email → Response)
- [x] Test workflow with real data (qwen3:8b via Ollama)
- [x] Validate estimate output quality
- [x] Document results and push to GitHub

### Workflow Results

| Field | Value |
|-------|-------|
| Workflow name | Roofing Estimate Demo v1 |
| n8n ID | 5cSnoYwqjXM3XlZy |
| Nodes | Webhook → Validate Inputs → Call Ollama → Pass Input Data → Format Email Body → Webhook Response |
| Model used | qwen3:8b (via Ollama at localhost:11434) |
| Test input | 4821 Ridgeview Ln, Austin TX 78741, 1800 sqft, medium pitch, asphalt, minor damage |
| Estimate generated | $9,000 (labor: $3,000 + materials: $6,000) |
| Cost per sqft | $5.00 |
| Timeline | 3-5 days |
| Quality | PASS (7/7 checks: costs present, math correct, reasonable range, timeline, notes) |
| Time | 27 seconds |
| Iterations | 5 (fetch → http module → $helpers → raw contentType fix) |
| Issues | n8n Code node disallows fetch and http module; fixed with HTTP Request node + raw JSON body |
| Webhook URL | http://localhost:5678/webhook/roofing-estimate |

## Backlog

- [ ] Fine-tuning pipeline with mlx_lm
- [ ] Evaluate models (see EVALS.md)
- [ ] Add authentication to server
- [ ] Multi-model load balancing
