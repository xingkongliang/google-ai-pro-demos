#!/usr/bin/env bash
set -euo pipefail

# Demo 03: 文件上传复用、PDF/YouTube 分析与音视频转写
# 用法:
#   bash scripts/cli_demos/03_analyze_and_transcribe.sh --dry-run
#   bash scripts/cli_demos/03_analyze_and_transcribe.sh [本地音视频或PDF路径]

DRY_RUN=0
TARGET_FILE=""
for arg in "$@"; do
  if [[ "$arg" == "--dry-run" ]]; then
    DRY_RUN=1
  else
    TARGET_FILE="$arg"
  fi
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUT_DIR="$PROJECT_DIR/outputs/cli"
mkdir -p "$OUT_DIR"

# 默认用本项目的 README.md 作为演示文档
SAMPLE_DOC="${TARGET_FILE:-$PROJECT_DIR/README.md}"

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

echo "=== 1. 直接分析本地文档 ($SAMPLE_DOC) ==="
run_cli analyze "总结这份文档的核心内容，并列出对开发者最实用的 3 个起步动作。" \
  -i "$SAMPLE_DOC" \
  -m gemini-4-hydrogen

echo
echo "=== 2. 大文件上传复用 + 音视频转写命令模板（最多支持 2GB，48h TTL）==="
cat <<'EOF'
# 上传大文件一次，拿到 files/<id> 后重复用于分析与转写：
FILE_URI=$(gemini-api files upload ./meeting.mp4 --wait)

# 提取会议行动项（带时间戳与负责人）：
gemini-api analyze -i "$FILE_URI" "列出所有行动项、负责人和对应时间戳。"

# 生成 SRT 字幕（audio 默认用 gemini-3.5-transcribe，video 默认用 gemini-4-hydrogen）：
gemini-api transcribe -i "$FILE_URI" --format srt --out ./outputs/cli/meeting.srt

# 直接分析公开 YouTube 视频（无需下载）：
gemini-api analyze -i "https://www.youtube.com/watch?v=<VIDEO_ID>" "按章节总结视频要点。"
EOF
