## 06 — Quantization (FP8, AWQ, GPTQ)

### Objectives
- Reduce VRAM usage via quantization and compare quality/perf trade-offs.

### Examples
1) FP8/FP16 (where supported):
```bash
uvx vllm serve meta-llama/Llama-3.1-8B-Instruct \
  --port 8000 \
  --dtype auto
```

2) AWQ (if the model has AWQ weights):
```bash
uvx vllm serve <awq-capable-model> \
  --port 8000 \
  --quantization awq
```

3) GPTQ (if GPTQ weights are available):
```bash
uvx vllm serve <gptq-capable-model> \
  --port 8000 \
  --quantization gptq
```

### Procedure
- For each configuration, record:
  - VRAM usage at rest (`nvidia-smi`), first-token latency, tokens/s.
  - Subjective quality on a small eval set (e.g., math, coding, writing prompts).

### Notes
- Quantization support varies by model and vLLM version.
- Expect some quality degradation; measure if acceptable for your use-case.

### Checkpoint
- You have a table summarizing VRAM savings vs latency vs perceived quality.


