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

## References

- See TASKS.md for current work
- See DECISIONS.md for architecture choices
- See DEPLOYMENT.md for server setup
