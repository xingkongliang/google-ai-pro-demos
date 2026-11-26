#!/usr/bin/env bash
set -euo pipefail

# Demo 02: 多媒体生成（Nano Banana 2.1 生图/修图、Gemini 3.8 TTS 多人对话、Lyria 3.5 音乐、Omni 1.2 视频）
# 用法:
#   bash scripts/cli_demos/02_media_generation.sh --dry-run
#   bash scripts/cli_demos/02_media_generation.sh

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)/outputs/cli"
mkdir -p "$OUT_DIR"

run_cli() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    if command -v gemini-api >/dev/null 2>&1; then
      echo "+ gemini-api $* --dry-run"
      gemini-api "$@" --dry-run
    else
      echo "[DRY-RUN PREVIEW] gemini-api $*"
    fi
  else
    if ! command -v gemini-api >/dev/null 2>&1; then
      echo "错误：未安装 gemini-api CLI。" >&2
      exit 1
    fi
    echo "+ gemini-api $*"
    gemini-api "$@"
  fi
}

echo "=== 1. 文生图 (gemini-nano-banana-2.1, 16:9, 2K) ==="
run_cli image "Isometric minimalist developer desk with glowing holographic terminal, clean studio lighting" \
  --aspect-ratio 16:9 \
  --image-size 2K \
  --body '{"response_format": {"mime_type": "image/jpeg"}}' \
  --out "$OUT_DIR/hero.jpg"

echo
echo "=== 2. 对话式修图 (基于上一步产物) ==="
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "[DRY-RUN PREVIEW] gemini-api image 'Add warm golden hour sunset lighting' -i '$OUT_DIR/hero.jpg' --out '$OUT_DIR/hero-sunset.jpg'"
else
  run_cli image "Add warm golden hour sunset lighting" \
    -i "$OUT_DIR/hero.jpg" \
    --body '{"response_format": {"mime_type": "image/jpeg"}}' \
    --out "$OUT_DIR/hero-sunset.jpg"
fi

echo
echo "=== 3. 多人对话 TTS (gemini-3.8-flash-tts) ==="
run_cli tts "Alice: Google AI Pro 每月送 200 个 Colab 计算单元和 10 美元 GCP 额度。 Bob: 太实用了，跑实验和部署轻量服务正好够用！" \
  --multi-speaker "Alice=Kore,Bob=Puck" \
  --out "$OUT_DIR/dialogue.wav"

echo
echo "=== 4. 音乐生成 (lyria-3.5) ==="
run_cli music "Lo-fi chillhop beats for late-night coding, warm Rhodes electric piano, soft vinyl crackle, 85 BPM, instrumental" \
  --out "$OUT_DIR/coding-lofi.wav"

echo
echo "=== 5. 视频生成 (gemini-omni-1.2-flash, 异步提交示例) ==="
if [[ "$DRY_RUN" -eq 1 ]]; then
  run_cli video "Aerial drone shot over dramatic coastal cliffs at golden sunrise, calm ocean waves, cinematic 24fps" \
    -m gemini-omni-1.2-flash \
    --aspect-ratio 16:9 \
    --resolution 1080p \
    --async
  echo "[DRY-RUN PREVIEW] gemini-api video --resume <VID_ID> --out '$OUT_DIR/cliffs.mp4'"
else
  VID_ID=$(gemini-api video "Aerial drone shot over dramatic coastal cliffs at golden sunrise, calm ocean waves, cinematic 24fps" \
    -m gemini-omni-1.2-flash \
    --aspect-ratio 16:9 \
    --resolution 1080p \
    --async)
  echo "Video Job ID: $VID_ID"
  gemini-api video --resume "$VID_ID" --out "$OUT_DIR/cliffs.mp4"
fi
