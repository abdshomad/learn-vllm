#!/usr/bin/env bash
set -euo pipefail

# lesson-02-hello-vllm-server.sh
# Manage a local OpenAI-compatible vLLM server using the project's uv environment.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_DIR="$PROJECT_ROOT/scripts/logs"
PID_FILE="$LOG_DIR/lesson-02-hello-vllm-server.pid"

DEFAULT_MODEL="meta-llama/Llama-3.1-8B-Instruct"
DEFAULT_PORT="8000"
DEFAULT_DTYPE="auto"

usage() {
  cat <<EOF
Usage: $(basename "$0") <start|stop|status|logs|test> [options]

Commands:
  start                Start vLLM server in background
  stop                 Stop running vLLM server
  status               Show server status (PID/port/listen)
  logs [-f]            Show latest server log (use -f to follow)
  test [opts]          Send a test chat request to the server

Options for start:
  -m, --model MODEL            HF model id (default: $DEFAULT_MODEL)
  -p, --port PORT              Port to listen on (default: $DEFAULT_PORT)
  --dtype DTYPE                Data type, e.g. auto, float16, bfloat16 (default: $DEFAULT_DTYPE)
  --max-model-len N            Optional max model length

Options for test:
  -m, --model MODEL            Model name served by the API (optional)
  -p, --port PORT              Server port (default: $DEFAULT_PORT)
  -q, --query PROMPT           User prompt (default: "Say hello in one sentence.")

Examples:
  $(basename "$0") start -m "$DEFAULT_MODEL" -p 8000 --dtype auto
  $(basename "$0") status
  $(basename "$0") logs -f
  $(basename "$0") test -p 8000 -q "What is vLLM?"
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

start_server() {
  local model="$DEFAULT_MODEL"
  local port="$DEFAULT_PORT"
  local dtype="$DEFAULT_DTYPE"
  local max_model_len=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -m|--model)
        model="$2"; shift 2 ;;
      -p|--port)
        port="$2"; shift 2 ;;
      --dtype)
        dtype="$2"; shift 2 ;;
      --max-model-len)
        max_model_len="$2"; shift 2 ;;
      -h|--help)
        usage; exit 0 ;;
      *)
        echo "Unknown option: $1" >&2; usage; exit 1 ;;
    esac
  done

  ensure_log_dir
  ensure_uv_env

  if [[ -f "$PID_FILE" ]] && ps -p "$(cat "$PID_FILE" 2>/dev/null)" >/dev/null 2>&1; then
    echo "[start] Server already running with PID $(cat "$PID_FILE")" >&2
    exit 0
  fi

  # Find an available port incrementally if requested port is busy
  try_port="$port"
  for _ in $(seq 0 50); do
    if ss -ltn | grep -q ":${try_port}\\b"; then
      try_port=$((try_port + 1))
    else
      break
    fi
  done
  if ss -ltn | grep -q ":${try_port}\\b"; then
    echo "[start] Could not find a free port starting at $port within 51 attempts." >&2
    exit 1
  fi
  if [[ "$try_port" != "$port" ]]; then
    echo "[start] Port $port busy; using next available port $try_port"
  fi
  port="$try_port"

  ts="$(date +%Y%m%d-%H%M%S)"
  log_file="$LOG_DIR/lesson-02-hello-vllm-server-${port}-${ts}.log"

  cmd=(uvx vllm serve "$model" --port "$port" --dtype "$dtype")
  if [[ -n "$max_model_len" ]]; then
    cmd+=(--max-model-len "$max_model_len")
  fi

  echo "[start] Launching: ${cmd[*]}" | tee -a "$log_file"
  # Run in background with nohup, capture PID
  nohup "${cmd[@]}" >"$log_file" 2>&1 &
  echo $! > "$PID_FILE"
  echo "[start] PID $(cat "$PID_FILE") | log $log_file"

  # Brief wait then print status
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
  # Graceful wait, then SIGKILL if necessary
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
  # Show listeners for common ports
  ss -ltnp | awk 'NR==1 || /:8000 |:8010 |:8020 / {print}' || true
}

logs_view() {
  local follow="false"
  if [[ "${1:-}" == "-f" ]]; then
    follow="true"
  fi
  ensure_log_dir
  local latest
  latest="$(ls -1t "$LOG_DIR"/lesson-02-hello-vllm-server-*.log 2>/dev/null | head -n 1 || true)"
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
  local model=""
  local port="$DEFAULT_PORT"
  local prompt="Say hello in one sentence."

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -m|--model)
        model="$2"; shift 2 ;;
      -p|--port)
        port="$2"; shift 2 ;;
      -q|--query)
        prompt="$2"; shift 2 ;;
      -h|--help)
        usage; exit 0 ;;
      *)
        echo "Unknown option: $1" >&2; usage; exit 1 ;;
    esac
  done

  # Verify server is reachable
  if ! curl -s "http://localhost:${port}/v1/models" >/dev/null; then
    echo "[test] Server not reachable at http://localhost:${port}. Start it first." >&2
    exit 1
  fi

  # If model not provided, try to detect first available via jq; fallback to DEFAULT_MODEL
  if [[ -z "$model" ]]; then
    if command -v jq >/dev/null 2>&1; then
      model="$(curl -s "http://localhost:${port}/v1/models" | jq -r '.data[0].id // empty')"
    fi
    if [[ -z "$model" ]]; then
      model="$DEFAULT_MODEL"
    fi
  fi

  echo "[test] Using model: $model"
  echo "[test] Prompt: $prompt"

  # Build JSON payload safely; prefer jq if available
  local payload
  if command -v jq >/dev/null 2>&1; then
    payload="$(jq -n --arg model "$model" --arg prompt "$prompt" '{model:$model, messages:[{role:"user", content:$prompt}], max_tokens:128}')"
  else
    # Fallback minimal escaping (no jq). Newlines/quotes in prompt may break.
    payload='{"model":"'"$model"'","messages":[{"role":"user","content":"'"$prompt"'"}],"max_tokens":128}'
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


