"""Demo 03: Nano Banana 2.1 (gemini-nano-banana-2.1) 文生图与对话式多轮编辑。"""

from __future__ import annotations

from common import get_client, parse_common_args, print_dry_run, save_base64_media


def main() -> None:
    args = parse_common_args("Nano Banana 2.1 文生图与多轮修图演示")

    gen_req = {
        "model": "gemini-nano-banana-2.1",
        "input": "A sleek isometric illustration of a futuristic developer workstation with floating glowing code panels and a miniature cloud server, clean soft studio lighting.",
        "response_format": {
            "type": "image",
            "aspect_ratio": "16:9",
            "image_size": "2K",
        },
    }
    edit_req = {
        "model": "gemini-nano-banana-2.1",
        "input": "Change the lighting to a warm cyberpunk neon sunset and add a small coffee cup on the desk.",
        "previous_interaction_id": "<turn1.id>",
        "response_format": {
            "type": "image",
            "aspect_ratio": "16:9",
            "image_size": "2K",
        },
    }

    if args.dry_run:
        print_dry_run("1. 文生图 (gemini-nano-banana-2.1)", gen_req)
        print_dry_run("2. 多轮对话式编辑", edit_req)
        return

    client = get_client()

    print("=== 1. 生成原图 ===")
    t1 = client.interactions.create(**gen_req)
    if not t1.output_image:
        print("未返回生成图像，跳过第 2 步修图。")
        return

    ext = "jpg" if "jpeg" in (t1.output_image.mime_type or "") else "png"
    p1 = save_base64_media(t1.output_image.data, f"workstation_v1.{ext}")
    print(f"已保存原图: {p1} (interaction_id={t1.id})")

    print("=== 2. 基于 previous_interaction_id 对话式修图 ===")
    t2 = client.interactions.create(
        model=edit_req["model"],
        input=edit_req["input"],
        previous_interaction_id=t1.id,
        response_format=edit_req["response_format"],
    )
    if t2.output_image:
        ext = "jpg" if "jpeg" in (t2.output_image.mime_type or "") else "png"
        p2 = save_base64_media(t2.output_image.data, f"workstation_v2_sunset.{ext}")
        print(f"已保存修图: {p2} (interaction_id={t2.id})")


if __name__ == "__main__":
    main()
