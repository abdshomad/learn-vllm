## 03 — Clients: Python and Node.js

### Objectives
- Call the vLLM server via OpenAI-compatible APIs.
- Implement non-streaming and streaming requests.

### Python (OpenAI SDK)
```bash
uv pip install "openai>=1.40"
```
```python
# save as clients/python_basic.py
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8000/v1", api_key="not-needed")

resp = client.chat.completions.create(
    model="meta-llama/Llama-3.1-8B-Instruct",
    messages=[{"role":"user","content":"Say hello in one sentence."}],
    temperature=0.7,
    max_tokens=64,
)
print(resp.choices[0].message.content)
```

### Python streaming
```python
# save as clients/python_stream.py
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8000/v1", api_key="not-needed")

with client.chat.completions.stream(
    model="meta-llama/Llama-3.1-8B-Instruct",
    messages=[{"role":"user","content":"Stream a short poem."}],
) as stream:
    for event in stream:
        if event.type == "token":
            print(event.token, end="", flush=True)
```

### Node.js (OpenAI SDK)
```bash
# from project root (use your Node env)
npm i openai@^4
```
```javascript
// save as clients/js_basic.mjs
import OpenAI from "openai";
const client = new OpenAI({ baseURL: "http://localhost:8000/v1", apiKey: "not-needed" });

const resp = await client.chat.completions.create({
  model: "meta-llama/Llama-3.1-8B-Instruct",
  messages: [{ role: "user", content: "Say hello in one sentence." }],
  max_tokens: 64,
});
console.log(resp.choices[0].message.content);
```

### Node.js streaming
```javascript
// save as clients/js_stream.mjs
import OpenAI from "openai";
const client = new OpenAI({ baseURL: "http://localhost:8000/v1", apiKey: "not-needed" });

const stream = await client.chat.completions.create({
  model: "meta-llama/Llama-3.1-8B-Instruct",
  messages: [{ role: "user", content: "Stream a short poem." }],
  stream: true,
});
for await (const part of stream) {
  if (part.choices?.[0]?.delta?.content) process.stdout.write(part.choices[0].delta.content);
}
```

### Exercises
- Compare latency between non-streaming vs streaming for short vs long outputs.
- Try `temperature={0.0, 0.7, 1.0}` and a custom `stop` sequence.

### Checkpoint
- You can reliably call the server from Python and Node with and without streaming.


