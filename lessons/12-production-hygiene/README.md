## 12 — Production Hygiene (Local)

### Objectives
- Harden the local server environment for reliability and security.

### Stability and limits
- Enforce prompt/output caps and reasonable `--max-model-len`.
- Set request timeouts and size limits at the proxy.

### Security
- Place vLLM behind a reverse proxy (e.g., nginx/traefik) with token auth and TLS.
- Restrict access to localhost or a private network segment.

### Reliability
- Health checks on `/v1/models`.
- Graceful shutdown; preserve weights cache between restarts.

### Packaging
- Pin versions (vLLM, CUDA, drivers). Create a startup script or systemd unit.

### Checkpoint
- You can start the server with one command, and it’s protected behind a basic auth proxy with TLS.


