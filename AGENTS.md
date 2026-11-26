# google-ai-pro-demos

## Overview

Google AI Pro 订阅权益说明手册、开发者资源实战指南，以及基于 `google-gemini/gemini-api-cli`、`google-gemini/gemini-skills` 与最新 `google-genai`（Interactions API）的可运行演示集合。

## Stack

- **Shell CLI**: `gemini-api` (`google-gemini/gemini-api-cli`)、`gcloud`（可选，用于管理 GCP $10/月开发者抵用金）
- **Python**: Python 3.11+、`uv`、`google-genai >= 3.5.0`、`pydantic`、`python-dotenv`
- **Colab**: Jupyter Notebook (`demos/08_colab_gpu_starter.ipynb`)

## Commands

```bash
# 1. 环境体检（检查 gemini-api CLI、uv、API Key 来源）
bash scripts/check_env.sh

# 2. 安装 Python 依赖
uv sync

# 3. 无 API Key 预览（所有 CLI 与 Python Demo 均支持 --dry-run）
bash scripts/cli_demos/01_text_and_structured.sh --dry-run
uv run python demos/01_text_chat_streaming.py --dry-run

# 4. 运行实际 Demo（需配置 GEMINI_API_KEY）
uv run python demos/01_text_chat_streaming.py
```

## Conventions

- **只使用现代模型与 Interactions API**：使用 `gemini-4-hydrogen` / `gemini-4-neon` / `gemini-nano-banana-2.1` / `gemini-3.8-flash-tts` / `lyria-3.5` / `gemini-omni-1.2-flash` / `gemini-decision-1`；禁止使用已弃用的 `gemini-2.5-*`、`gemini-2.0-*`、`gemini-1.5-*` 与旧版 `google-generativeai` SDK。
- **密钥存放**：`GEMINI_API_KEY` 优先存放在项目 `.env`、`~/.env` 或本机 OS Keychain（`gemini-api configure --api-key ...`），禁止提交任何 `.env` 到 git。
- **产物输出**：所有 Demo 生成的媒体/文本默认输出到 `outputs/`（已被 `.gitignore` 忽略）。
