## 02 — Hello vLLM Server

### Objectives
- Launch a local OpenAI-compatible vLLM server.
- Verify the health and list models.

### Steps
1) Pick a model you can load on your GPUs (examples):
- `TinyLlama/TinyLlama-1.1B-Chat-v1.0` (open; great first run, low VRAM)
- `Qwen/Qwen2.5-0.5B-Instruct` (tiny; good for low VRAM/testing)
- `mistralai/Mixtral-8x7B-Instruct-v0.1` (larger, requires more VRAM)

2) Start the server

Option A — with the helper script (recommended):
```bash
chmod +x scripts/lesson-02-hello-vllm-server.sh
scripts/lesson-02-hello-vllm-server.sh start \
  -m TinyLlama/TinyLlama-1.1B-Chat-v1.0 \
  -p 8000 \
  --dtype auto
```

Option B — manual command:
```bash
uvx vllm serve TinyLlama/TinyLlama-1.1B-Chat-v1.0 \
  --port 8000 \
  --dtype auto
```

3) Verify health and models:
```bash
curl http://localhost:8000/v1/models | jq
```

4) Stop the server when done:
- With script: `scripts/lesson-02-hello-vllm-server.sh stop`
- Manual: press Ctrl+C in the server terminal

### Notes
- First start will download weights; subsequent starts should reuse the HF cache.
- If ports conflict, change `--port` (script: `-p <port>`).
- Use `TinyLlama/TinyLlama-1.1B-Chat-v1.0` for a fast, open first run with low VRAM. `Qwen/Qwen2.5-0.5B-Instruct` is another small option.
- The script also supports: `status` and `logs -f`.

#### Gated models (Hugging Face auth required)
- Some models like `meta-llama/Llama-3.1-8B-Instruct` are gated. You must have access and be logged in.
- Install the CLI (inside the project `uv` venv):
```bash
source .venv/bin/activate
uv pip install -q "huggingface_hub>=0.23"
```
- Authenticate (inside the project `uv` venv):
```bash
source .venv/bin/activate
uvx huggingface-cli login
# or non-interactive
export HF_TOKEN=<YOUR-HF-TOKEN>
uvx huggingface-cli login --token "$HF_TOKEN" --add-to-git-credential
```
- After logging in, start again (script or manual). If you prefer open models with no auth, use `TinyLlama/TinyLlama-1.1B-Chat-v1.0` (recommended for first run). Other open options:
  - `Qwen/Qwen2.5-0.5B-Instruct`
  - `microsoft/phi-2`

### Exercise
- Try a different model and compare startup time.
- Add `--max-model-len 8192` and note VRAM impact at startup.

### Checkpoint
- You can start and stop vLLM; the `/v1/models` endpoint returns your loaded model.


