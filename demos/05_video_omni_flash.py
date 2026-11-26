"""Demo 05: Gemini Omni 1.2 Flash (gemini-omni-1.2-flash) 文生视频（含原生同步音效）。"""

from __future__ import annotations

import time

from common import get_client, parse_common_args, print_dry_run, save_base64_media


def main() -> None:
    args = parse_common_args("Gemini Omni 1.2 Flash 视频生成演示")

    video_req = {
        "model": "gemini-omni-1.2-flash",
        "input": (
            "Cinematic 5-second aerial tracking shot over misty coastal cliffs at golden sunrise, "
            "gentle ocean waves crashing below with natural ambient sea breeze and wave audio."
        ),
        "response_format": {
            "type": "video",
            "aspect_ratio": "16:9",
            "resolution": "1080p",
        },
        "background": True,
    }

    if args.dry_run:
        print_dry_run("Gemini Omni 1.2 Flash 异步视频生成", video_req)
        return

    client = get_client(api_version="v1beta")

    print("=== 提交异步视频生成任务 (gemini-omni-1.2-flash) ===", flush=True)
    job = client.interactions.create(**video_req)
    print(f"Interaction ID: {job.id}, 初始状态: {job.status}", flush=True)

    max_polls = 36  # 最长等待 6 分钟 (36 * 10s)
    polls = 0
    while job.status in ("queued", "in_progress") and polls < max_polls:
        time.sleep(10)
        polls += 1
        job = client.interactions.get(job.id)
        print(f"  轮询状态 ({polls}/{max_polls}): {job.status}", flush=True)

    if job.status != "completed":
        print(f"视频生成未完成或已超时: status={job.status}, error={getattr(job, 'error', None)}")
        return

    output_video = getattr(job, "output_video", None)
    if output_video and getattr(output_video, "data", None):
        out = save_base64_media(output_video.data, "coastal_sunrise.mp4")
        print(f"已保存视频: {out}")
    else:
        print("任务已完成，但未在 output_video.data 中找到内联视频，请检查 job.steps。")


if __name__ == "__main__":
    main()
