# Security

## Threat Model

Local inference stack. Primary risks: unauthorized API access, data leakage through model outputs, supply chain attacks on model weights.

---

## Current Security Posture

### mlx_lm.server

- **Default binding**: 127.0.0.1 (localhost only) ✅
- **Authentication**: None (local only) ⚠️
- **HTTPS**: None (local only) ⚠️
- **Rate limiting**: None ⚠️

### Rules

- NEVER expose mlx_lm.server on 0.0.0.0 without authentication
- NEVER commit API keys, tokens, or credentials
- NEVER store user data in model context across sessions
- ALWAYS use --host 127.0.0.1 (default) unless explicitly needed

---

## If Exposing to Network

If you ever need to expose the server beyond localhost:

1. Add reverse proxy (nginx) with authentication
2. Use HTTPS with valid certificate
3. Implement rate limiting
4. Log all requests
5. Update this file with threat assessment

---

## Model Security

- Download models only from `mlx-community` or official `Qwen` HuggingFace orgs
- Verify model checksums if available
- Don't load untrusted adapter weights

---

## Secrets Management

- HuggingFace tokens: store in `~/.config/huggingface/token` (hf login)
- GitHub tokens: managed by gh CLI
- NEVER hardcode tokens in scripts
- NEVER commit .env files

---

## Incident Response

If model server is accidentally exposed:
1. Kill process immediately: `pkill -f mlx_lm`
2. Check logs for unauthorized requests
3. Rotate any API keys that may have been exposed
4. Document in this file
