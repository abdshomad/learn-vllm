## 02 — Hello vLLM Server

### Objectives
- Launch a local OpenAI-compatible vLLM server.
- Verify the health and list models.

### Steps
1) Pick a model you can load on your GPUs (examples):
- `meta-llama/Llama-3.1-8B-Instruct`
- `mistralai/Mixtral-8x7B-Instruct-v0.1` (larger, requires more VRAM)

2) Start the server:
```bash
uvx vllm serve meta-llama/Llama-3.1-8B-Instruct \
  --port 8000 \
  --dtype auto
```

3) Verify health and models:
```bash
curl http://localhost:8000/v1/models | jq
```

4) Stop the server (Ctrl+C) when done.

### Notes
- First start will download weights; subsequent starts should reuse the HF cache.
- If ports conflict, change `--port`.

### Exercise
- Try a different model and compare startup time.
- Add `--max-model-len 8192` and note VRAM impact at startup.

### Checkpoint
- You can start and stop vLLM; the `/v1/models` endpoint returns your loaded model.


