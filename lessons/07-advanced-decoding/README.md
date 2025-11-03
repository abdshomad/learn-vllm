## 07 — Advanced Decoding: Speculative + Prefix Caching

### Objectives
- Use speculative decoding to improve throughput.
- Leverage prefix caching for repeated prompts.

### Speculative decoding
```bash
uvx vllm serve meta-llama/Llama-3.1-8B-Instruct \
  --port 8000 \
  --dtype auto \
  --speculative-model meta-llama/Llama-3.1-8B-Instruct
```

Notes:
- The exact flags and compatibility can change by version; verify your vLLM version’s docs.

### Prefix caching
- Send multiple requests that share the same long system or prefix prompt.
- Measure reduced prefill time on subsequent requests.

### Exercise
- Create a script that issues 10 requests sharing a 2–4k token prefix; compare the first vs subsequent latencies.

### Checkpoint
- You can run with speculative decoding and observe benefits from prefix caching.


