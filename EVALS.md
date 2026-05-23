# Model Evaluations

## Eval Framework

Test each model on standard tasks. Score 1-5. Record date + model version.

---

## Qwen2.5-7B-Instruct-4bit

**Version**: mlx-community/Qwen2.5-7B-Instruct-4bit
**Date tested**: —
**Status**: Not yet tested

### Benchmarks

| Task | Score | Notes |
|------|-------|-------|
| Basic Q&A | — | — |
| Code generation | — | — |
| Reasoning | — | — |
| Speed (tok/s) | — | — |
| Memory usage | — | — |

### Test Prompts

```
# Test 1: Basic reasoning
Prompt: "If I have 3 apples and give away 2, then buy 5 more, how many do I have?"
Expected: 6

# Test 2: Code generation
Prompt: "Write a Python function that reverses a string without using slicing."
Expected: Working function using loop or reversed()

# Test 3: Instruction following
Prompt: "List exactly 3 fruits. Only output the list, nothing else."
Expected: Exactly 3 fruits, no preamble
```

---

## Qwen2.5-Coder-32B-Instruct-4bit

**Version**: mlx-community/Qwen2.5-Coder-32B-Instruct-4bit
**Date tested**: —
**Status**: Not yet tested

### Benchmarks

| Task | Score | Notes |
|------|-------|-------|
| Basic Q&A | — | — |
| Code generation | — | — |
| Complex reasoning | — | — |
| Speed (tok/s) | — | — |
| Memory usage | — | — |

---

## Comparison

| Metric | 7B-4bit | 32B-4bit |
|--------|---------|---------|
| Speed | — tok/s | — tok/s |
| RAM | — GB | — GB |
| Code quality | — | — |
| Best for | fast tasks | complex reasoning |
