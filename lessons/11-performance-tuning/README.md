## 11 — Performance Tuning (Multi-GPU)

### Objectives
- Tune core flags to hit target SLOs for latency and throughput.

### Key flags
- `--gpu-memory-utilization 0.90–0.95`: headroom vs capacity
- `--tensor-parallel-size N`: scale across GPUs
- `--max-num-seqs`: concurrent sequences (affects batching)
- `--max-model-len`: cap context to control KV cache

### Procedure
1) Reuse the benchmark script and vary one knob at a time.
2) Plot tokens/s vs `max_num_seqs` and p95 latency vs `max_model_len`.
3) Choose a configuration that balances first-token latency and sustained decode.

### Tips
- Streaming smaller chunks improves UX for long responses.
- Keep HF cache on fast local storage to reduce cold starts.

### Checkpoint
- You have a tuned configuration with documented rationale for the chosen flags.


