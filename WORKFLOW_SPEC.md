# Workflow Spec: Roofing Estimate Demo v1

## Overview

Webhook-triggered workflow that accepts roofing job inputs, calls a local LLM (Ollama) to generate a professional estimate, and returns a structured JSON response with email-ready body.

---

## Inputs

POST body to `/webhook/roofing-estimate`:

| Field      | Type   | Required | Description                                      |
|------------|--------|----------|--------------------------------------------------|
| address    | string | yes      | Property address (e.g. "123 Main St, Austin TX") |
| sqft       | number | yes      | Roof square footage (100–10000)                  |
| pitch      | string | yes      | Roof pitch: flat / low / medium / steep          |
| material   | string | yes      | Material: asphalt / metal / tile / flat          |
| damage     | string | yes      | Damage level: none / minor / moderate / severe   |
| email      | string | yes      | Customer email for quote delivery                |

---

## Processing Steps

### Step 1 — Validate Inputs
- Check all 6 fields present and non-empty
- Validate sqft is a number in range 100–10000
- Validate pitch is one of: flat / low / medium / steep
- Validate material is one of: asphalt / metal / tile / flat
- Validate damage is one of: none / minor / moderate / severe
- Validate email contains @ and .
- On failure: return 400 with `{ error: "validation_failed", details: [...] }`

### Step 2 — Generate Estimate via Ollama
- POST to `http://host.docker.internal:11434/api/generate`
- Model: `qwen3:8b`
- Prompt: structured request for roofing estimate including all input fields
- Expect: JSON with labor_cost, materials_cost, total_cost, timeline, notes

### Step 3 — Parse LLM Response
- Extract JSON block from Ollama response text
- Validate required fields: labor_cost, materials_cost, total_cost, timeline
- On parse failure: retry once with simplified prompt
- Set estimated_at timestamp

### Step 4 — Format Email Body
- Build professional email text with greeting, line-item costs, timeline, next steps
- Include property address and date
- Keep under 500 words

### Step 5 — Error Handling
- Validation errors → 400
- Ollama unreachable → 503 with `{ error: "model_unavailable" }`
- Parse failures after retry → 500 with `{ error: "generation_failed" }`
- All errors logged to workflow execution history

### Step 6 — Return Response
- 200 with full estimate payload
- Include: labor_cost, materials_cost, total_cost, timeline, email_body, generated_at

---

## Outputs

### Success (200)
```json
{
  "status": "success",
  "estimate": {
    "address": "123 Main St, Austin TX",
    "sqft": 1800,
    "material": "asphalt",
    "labor_cost": 3200,
    "materials_cost": 4500,
    "total_cost": 7700,
    "timeline": "3-5 business days",
    "notes": "Price includes tear-off and disposal",
    "generated_at": "2026-05-23T10:00:00Z"
  },
  "email_body": "Dear Customer, ..."
}
```

### Error (400 / 503 / 500)
```json
{
  "status": "error",
  "error": "validation_failed",
  "details": ["sqft must be a number between 100 and 10000"]
}
```

---

## Success Criteria

- [ ] Webhook accepts POST and returns within 30 seconds
- [ ] All 6 input fields validated with clear error messages
- [ ] LLM generates line-item cost breakdown (labor + materials + total)
- [ ] Timeline estimate included
- [ ] Email body is professional, clear, < 500 words
- [ ] No hallucinated data (costs within realistic range for sqft)
- [ ] Total cost = labor + materials (math check)
- [ ] Workflow handles Ollama timeout gracefully

---

## Test Data

```json
{
  "address": "4821 Ridgeview Ln, Austin TX 78741",
  "sqft": 1800,
  "pitch": "medium",
  "material": "asphalt",
  "damage": "minor",
  "email": "testcustomer@example.com"
}
```

Expected total range: $5,000–$15,000 for 1800 sqft asphalt with minor damage.
