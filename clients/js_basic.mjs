import OpenAI from "openai";

const client = new OpenAI({ baseURL: "http://localhost:8001/v1", apiKey: "not-needed" });

const resp = await client.chat.completions.create({
  model: "TinyLlama/TinyLlama-1.1B-Chat-v1.0",
  messages: [{ role: "user", content: "Say hello in one sentence." }],
  max_tokens: 64,
});
console.log(resp.choices[0].message.content);


