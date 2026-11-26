#!/usr/bin/env bash
set -euo pipefail

# Demo 01: gemini-api CLI 文本生成、服务端多轮对话、JSON Schema 结构化输出
# 用法:
#   bash scripts/cli_demos/01_text_and_structured.sh --dry-run   # 离线预览，不消耗额度
#   bash scripts/cli_demos/01_text_and_structured.sh             # 实际调用

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

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
      echo "错误：未安装 gemini-api CLI。请先运行：" >&2
      echo "  curl -fsSL https://raw.githubusercontent.com/google-gemini/gemini-api-cli/main/scripts/install.sh | bash" >&2
      exit 1
    fi
    echo "+ gemini-api $*"
    gemini-api "$@"
  fi
}

echo "=== 1. 使用 Gemini 4 Neon 进行深度分析 ==="
run_cli generate "用 3 个要点对比 Google Cloud Run 与 GCE 在每月 10 美元预算下的适用场景。" \
  -m gemini-4-neon

echo
echo "=== 2. 服务端多轮对话 (previous-interaction-id) ==="
if [[ "$DRY_RUN" -eq 1 ]]; then
  run_cli generate "请为时序日志设计两种索引策略。" -m gemini-4-hydrogen --jq '.id'
  run_cli generate "针对写多读少场景对比这两种策略。" -m gemini-4-hydrogen --previous-interaction-id "<TURN1_ID>"
else
  TURN1_ID=$(gemini-api generate "请为时序日志设计两种索引策略。" -m gemini-4-hydrogen --jq '.id')
  echo "Turn 1 Interaction ID: $TURN1_ID"
  gemini-api generate "针对写多读少场景对比这两种策略。" \
    -m gemini-4-hydrogen \
    --previous-interaction-id "$TURN1_ID"
fi

echo
echo "=== 3. 管道输入 (--stdin) + JSON Schema 结构化输出 ==="
SAMPLE_LOG=$'ERROR 2026-11-25 auth.py:42 InvalidTokenError: signature expired\nWARN 2026-11-25 cache.py:18 miss key=user:9\nERROR 2026-11-25 db.py:91 ConnectionTimeoutError: pool exhausted'
SCHEMA_BODY='{
  "response_format": {
    "type": "text",
    "mime_type": "application/json",
    "schema": {
      "type": "object",
      "properties": {
        "errors": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "file": {"type": "string"},
              "error_type": {"type": "string"},
              "summary": {"type": "string"}
            },
            "required": ["file", "error_type", "summary"]
          }
        }
      },
      "required": ["errors"]
    }
  },
  "store": false
}'

if [[ "$DRY_RUN" -eq 1 ]]; then
  if command -v gemini-api >/dev/null 2>&1; then
    printf '%s\n' "$SAMPLE_LOG" | gemini-api generate "提取所有 ERROR 级别日志并结构化输出。" --stdin --body "$SCHEMA_BODY" --dry-run
  else
    echo "[DRY-RUN PREVIEW] printf '<log>' | gemini-api generate '提取所有 ERROR 级别日志并结构化输出。' --stdin --body '<json-schema>'"
  fi
else
  printf '%s\n' "$SAMPLE_LOG" | gemini-api generate "提取所有 ERROR 级别日志并结构化输出。" \
    -m gemini-4-hydrogen \
    --stdin \
    --stream=false \
    --body "$SCHEMA_BODY"
fi
