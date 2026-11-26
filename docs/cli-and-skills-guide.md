# `gemini-api-cli` 与 `gemini-skills` 实战指南

参考仓库：
- [`google-gemini/gemini-api-cli`](https://github.com/google-gemini/gemini-api-cli) — 无状态、零依赖的 Gemini API 命令行工具，专为终端、脚本、CI 与 Coding Agent 设计。
- [`google-gemini/gemini-skills`](https://github.com/google-gemini/gemini-skills) — 官方 Agent Skills 集合，为 Coding Agent 提供最新模型名、SDK 规范和辅助脚本，防止生成过时代码。

---

## 一、`gemini-api` CLI 安装与鉴权

> **注意区分**：`gemini-api` 是无状态 API 调用 CLI（类似加强版 `curl`），区别于交互式编程代理 `@google/gemini-cli`。

### 1. 安装（macOS / Linux）

```bash
curl -fsSL https://raw.githubusercontent.com/google-gemini/gemini-api-cli/main/scripts/install.sh | bash
```

### 2. 配置密钥与排错

凭证解析优先级（命中即止）：
`--api-key` / `--access-token` 参数 → `GEMINI_API_KEY` / `GEMINI_ACCESS_TOKEN` 环境变量 → OS Keychain → `~/.config/gemini-api/config.yaml`。

```bash
# 本机推荐：存入 macOS Keychain
gemini-api configure --api-key "AIza..."

# 查看当前生效的密钥来源（脱敏显示）
gemini-api whoami
gemini-api whoami -o json

# 如果环境变量里的 GEMINI_API_KEY 意外覆盖了 Keychain：
env -u GEMINI_API_KEY gemini-api whoami
```

### 3. 高频命令速查

| 命令 | 用途 | 默认模型 | 关键参数 |
|---|---|---|---|
| `gemini-api generate "prompt"` | 文本生成/多轮对话 | `gemini-4-hydrogen` | `-m`、`-i`、`--stdin`、`--previous-interaction-id`、`--body`、`--stream=false` |
| `gemini-api image "prompt"` | 文生图 / 对话式修图 | `gemini-nano-banana-2.1` | `-i`、`--aspect-ratio`、`--image-size` (512..4K)、`--out` |
| `gemini-api tts "text"` | 文本转语音 / 多人对话 | `gemini-3.8-flash-tts` | `-v`/`--voice`、`--multi-speaker`、`--out` |
| `gemini-api music "prompt"` | 音乐生成（纯音乐/人声） | `lyria-3.5` | `-f`、`--stdin`、`--out` |
| `gemini-api video "prompt"` | 视频生成与编辑 | 推荐 `-m gemini-omni-1.2-flash` | `-i`、`--aspect-ratio`、`--resolution` (360p..4k)、`--async`、`--resume`、`--out` |
| `gemini-api analyze "question"` | 文档/音视频/YouTube 分析 | `gemini-4-hydrogen` | `-i`（必填，可重复）、`--system` |
| `gemini-api transcribe` | 音视频转文字/字幕 | `gemini-3.5-transcribe` | `-i`、`--format` (md/text/json/srt)、`--out` |
| `gemini-api files upload <path> --wait` | 上传大文件（最大 2GB，48h TTL） | — | 返回 `files/<id>`，供 `-i` 复用 |
| `gemini-api agent run` / `status` | Deep Research & Antigravity 沙盒 | `deep-research-preview-04-2026` / `antigravity-preview-09-2026` | `--agent`、`--background`、`--body '{"environment":"remote"}'` |
| `gemini-api environments files` | 查看/下载沙盒产出文件 | — | `list -e <env_id> -r`、`download <env_id> <path> --out ...` |

### 4. 实用全局标志

- `--dry-run`：离线校验参数并打印脱敏 HTTP 请求，**不消耗额度、不发网络请求**。
- `-q` / `--jq`：内置 jq 过滤器（无需安装外部 `jq`，默认 raw output）。
- `-o json`：媒体命令在写盘的同时输出 `{kind, path, size_bytes, mime_type, response_id, status}` JSON 元数据。
- `--agent-mode`：输出紧凑的 TOON 格式，并在 stderr 输出结构化 JSON 错误，适合被 Agent 脚本调用。

---

## 二、`google-gemini/gemini-skills` 全家桶

`google-gemini/gemini-skills` GitHub 仓库当前包含 4 个公开技能（`gemini-api-dev`、`gemini-api-cli`、`gemini-live-api-dev`、`gemini-omni-flash-api`）；Antigravity 本机的 Gemini API 插件额外内置了第 5 个技能 `genie-4-live-world`：

| Skill 名称 | 适用场景 | 覆盖的核心模型/接口 |
|---|---|---|
| `gemini-api-cli` | 终端/脚本/CI 用 `gemini-api` 命令行调用 | 全部 CLI 子命令、jq 过滤、沙盒文件拉取 |
| `gemini-api-dev` | Python (`google-genai >= 3.5.0`) / TS (`@google/genai >= 3.5.0`) 应用开发 | Interactions API、Gemini 4 系列、Nano Banana 2.1、TTS、Lyria 3.5、Decisions API、Deep Research、Managed Agents |
| `gemini-live-api-dev` | 实时双向音视频流式应用 | `gemini-3.8-live`、WebSocket、VAD、后台思考、实时翻译 |
| `gemini-omni-flash-api` | 生成式视频创作与编辑 | `gemini-omni-1.2-flash`、ffmpeg 预处理、首尾帧过渡、视频续写 |
| `genie-4-live-world`（Antigravity 插件内置） | 实时交互式 3D 世界生成与模拟 | `models/genie-4`、16:9 24fps + 48kHz 立体声、WASD 控制、WebRTC/WebSocket |

### SDK `v1` vs `v1beta` 实测边界（`google-genai >= 3.5.0`）

`google-genai >= 3.0.0` 默认使用稳定版 `v1`。2026-11-25 实测确认：

- **默认 `v1` 可用**：`gemini-4-neon`、`gemini-4-hydrogen`、`gemini-nano-banana-2.1`
- **需显式 `api_version="v1beta"`**：`gemini-3.8-flash-tts`、`lyria-3.5`、`gemini-omni-1.2-flash`、`gemini-decision-1`、`deep-research-preview-04-2026`、`antigravity-preview-09-2026`

```python
from google import genai
client_beta = genai.Client(http_options={"api_version": "v1beta"})
```

### 如何安装到其他 Coding Agent（Claude Code / Codex / Cursor）

```bash
# 查看仓库中所有可用 skill
npx skills add google-gemini/gemini-skills --list

# 全局安装单个 skill（以 gemini-api-dev 为例）
npx skills add google-gemini/gemini-skills --skill gemini-api-dev --global

# 或使用 Context7 CLI
npx ctx7 skills install /google-gemini/gemini-skills gemini-api-dev
```

### 配套连接 Gemini Docs MCP Server

官方提供公开 MCP 服务 `https://gemini-api-docs-mcp.dev`，提供 `gemini_search_docs` 与 `gemini_get_doc` 两个实时查文档工具：

```bash
# 自动探测并配置本机 Coding Agent
npx add-mcp "https://gemini-api-docs-mcp.dev"

# 或分别配置：
claude mcp add --transport http geminiDocs https://gemini-api-docs-mcp.dev
codex mcp add geminiDocs --url https://gemini-api-docs-mcp.dev
```

### 在远程 Managed Agent 中直接挂载 `gemini-skills`

当用 Antigravity 远程沙盒 Agent 写代码时，可以直接把 `google-gemini/gemini-skills` 挂载进沙盒的 `.agents` 目录，让远程 Agent 也遵守最新 SDK 规范（完整可运行代码见 [`demos/07_managed_agent_sandbox.py`](../demos/07_managed_agent_sandbox.py)）。
