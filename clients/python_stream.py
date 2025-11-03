from openai import OpenAI


def main() -> None:
    client = OpenAI(base_url="http://localhost:8001/v1", api_key="not-needed")
    stream = client.chat.completions.create(
        model="TinyLlama/TinyLlama-1.1B-Chat-v1.0",
        messages=[{"role": "user", "content": "Stream a short poem."}],
        temperature=0.7,
        max_tokens=128,
        stream=True,
    )

    for chunk in stream:
        try:
            delta = chunk.choices[0].delta
            if getattr(delta, "content", None):
                print(delta.content, end="", flush=True)
        except Exception:
            continue


if __name__ == "__main__":
    main()


