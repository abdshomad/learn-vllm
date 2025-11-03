## AGENTS: Run everything in a uv virtual environment

This project uses a `uv`-managed virtual environment for fast, reproducible Python workflows.

Note: In commands and paths, always use the placeholder `<YOUR-WORKING-DIR>/learn-vllm` instead of your actual absolute directory. For example, prefer `cd <YOUR-WORKING-DIR>/learn-vllm` rather than `/home/aiserver/LABS/GPU-CLUSTER/learn-vllm`.

### 1) Prerequisites
- Python 3.10+ available on your PATH
- Install `uv` (one-time):

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
# After install, ensure your shell can find `uv`
uv --version
```

### 2) Create and activate the venv
```bash
cd <YOUR-WORKING-DIR>/learn-vllm
uv venv .venv
source .venv/bin/activate
```

### 3) Install dependencies
- If the project has `pyproject.toml` (preferred):

```bash
uv sync --all-extras --dev
```

- If the project uses `requirements.txt` instead:

```bash
uv pip install -r requirements.txt
```

You can add new packages at any time:

```bash
uv pip install <package-name>
```

### 4) Run your code with uv
- Python modules or scripts:

```bash
uv run python path/to/script.py
```

- Unit tests (examples):

```bash
uv run pytest -q
```

### 5) Jupyter (optional)
```bash
uvx jupyter lab
# or
uvx jupyter notebook
```

### 6) Example: start a vLLM server (OpenAI-compatible)
Pick a model you have access to (e.g., `meta-llama/Llama-3.1-8B-Instruct`). Ensure the model fits your GPU memory.

```bash
# Install vLLM if not already present
uv pip install "vllm>=0.6"

# Start the server (newer vLLM has the `serve` shorthand)
uvx vllm serve meta-llama/Llama-3.1-8B-Instruct \
  --port 8000 \
  --dtype auto

# Alternative (module entrypoint)
uv run python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Llama-3.1-8B-Instruct \
  --port 8000 \
  --dtype auto
```

Then point your client to `http://localhost:8000/v1`.

### 7) GPU/CUDA notes (optional)
- Set CUDA-related env vars as needed, for example:

```bash
export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:256
```

### 8) Deactivate the venv
```bash
deactivate
```

### Troubleshooting
- If `uv` is not found after install, restart your shell or ensure the installer’s bin path is on `PATH`.
- If dependency resolution fails, try `uv clean` then `uv sync` again.
- For GPU issues, confirm correct CUDA toolkit/driver versions and that `torch.cuda.is_available()` returns `True` inside the venv.


