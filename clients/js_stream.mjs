import OpenAI from "openai";

const client = new OpenAI({ baseURL: "http://localhost:8001/v1", apiKey: "not-needed" });

const stream = await client.chat.completions.create({
  model: "TinyLlama/TinyLlama-1.1B-Chat-v1.0",
  messages: [{ role: "user", content: "Stream a short poem." }],
  stream: true,
});

for await (const part of stream) {
  if (part.choices?.[0]?.delta?.content) process.stdout.write(part.choices[0].delta.content);
}


