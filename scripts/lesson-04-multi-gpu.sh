#!/usr/bin/env bash
set -euo pipefail

# lesson-04-multi-gpu.sh
# Start/stop a multi-GPU vLLM server using tensor parallelism.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/scripts/logs"
PID_FILE="$LOG_DIR/lesson-04-multi-gpu.pid"

DEFAULT_MODEL="TinyLlama/TinyLlama-1.1B-Chat-v1.0"
DEFAULT_PORT="8000"
DEFAULT_DTYPE="auto"
DEFAULT_TP_SIZE="2"
DEFAULT_GPU_UTIL="0.92"

usage() {
  cat <<EOF
Usage: $(basename "$0") <start|stop|status|logs|test> [options]

Commands:
  start                Start vLLM server with tensor parallelism in background
  stop                 Stop running vLLM server
  status               Show server status (PID/port/listen)
  logs [-f]            Show latest server log (use -f to follow)
  test [opts]          Send a test chat request to the server

Options for start:
  -m, --model MODEL            HF model id (default: $DEFAULT_MODEL)
  -p, --port PORT              Starting port to try (default: $DEFAULT_PORT)
  --dtype DTYPE                Data type, e.g. auto, float16, bfloat16 (default: $DEFAULT_DTYPE)
  --tp N                       Tensor parallel size (default: $DEFAULT_TP_SIZE)
  --gpu-memory-utilization V   Fraction [0-1] (default: $DEFAULT_GPU_UTIL)
  --max-model-len N            Optional max model length
  --gpus CSV                   Optional CUDA devices, e.g. 0,1 or 0,2 (sets CUDA_VISIBLE_DEVICES)

Options for test:
  -p, --port PORT              Server port (default: $DEFAULT_PORT)
  -q, --query PROMPT           User prompt (default: "Say hello in one sentence.")
EOF
}

ensure_uv_env() {
  cd "$PROJECT_ROOT"
  if [[ ! -d .venv ]]; then
    echo "[setup] Creating uv virtual environment at .venv"
    uv venv .venv
  fi
  # shellcheck disable=SC1091
  source .venv/bin/activate
  # Ensure vLLM is available
  uv pip install -q "vllm>=0.6"
}

ensure_log_dir() {
  mkdir -p "$LOG_DIR"
}

find_free_port() {
  local start_port="$1"
  local candidate="$start_port"
  for _ in $(seq 0 200); do
    if ss -ltn | grep -q ":${candidate}\\b"; then
      candidate=$((candidate + 1))
    else
      echo "$candidate"
      return 0
    fi
  done
  echo "" # no port found
  return 1
}

start_server() {
  local model="$DEFAULT_MODEL"
  local port="$DEFAULT_PORT"
  local dtype="$DEFAULT_DTYPE"
  local tp_size="$DEFAULT_TP_SIZE"
  local gpu_util="$DEFAULT_GPU_UTIL"
  local max_model_len=""
  local gpus=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -m|--model) model="$2"; shift 2 ;;
      -p|--port) port="$2"; shift 2 ;;
      --dtype) dtype="$2"; shift 2 ;;
      --tp) tp_size="$2"; shift 2 ;;
      --gpu-memory-utilization) gpu_util="$2"; shift 2 ;;
      --max-model-len) max_model_len="$2"; shift 2 ;;
      --gpus) gpus="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
    esac
  done

  ensure_log_dir
  ensure_uv_env

  if [[ -f "$PID_FILE" ]] && ps -p "$(cat "$PID_FILE" 2>/dev/null)" >/dev/null 2>&1; then
    echo "[start] Server already running with PID $(cat "$PID_FILE")" >&2
    exit 0
  fi

  local free_port
  free_port="$(find_free_port "$port" || true)"
  if [[ -z "$free_port" ]]; then
    echo "[start] Could not find a free port starting at $port within range." >&2
    exit 1
  fi
  if [[ "$free_port" != "$port" ]]; then
    echo "[start] Port $port busy; using next available port $free_port"
  fi
  port="$free_port"

  local ts log_file
  ts="$(date +%Y%m%d-%H%M%S)"
  log_file="$LOG_DIR/lesson-04-multi-gpu-${port}-${ts}.log"

  local -a cmd
  cmd=(uvx vllm serve "$model" --port "$port" --dtype "$dtype" --tensor-parallel-size "$tp_size" --gpu-memory-utilization "$gpu_util")
  if [[ -n "$max_model_len" ]]; then
    cmd+=(--max-model-len "$max_model_len")
  fi

  if [[ -n "$gpus" ]]; then
    export CUDA_VISIBLE_DEVICES="$gpus"
    echo "[start] Using CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES" | tee -a "$log_file"
  fi

  echo "[start] Launching: ${cmd[*]}" | tee -a "$log_file"
  nohup "${cmd[@]}" >"$log_file" 2>&1 &
  echo $! > "$PID_FILE"
  echo "[start] PID $(cat "$PID_FILE") | port $port | log $log_file"

  sleep 3
  "$0" status || true
}

stop_server() {
  if [[ ! -f "$PID_FILE" ]]; then
    echo "[stop] No PID file found at $PID_FILE"
    exit 0
  fi
  local pid
  pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  if [[ -z "$pid" ]]; then
    echo "[stop] PID file empty; removing"
    rm -f "$PID_FILE"
    exit 0
  fi
  if ! ps -p "$pid" >/dev/null 2>&1; then
    echo "[stop] Process $pid not running; removing PID file"
    rm -f "$PID_FILE"
    exit 0
  fi
  echo "[stop] Terminating PID $pid"
  kill "$pid" || true
  for i in {1..20}; do
    if ps -p "$pid" >/dev/null 2>&1; then
      sleep 0.5
    else
      break
    fi
  done
  if ps -p "$pid" >/dev/null 2>&1; then
    echo "[stop] Force killing PID $pid"
    kill -9 "$pid" || true
  fi
  rm -f "$PID_FILE"
  echo "[stop] Stopped"
}

status_server() {
  local pid=""
  if [[ -f "$PID_FILE" ]]; then
    pid="$(cat "$PID_FILE" 2>/dev/null || true)"
  fi
  if [[ -n "$pid" ]] && ps -p "$pid" >/dev/null 2>&1; then
    echo "[status] Running | PID $pid"
  else
    echo "[status] Not running"
  fi
  ss -ltnp | awk 'NR==1 || /:8000 |:8010 |:8020 |:80[2-9][0-9] / {print}' || true
}

logs_view() {
  local follow="false"
  if [[ "${1:-}" == "-f" ]]; then
    follow="true"
  fi
  ensure_log_dir
  local latest
  latest="$(ls -1t "$LOG_DIR"/lesson-04-multi-gpu-*.log 2>/dev/null | head -n 1 || true)"
  if [[ -z "$latest" ]]; then
    echo "[logs] No logs found in $LOG_DIR"
    exit 0
  fi
  echo "[logs] Showing $latest"
  if [[ "$follow" == "true" ]]; then
    tail -f "$latest"
  else
    tail -n 200 "$latest"
  fi
}

test_query() {
  local port="$DEFAULT_PORT"
  local prompt="Say hello in one sentence."

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p|--port) port="$2"; shift 2 ;;
      -q|--query) prompt="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
    esac
  done

  if ! curl -s "http://localhost:${port}/v1/models" >/dev/null; then
    echo "[test] Server not reachable at http://localhost:${port}. Start it first." >&2
    exit 1
  fi

  local payload response
  if command -v jq >/dev/null 2>&1; then
    payload="$(jq -n --arg prompt "$prompt" '{model:"", messages:[{role:"user", content:$prompt}], max_tokens:64}')"
  else
    payload='{"model":"","messages":[{"role":"user","content":"'"$prompt"'"}],"max_tokens":64}'
  fi

  response="$(curl -s -X POST "http://localhost:${port}/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -d "$payload")"

  if command -v jq >/dev/null 2>&1; then
    echo "$response" | jq -r '.choices[0].message.content // .'
  else
    echo "$response"
  fi
}

main() {
  local cmd="${1:-}"
  shift || true
  case "$cmd" in
    start) start_server "$@" ;;
    stop) stop_server ;;
    status) status_server ;;
    logs) logs_view "$@" ;;
    test) test_query "$@" ;;
    -h|--help|"") usage ;;
    *) echo "Unknown command: $cmd" >&2; usage; exit 1 ;;
  esac
}

main "$@"


