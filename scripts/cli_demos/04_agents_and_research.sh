#!/usr/bin/env bash
set -euo pipefail

# Demo 04: 托管代理（Deep Research 后台调研 + Antigravity 远程 Linux 沙盒）
# 用法:
#   bash scripts/cli_demos/04_agents_and_research.sh --dry-run
#   bash scripts/cli_demos/04_agents_and_research.sh

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

echo "=== 1. Deep Research 后台深度调研 (deep-research-preview-04-2026) ==="
if [[ "$DRY_RUN" -eq 1 ]]; then
  run_cli agent run "对比 2026 年主流开源向量数据库在百万级向量的内存占用与查询延迟，附主要参考来源。" \
    --agent deep-research-preview-04-2026 \
    --background \
    --jq '.id'
  echo "[DRY-RUN PREVIEW] gemini-api agent status <RUN_ID> --jq '.status'"
else
  RUN_ID=$(gemini-api agent run "对比 2026 年主流开源向量数据库在百万级向量的内存占用与查询延迟，附主要参考来源。" \
    --agent deep-research-preview-04-2026 \
    --background \
    --jq '.id')
  echo "Deep Research Run ID: $RUN_ID"
  echo "查看状态: gemini-api agent status $RUN_ID --jq '.status'"
  echo "提取全文: gemini-api agent status $RUN_ID --jq '[.steps[]? | select(.type==\"model_output\") | .content[]? | select(.type==\"text\") | .text] | join(\"\")'"
fi

echo
echo "=== 2. Antigravity 远程 Linux 沙盒 Agent (antigravity-preview-09-2026) ==="
if [[ "$DRY_RUN" -eq 1 ]]; then
  run_cli agent run "用 Python 对比 timsort 与 heapq.nsmallest 在 100k 随机整数上的耗时，并把结果写入 benchmark.csv。" \
    --agent antigravity-preview-09-2026 \
    --body '{"environment": "remote"}' \
    --jq '.environment_id'
  echo "[DRY-RUN PREVIEW] gemini-api environments files list -e <ENV_ID> -r"
  echo "[DRY-RUN PREVIEW] gemini-api environments files download <ENV_ID> benchmark.csv --out '$OUT_DIR/benchmark.csv'"
else
  ENV_ID=$(gemini-api agent run "用 Python 对比 timsort 与 heapq.nsmallest 在 100k 随机整数上的耗时，并把结果写入 benchmark.csv。" \
    --agent antigravity-preview-09-2026 \
    --body '{"environment": "remote"}' \
    --jq '.environment_id')
  echo "Remote Sandbox Environment ID: $ENV_ID"
  gemini-api environments files list -e "$ENV_ID" -r
  gemini-api environments files download "$ENV_ID" benchmark.csv --out "$OUT_DIR/benchmark.csv"
  echo "已下载沙盒产物到: $OUT_DIR/benchmark.csv"
fi
