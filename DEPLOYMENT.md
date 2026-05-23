# Deployment

## Environment Setup

```bash
# 1. Create virtualenv (first time only)
python3 -m venv ~/mlx_env

# 2. Activate
source ~/mlx_env/bin/activate

# 3. Install
pip install mlx mlx-lm

# 4. Verify
mlx_lm.server --help
```

---

## Running the Server

### Qwen 7B (fast, everyday tasks)

```bash
source ~/mlx_env/bin/activate
mlx_lm.server \
  --model mlx-community/Qwen2.5-7B-Instruct-4bit \
  --host 127.0.0.1 \
  --port 8080 \
  --log-level INFO
```

### Qwen Coder 32B (complex reasoning, code)

```bash
source ~/mlx_env/bin/activate
mlx_lm.server \
  --model mlx-community/Qwen2.5-Coder-32B-Instruct-4bit \
  --host 127.0.0.1 \
  --port 8081 \
  --log-level INFO
```

---

## API Reference

Server exposes OpenAI-compatible endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| /v1/chat/completions | POST | Chat inference |
| /v1/completions | POST | Text completion |
| /v1/models | GET | List loaded model |

### Example Request

```bash
curl http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 100
  }'
```

---

## Auto-Start (launchd)

To start server automatically on login:

```bash
# Create plist at ~/Library/LaunchAgents/com.welbe.mlx-server.plist
# Load: launchctl load ~/Library/LaunchAgents/com.welbe.mlx-server.plist
# Unload: launchctl unload ~/Library/LaunchAgents/com.welbe.mlx-server.plist
```

(plist template: TODO — add when needed)

---

## Model Downloads

Models auto-download on first use from HuggingFace to `~/.cache/huggingface/`.

To pre-download:

```bash
source ~/mlx_env/bin/activate
python3 -c "from mlx_lm import load; load('mlx-community/Qwen2.5-7B-Instruct-4bit')"
python3 -c "from mlx_lm import load; load('mlx-community/Qwen2.5-Coder-32B-Instruct-4bit')"
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `mlx_lm.server: command not found` | `source ~/mlx_env/bin/activate` first |
| Port already in use | `lsof -i :8080` → kill process |
| Out of memory | Use smaller model or reduce --max-tokens |
| Slow first response | Model loading into RAM, normal on first call |
