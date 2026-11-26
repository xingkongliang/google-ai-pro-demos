#!/usr/bin/env bash
set -euo pipefail

echo "=== Google AI Pro Demos 环境体检 ==="
echo

check_cmd() {
  local cmd="$1"
  local hint="$2"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf "[OK]   %-12s -> %s\n" "$cmd" "$(command -v "$cmd")"
  else
    printf "[MISS] %-12s -> %s\n" "$cmd" "$hint"
  fi
}

check_cmd "gemini-api" "安装: curl -fsSL https://raw.githubusercontent.com/google-gemini/gemini-api-cli/main/scripts/install.sh | bash"
check_cmd "uv"         "安装: curl -LsSf https://astral.sh/uv/install.sh | sh"
check_cmd "python3"    "需要 Python 3.11+"
check_cmd "gcloud"     "可选（管理 GCP \$10/月抵用金）: brew install --cask google-cloud-sdk"
check_cmd "ffmpeg"     "可选（视频预处理）: brew install ffmpeg"

echo
echo "--- 凭证来源检查（不打印真实密钥）---"
if [[ -n "${GEMINI_API_KEY:-}" ]]; then
  echo "[ENV]  当前 Shell 已导出 GEMINI_API_KEY（注意：会覆盖 gemini-api keychain 配置）"
else
  echo "[ENV]  当前 Shell 未设置 GEMINI_API_KEY"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ -f "$PROJECT_DIR/.env" ]] && grep -q '^GEMINI_API_KEY=' "$PROJECT_DIR/.env"; then
  echo "[FILE] 项目 .env 中存在 GEMINI_API_KEY"
else
  echo "[FILE] 项目 .env 未配置 GEMINI_API_KEY"
fi

if [[ -f "$HOME/.env" ]] && grep -q '^GEMINI_API_KEY=' "$HOME/.env"; then
  echo "[FILE] ~/.env 中存在 GEMINI_API_KEY"
else
  echo "[FILE] ~/.env 未配置 GEMINI_API_KEY"
fi

if command -v gemini-api >/dev/null 2>&1; then
  echo
  echo "--- gemini-api whoami ---"
  gemini-api whoami || true
fi

echo
echo "--- 本地官方 gemini-skills 检查 ---"
SKILLS_DIR="$HOME/.gemini/config/plugins/gemini-api/skills"
if [[ -d "$SKILLS_DIR" ]]; then
  echo "[OK]   已安装 Antigravity Gemini API Plugin Skills:"
  ls -1 "$SKILLS_DIR" | sed 's/^/       - /'
else
  echo "[INFO] 未在 $SKILLS_DIR 检测到插件；可用 npx skills add google-gemini/gemini-skills --list 安装"
fi
