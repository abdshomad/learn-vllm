from openai import OpenAI


def main() -> None:
    client = OpenAI(base_url="http://localhost:8001/v1", api_key="not-needed")
    response = client.chat.completions.create(
        model="TinyLlama/TinyLlama-1.1B-Chat-v1.0",
        messages=[{"role": "user", "content": "Say hello in one sentence."}],
        temperature=0.7,
        max_tokens=64,
    )
    print(response.choices[0].message.content)


if __name__ == "__main__":
    main()


