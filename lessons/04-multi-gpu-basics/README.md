## 04 — Multi-GPU Basics (Tensor Parallelism)

### Objectives
- Run vLLM with tensor parallelism on a single multi-GPU node.
- Validate utilization and basic scaling behavior.

### Steps
1) Start with tensor parallel size 2 (adjust to your GPUs):
```bash
uvx vllm serve meta-llama/Llama-3.1-8B-Instruct \
  --port 8000 \
  --dtype auto \
  --tensor-parallel-size 2 \
  --gpu-memory-utilization 0.92
```

2) Validate GPU usage:
```bash
nvidia-smi
```

3) Compare to single-GPU runs on the same prompts.

### Notes
- Larger models or longer `--max-model-len` benefit from multiple GPUs.
- Keep some headroom (`--gpu-memory-utilization`) to avoid OOM under load.

### Exercise
- Try `--tensor-parallel-size 1, 2, 4` and record memory usage differences.
- Observe effect on first-token latency vs decode throughput.

### Checkpoint
- You can launch with TP>1 and see all selected GPUs utilized.


