#!/usr/bin/env bash
set -euo pipefail

# 用 GCP 下载的桌面端 OAuth JSON 一键更新 rclone gdrive 的私人 client_id / client_secret
# 用法:
#   bash scripts/setup_rclone_client.sh ~/Downloads/client_secret_xxxx.json [remote名称，默认 gdrive]

if [[ $# -lt 1 ]]; then
  echo "用法: bash $0 <GCP下载的client_secret.json路径> [remote名称，默认 gdrive]" >&2
  exit 2
fi

JSON_PATH="$1"
REMOTE_NAME="${2:-gdrive}"

if [[ ! -f "$JSON_PATH" ]]; then
  echo "错误：找不到文件 $JSON_PATH" >&2
  exit 1
fi

if ! command -v rclone >/dev/null 2>&1; then
  echo "错误：未安装 rclone" >&2
  exit 1
fi

# 从 Google OAuth JSON（支持 installed 或 web 节点）安全提取 client_id / client_secret
read -r CLIENT_ID CLIENT_SECRET < <(
  python3 - "$JSON_PATH" <<'PY'
import json, sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)

node = data.get("installed") or data.get("web") or data
cid = node.get("client_id", "").strip()
csec = node.get("client_secret", "").strip()
if not cid or not csec:
    print("ERROR: JSON 中缺少 client_id 或 client_secret", file=sys.stderr)
    sys.exit(1)
print(f"{cid}\t{csec}")
PY
)

echo "=== 正在为 rclone remote '${REMOTE_NAME}' 写入私人 OAuth 凭据（不打印密钥）==="
echo "接下来会自动打开浏览器，请用你的 Google 账号重新点击同意授权..."
rclone config update "$REMOTE_NAME" \
  client_id "$CLIENT_ID" \
  client_secret "$CLIENT_SECRET" \
  scope drive

echo
echo "=== 验证连接（确认不再出现 shared client_id 警告）==="
rclone about "${REMOTE_NAME}:"

echo
echo "完成！建议妥善保管或删除下载目录中的 ${JSON_PATH}（rclone 已将凭据保存到 ~/.config/rclone/rclone.conf）。"
