"""Demo 07: Antigravity 远程 Linux 沙盒 Agent + 挂载 google-gemini/gemini-skills 仓库 (v1beta)。"""

from __future__ import annotations

from common import get_client, parse_common_args, print_dry_run


def main() -> None:
    args = parse_common_args("Antigravity 远程沙盒 Agent + 挂载 gemini-skills 演示")

    req = {
        "api_version": "v1beta",
        "agent": "antigravity-preview-09-2026",
        "agent_config": {
            "type": "antigravity",
            "model": "gemini-4-neon",
        },
        "input": (
            "1. 检查 .agents 目录中挂载的 google-gemini/gemini-skills 技能清单；\n"
            "2. 写一个 Python 脚本 benchmark_sort.py，对比内置 timsort 与 heapq.nsmallest 在 50,000 个随机数上的耗时；\n"
            "3. 运行脚本并将汇总结果保存到 summary.txt，最后打印 summary.txt 内容。"
        ),
        "environment": {
            "type": "remote",
            "sources": [
                {
                    "type": "repository",
                    "source": "https://github.com/google-gemini/gemini-skills",
                    "target": ".agents",
                }
            ],
        },
    }

    if args.dry_run:
        print_dry_run("Antigravity 远程沙盒 Agent (挂载 gemini-skills)", req)
        return

    client = get_client(api_version="v1beta")

    print("=== 启动 Antigravity 远程沙盒 Agent (Gemini 4 Neon + gemini-skills) ===")
    interaction = client.interactions.create(
        agent=req["agent"],
        agent_config=req["agent_config"],
        input=req["input"],
        environment=req["environment"],
    )
    print(f"Environment ID: {interaction.environment_id}")
    print("\n--- Agent 输出 ---")
    print(interaction.output_text)
    print(
        "\n提示：可用 gemini-api CLI 下载沙盒内文件：\n"
        f"  gemini-api environments files list -e {interaction.environment_id} -r\n"
        f"  gemini-api environments files download {interaction.environment_id} summary.txt --out outputs/summary.txt"
    )


if __name__ == "__main__":
    main()
