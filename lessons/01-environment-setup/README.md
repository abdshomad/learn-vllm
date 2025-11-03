## 01 — Environment Setup

### Objectives
- Prepare Python with `uv` and create an isolated venv.
- Install vLLM and verify GPU visibility.

### Prerequisites
- Linux with NVIDIA driver and CUDA runtime compatible with your PyTorch build.
- Python 3.10+ on PATH.

### Steps
1) Install `uv` (one-time):
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
uv --version
```

2) Create and activate the venv in the workspace root:
```bash
cd <YOUR-WORKING-DIR>/learn-vllm
uv venv .venv
source .venv/bin/activate
```

3) Install vLLM (and optional extras):
```bash
uv pip install "vllm>=0.6"
# Optional helpers
uv pip install "openai>=1.40" "tiktoken>=0.7" "prometheus-client>=0.19"
```

4) GPU sanity check inside the venv:
```bash
uv run python - << 'PY'
import torch
print('CUDA available:', torch.cuda.is_available())
print('Device count:', torch.cuda.device_count())
PY
```

### Notes
- If `torch.cuda.is_available()` is False, verify drivers, CUDA toolkit, and that the environment can access GPUs.
- You may set `export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:256` to reduce fragmentation.

### Exercise
- Record your `uv --version`, GPU model, and total VRAM.
- Confirm that activating `.venv` places `python` and `pip` from `.venv` first on PATH.

### Checkpoint
- You have an active `uv` environment and vLLM installed; CUDA is visible.


