"""Demo 04: Gemini 3.8 Flash TTS 语音合成 + Lyria 3.5 音乐生成。"""

from __future__ import annotations

from common import get_client, parse_common_args, print_dry_run, save_base64_media


def main() -> None:
    args = parse_common_args("Gemini 3.8 TTS 与 Lyria 3.5 音乐生成演示")

    tts_req = {
        "model": "gemini-3.8-flash-tts",
        "input": "欢迎使用 Google AI Pro 开发者演示项目！现在你听到的是 Gemini 3.8 Flash TTS 合成的自然语音。",
        "response_format": {"type": "audio"},
        "store": False,
    }
    music_req = {
        "model": "lyria-3.5",
        "input": "Upbeat synthwave instrumental track for a coding demo video, crisp analog bassline, bright arpeggios, 110 BPM.",
        "response_format": {"type": "audio"},
    }

    if args.dry_run:
        print_dry_run("1. 语音合成 (gemini-3.8-flash-tts)", tts_req)
        print_dry_run("2. 音乐生成 (lyria-3.5)", music_req)
        return

    client = get_client(api_version="v1beta")

    print("=== 1. 语音合成 (gemini-3.8-flash-tts) ===")
    tts_resp = client.interactions.create(**tts_req)
    if tts_resp.output_audio:
        out = save_base64_media(tts_resp.output_audio.data, "welcome_tts.wav")
        print(f"已保存语音: {out} (mime={tts_resp.output_audio.mime_type})")

    print("=== 2. 音乐生成 (lyria-3.5) ===")
    music_resp = client.interactions.create(**music_req)
    if music_resp.output_audio:
        ext = "mp3" if "mpeg" in (music_resp.output_audio.mime_type or "") else "wav"
        out = save_base64_media(music_resp.output_audio.data, f"demo_synthwave.{ext}")
        print(f"已保存音乐: {out} (mime={music_resp.output_audio.mime_type})")


if __name__ == "__main__":
    main()
