#!/usr/bin/env bash
set -euo pipefail

# Workspace root (use current working directory)
ROOT_DIR="$(pwd)"
SCRIPTS_DIR="$ROOT_DIR/scripts"
LOG_DIR="$SCRIPTS_DIR/logs"
mkdir -p "$LOG_DIR"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="$LOG_DIR/00-environment-setup-$TIMESTAMP.log"
PID_FILE="$LOG_DIR/00-environment-setup.pid"

{
  echo "[INFO] Starting environment setup at $TIMESTAMP"
  echo "[INFO] Root: $ROOT_DIR"

  cd "$ROOT_DIR"

  # Ensure uv is available
  if ! command -v uv >/dev/null 2>&1; then
    echo "[INFO] Installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
  fi
  echo -n "[INFO] uv version: "
  uv --version || true

  # Create venv if missing
  if [ ! -d "$ROOT_DIR/.venv" ]; then
    echo "[INFO] Creating .venv..."
    uv venv .venv
  else
    echo "[INFO] .venv already exists"
  fi

  # Activate venv
  # shellcheck disable=SC1091
  source "$ROOT_DIR/.venv/bin/activate"
  echo "[INFO] Python: $(python -V)"
  echo "[INFO] Python path: $(which python)"

  # Install core packages
  echo "[INFO] Installing vLLM and helpers..."
  uv pip install "vllm>=0.6" "openai>=1.40" "tiktoken>=0.7" "prometheus-client>=0.19"

  # GPU sanity check
  echo "[INFO] Running GPU sanity check via torch..."
  uv run python - << 'PY'
import torch
print('CUDA available:', torch.cuda.is_available())
print('Device count:', torch.cuda.device_count())
if torch.cuda.is_available() and torch.cuda.device_count() > 0:
    print('Current device:', torch.cuda.current_device())
    print('Device name:', torch.cuda.get_device_name(0))
PY

  # Optional: capture nvidia-smi summary
  if command -v nvidia-smi >/dev/null 2>&1; then
    echo "[INFO] nvidia-smi summary:" 
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader || true
  fi

  echo "[INFO] Environment setup completed."
} | tee "$LOG_FILE"

# PID tracking (script is short-lived; record our own PID for audit)
echo $$ > "$PID_FILE"
echo "[INFO] PID recorded at $PID_FILE" | tee -a "$LOG_FILE"

exit 0


