## 08 — LoRA/PEFT Adapters

### Objectives
- Load LoRA adapters and switch between them without restarting the server.

### Start server with adapters
```bash
uvx vllm serve meta-llama/Llama-3.1-8B-Instruct \
  --port 8000 \
  --dtype auto \
  --adapter "name=finance,path=/path/to/finance-lora" \
  --adapter "name=legal,path=/path/to/legal-lora"
```

### Use adapter via client
Set the `extra_body` or model kwargs if supported; for OpenAI SDKs, send the adapter name in the request body via the provider’s documented field (check your vLLM version notes). Example pattern:
```python
from openai import OpenAI
client = OpenAI(base_url="http://localhost:8000/v1", api_key="not-needed")

resp = client.chat.completions.create(
    model="meta-llama/Llama-3.1-8B-Instruct",
    messages=[{"role":"user","content":"Summarize: earnings call"}],
    extra_body={"adapter":"finance"},  # exact key may vary by version
)
print(resp.choices[0].message.content)
```

### Exercise
- Switch adapters across requests and compare tone/domain specificity.

### Checkpoint
- You can load multiple adapters and route requests to a specific adapter at runtime.


