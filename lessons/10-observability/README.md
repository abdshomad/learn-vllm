## 10 — Observability: Logs, Metrics, Tracing

### Objectives
- Add basic request logging and Prometheus-style metrics.
- Optionally instrument client calls with OpenTelemetry.

### Logging
- Run the server with verbose logs when debugging; redact sensitive content in any persisted logs.

### Metrics (Python client-side example)
```python
# save as observability/metrics_wrapper.py
import time
from prometheus_client import Counter, Summary, start_http_server
from openai import OpenAI

REQS = Counter('vllm_requests_total', 'Total requests')
ERRS = Counter('vllm_errors_total', 'Total errors')
LAT = Summary('vllm_request_seconds', 'Request latency')

class MeasuredClient:
    def __init__(self, port=9100):
        start_http_server(port)
        self.client = OpenAI(base_url="http://localhost:8000/v1", api_key="not-needed")

    @LAT.time()
    def chat(self, messages, model):
        REQS.inc()
        try:
            return self.client.chat.completions.create(model=model, messages=messages)
        except Exception:
            ERRS.inc()
            raise
```

### Tracing (optional)
- Wrap calls with OpenTelemetry for distributed traces if you have a collector.

### Exercise
- Expose metrics on `:9100` and build a quick Grafana dashboard showing requests, errors, and latency.

### Checkpoint
- You can observe request counts and latency trends while testing.


