# Skill: n8n Workflow Builder

Design and validate roofing business automation workflows in n8n.

## When to Use

- Building a new automation (lead intake, follow-up, scheduling, reporting)
- Reviewing an existing workflow before deploying
- Connecting Ollama AI to a business process

---

## Pre-Build Checklist

Before opening n8n, answer these:

- [ ] What triggers this workflow? (webhook / cron / email / form / manual)
- [ ] What data comes in? (fields, format, source)
- [ ] What decision does AI need to make? (classify / draft / summarize / route)
- [ ] What happens with the output? (CRM update / email send / Slack alert / sheet row)
- [ ] What happens on failure? (retry / alert / log to sheet)
- [ ] Who needs to approve before it runs live?

---

## Workflow Template

```
[Trigger] → [Validate Input] → [Enrich/Lookup] → [AI Node] → [Route on Result] → [Action] → [Log/Notify]
```

### Node breakdown

| Position | Node Type | Purpose |
|----------|-----------|---------|
| 1 | Webhook / Cron / Email | Trigger |
| 2 | IF / Switch | Validate required fields |
| 3 | HTTP Request / Airtable | Enrich with existing data |
| 4 | HTTP Request → Ollama | AI classification or generation |
| 5 | Switch | Route on AI output (hot/warm/cold, yes/no) |
| 6 | Gmail / Twilio / Airtable | Take action |
| 7 | Google Sheets / Slack | Log result + alert on failure |

### Ollama HTTP Request node config

```json
{
  "method": "POST",
  "url": "http://localhost:11434/v1/chat/completions",
  "headers": { "Content-Type": "application/json" },
  "body": {
    "model": "qwen3:8b",
    "messages": [
      { "role": "system", "content": "{{ system_prompt }}" },
      { "role": "user", "content": "{{ input_data }}" }
    ],
    "max_tokens": 200,
    "temperature": 0.2
  }
}
```

Use `qwen3:8b` for classification/routing. Use `qwen3-coder:30b` for generation.

---

## Common Roofing Workflows

### Lead Intake → Qualify → Route
Trigger: Website form webhook
AI task: Classify lead as hot/warm/cold based on urgency, damage type, timeline
Action: Hot → owner SMS + CRM; Warm → email sequence; Cold → nurture list

### Follow-Up Sequence
Trigger: Cron (daily 9am)
AI task: Draft personalized follow-up based on last contact + job type
Action: Send via Gmail, log in Airtable

### Job Completion → Review Request
Trigger: Webhook from job management tool (when status = complete)
AI task: Generate personalized review request message
Action: Send SMS via Twilio, track response

### Weekly Report
Trigger: Cron (Friday 4pm)
AI task: Summarize week's leads, jobs, revenue from Airtable data
Action: Send digest to owner via Slack or email

---

## Success Criteria

A workflow is ready to deploy when:

- [ ] All required input fields are validated (IF node rejects missing data)
- [ ] AI prompt is tested with 5 real examples — output is consistent
- [ ] Failure path sends alert (Slack or email) — never fails silently
- [ ] Credentials stored in n8n vault, not hardcoded in nodes
- [ ] Workflow has a clear name: `[trigger]-[action]-v1`
- [ ] Tested end-to-end with real (or realistic) data before going live
- [ ] Owner has reviewed and approved the output quality

---

## Pitfalls to Avoid

- Prompts with no examples → inconsistent AI output → bad routing decisions
- No failure handling → silent failures → lost leads
- Hardcoded credentials in HTTP nodes → security risk
- No logging → impossible to debug issues after the fact
- Skipping the validate step → malformed data breaks downstream nodes
