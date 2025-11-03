# learn-vllm

## About
Hands-on learning path for vLLM focused on running a local OpenAI-compatible server on a single multi-GPU node, then progressing to tuning, observability, and production hygiene.

## Quick start
1) Create and activate an environment with `uv`:
```bash
cd <YOUR-WORKING-DIR>/learn-vllm
uv venv .venv
source .venv/bin/activate
```

2) Install vLLM and client SDKs:
```bash
uv pip install "vllm>=0.6" "openai>=1.40"
```

3) Start a local server (choose a model you can run):
```bash
uvx vllm serve TinyLlama/TinyLlama-1.1B-Chat-v1.0 \
  --port 8000 \
  --dtype auto
```

4) Verify:
```bash
curl http://localhost:8000/v1/models | jq
```

## Learn the course
Start here and follow lessons in order:
- lessons/README.md

## Repository structure
- lessons/: 13 step-by-step lessons with objectives, steps, and exercises
- AGENTS.md: workspace agent notes

## Requirements
- Linux with NVIDIA GPU(s), matching driver/CUDA runtime for PyTorch
- Python 3.10+
- Internet access for model downloads

## Notes
- Replace `<YOUR-WORKING-DIR>` with your actual working directory.
