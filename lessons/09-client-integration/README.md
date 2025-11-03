## 09 — Client Integration Patterns

### Objectives
- Build a thin client wrapper with retries, timeouts, and streaming.
- Coalesce small requests and reuse HTTP connections.

### Python wrapper (example)
```python
# save as clients/wrapper.py
import time
from typing import Iterable, Optional
from openai import OpenAI, APIError

class VLLMClient:
    def __init__(self, base_url: str = "http://localhost:8000/v1", timeout: float = 60.0):
        self.client = OpenAI(base_url=base_url, api_key="not-needed")
        self.timeout = timeout

    def chat(self, messages, model, max_tokens=256, temperature=0.7, retries=3, backoff=0.5):
        for attempt in range(retries):
            try:
                return self.client.chat.completions.create(
                    model=model,
                    messages=messages,
                    max_tokens=max_tokens,
                    temperature=temperature,
                    timeout=self.timeout,
                )
            except APIError:
                if attempt == retries - 1:
                    raise
                time.sleep(backoff * (2 ** attempt))

    def stream_chat(self, messages, model, **kwargs) -> Iterable[str]:
        with self.client.chat.completions.stream(model=model, messages=messages, **kwargs) as stream:
            for event in stream:
                if event.type == "token":
                    yield event.token
```

### Exercises
- Add circuit breaking when consecutive failures exceed a threshold.
- Implement a simple request queue to batch small prompts.

### Checkpoint
- You have a reusable client wrapper with retries, timeouts, and streaming support.


