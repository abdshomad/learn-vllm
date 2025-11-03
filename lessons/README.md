## vLLM Learning Path

Local OpenAI-compatible serving on a single multi-GPU node. Start at 01 and proceed in order.

### Course Index
- [01 — Environment Setup](01-environment-setup/README.md)
  - Install `uv`, create a virtual environment, install `vllm`, and verify CUDA.
- [02 — Hello vLLM Server](02-hello-vllm-server/README.md)
  - Start a minimal vLLM server, confirm `/v1/models`, and explore basic flags.
- [03 — Clients: Python and Node.js](03-clients-python-js/README.md)
  - Call chat completions via OpenAI-compatible APIs; implement streaming.
- [04 — Multi-GPU Basics](04-multi-gpu-basics/README.md)
  - Enable tensor parallelism, validate GPU utilization, and compare to single GPU.
- [05 — Benchmarking](05-benchmarking/README.md)
  - Establish latency and tokens/s baselines across batch sizes and lengths.
- [06 — Quantization](06-quantization/README.md)
  - Try FP16/FP8/AWQ/GPTQ; record VRAM savings vs. quality/perf trade-offs.
- [07 — Advanced Decoding](07-advanced-decoding/README.md)
  - Use speculative decoding and prefix caching to improve throughput.
- [08 — LoRA Adapters](08-lora-adapters/README.md)
  - Load multiple LoRA adapters and switch at runtime per request.
- [09 — Client Integration Patterns](09-client-integration/README.md)
  - Build a small wrapper with retries, timeouts, batching, and streaming.
- [10 — Observability](10-observability/README.md)
  - Add logging and metrics; optional tracing; visualize latency and errors.
- [11 — Performance Tuning](11-performance-tuning/README.md)
  - Tune key flags (`gpu_memory_utilization`, `max_num_seqs`, `max_model_len`).
- [12 — Production Hygiene](12-production-hygiene/README.md)
  - Harden with limits, auth proxy, TLS, and one-command startup.
- [13 — Success Criteria](13-success-criteria/README.md)
  - Validate SLOs, collect artifacts, and finalize a repeatable runbook.

### Conventions
- Workspace root: `<YOUR-WORKING-DIR>/learn-vllm`
- Use `uv` virtual environments and commands
- Server base URL: `http://localhost:8000/v1`
