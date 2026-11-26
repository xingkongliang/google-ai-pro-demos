"""Demo 06: Deep Research 托管研究代理 (deep-research-preview-04-2026, v1beta 后台轮询)。"""

from __future__ import annotations

import time

from common import ensure_outputs_dir, get_client, parse_common_args, print_dry_run


def main() -> None:
    args = parse_common_args("Deep Research 后台深度调研演示")

    req = {
        "api_version": "v1beta",
        "agent": "deep-research-preview-04-2026",
        "input": "调研 2026 年个人开发者使用 Google Cloud Run 与 Cloudflare Workers 的成本与冷启动延迟对比，给出带出处的总结报告。",
        "background": True,
    }

    if args.dry_run:
        print_dry_run("Deep Research 后台调研任务 (v1beta)", req)
        return

    client = get_client(api_version="v1beta")

    print("=== 启动 Deep Research 后台任务 ===", flush=True)
    interaction = client.interactions.create(
        agent=req["agent"],
        input=req["input"],
        background=True,
    )
    print(f"Run ID: {interaction.id} (status={interaction.status})", flush=True)

    max_polls = 90  # 最长等待 15 分钟 (90 * 10s)
    for poll in range(1, max_polls + 1):
        interaction = client.interactions.get(interaction.id)
        print(f"  当前状态 ({poll}/{max_polls}): {interaction.status}", flush=True)
        if interaction.status == "completed":
            report_path = ensure_outputs_dir() / "deep_research_report.md"
            report_path.write_text(interaction.output_text or "", encoding="utf-8")
            print(f"\n调研完成！报告已保存到: {report_path}", flush=True)
            return
        if interaction.status not in ("queued", "in_progress"):
            print(
                f"调研中止或需要交互: status={interaction.status}, error={getattr(interaction, 'error', None)}",
                flush=True,
            )
            if interaction.output_text:
                report_path = ensure_outputs_dir() / "deep_research_report.md"
                report_path.write_text(interaction.output_text, encoding="utf-8")
                print(f"已保存当前输出到: {report_path}", flush=True)
            return
        time.sleep(10)
    print(f"轮询超时（已等待 {max_polls * 10}s），请稍后通过 Interaction ID {interaction.id} 查询结果。", flush=True)


if __name__ == "__main__":
    main()
