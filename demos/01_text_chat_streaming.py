"""Demo 01: Gemini 4 Neon / Hydrogen 流式输出与服务端多轮状态 (Interactions API)。"""

from __future__ import annotations

from common import get_client, parse_common_args, print_dry_run


def main() -> None:
    args = parse_common_args("Gemini 4 流式生成与服务端多轮对话演示")

    stream_req = {
        "model": "gemini-4-neon",
        "input": "用 4 句话概括为什么 Google AI Pro 对个人开发者很划算。",
        "stream": True,
    }
    turn1_req = {
        "model": "gemini-4-hydrogen",
        "input": "你好，我正在规划一个利用 Colab 200 CU 的开源实验项目，代号 Project Nova。",
    }
    turn2_req = {
        "model": "gemini-4-hydrogen",
        "input": "请记住我的项目代号，并给我 3 条节省 Colab GPU Compute Units 的建议。",
        "previous_interaction_id": "<turn1.id>",
    }

    if args.dry_run:
        print_dry_run("1. 流式生成 (Gemini 4 Neon)", stream_req)
        print_dry_run("2. 服务端多轮对话 - Turn 1", turn1_req)
        print_dry_run("3. 服务端多轮对话 - Turn 2", turn2_req)
        return

    client = get_client()

    print("=== 1. 流式输出 (gemini-4-neon) ===")
    for event in client.interactions.create(**stream_req):
        if event.event_type == "step.delta" and event.delta.type == "text":
            print(event.delta.text, end="", flush=True)
        elif event.event_type == "interaction.completed" and event.interaction.usage:
            print(f"\n\n[Total Tokens: {event.interaction.usage.total_tokens}]\n")

    print("=== 2. 服务端多轮对话 (store=True 默认开启) ===")
    t1 = client.interactions.create(**turn1_req)
    print(f"Turn 1 (id={t1.id}):\n{t1.output_text}\n")

    t2 = client.interactions.create(
        model="gemini-4-hydrogen",
        input=turn2_req["input"],
        previous_interaction_id=t1.id,
    )
    print(f"Turn 2 (id={t2.id}):\n{t2.output_text}")


if __name__ == "__main__":
    main()
