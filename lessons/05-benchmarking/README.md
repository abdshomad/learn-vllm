## 05 — Benchmarking Latency and Throughput

### Objectives
- Establish baseline latency and tokens/s for single vs multi-GPU.
- Capture the impact of batch size and response length.

### Simple benchmark (Python)
```python
# save as benchmarks/basic_bench.py
import time
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8000/v1", api_key="not-needed")

def run(n_reqs=16, max_tokens=128):
    prompts = [
        {"role":"user","content":"Write a haiku about GPUs."}
    ]
    t0 = time.time()
    for _ in range(n_reqs):
        r = client.chat.completions.create(
            model="meta-llama/Llama-3.1-8B-Instruct",
            messages=prompts,
            max_tokens=max_tokens,
            temperature=0.7,
        )
        _ = r.choices[0].message.content
    dt = time.time() - t0
    print(f"requests={n_reqs}, max_tokens={max_tokens}, total_sec={dt:.2f}, rps={n_reqs/dt:.2f}")

if __name__ == "__main__":
    for max_tokens in (32, 128, 512):
        run(n_reqs=8, max_tokens=max_tokens)
```

### Procedure
1) Run on single GPU and record results.
2) Run with `--tensor-parallel-size 2` and repeat.
3) Optionally, increase concurrency by running multiple processes.

### What to record
- Request latency (p50, p95) and end-to-end tokens/s for different `max_tokens`.
- Observed GPU memory and utilization (`nvidia-smi`).

### Checkpoint
- You have a baseline table for single vs multi-GPU and several output lengths.


