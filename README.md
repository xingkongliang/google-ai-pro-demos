# Google AI Pro 权益指南与开发者 Demo 集合

> **免责与时效声明**：本项目为个人整理的开源演示与使用手册，**非 Google 官方项目**。文中涉及的 Google AI Pro 权益内容、月度额度与模型列表截至 **2026-11-26**，最新政策请以 Google 官方页面为准。

本项目整理了 **Google AI Pro** 订阅包含的全部核心权益、开通与配置路径，并结合官方开源工具 [`google-gemini/gemini-api-cli`](https://github.com/google-gemini/gemini-api-cli) 与 [`google-gemini/gemini-skills`](https://github.com/google-gemini/gemini-skills)，提供开箱即用的 CLI 脚本、Python SDK（`google-genai` Interactions API）演示程序与 Google Colab GPU 入门 Notebook。

---

## 一、Google AI Pro 核心权益总览

| 类别 | 包含资源 | 核心能力 / 额度 | 推荐入口 / 工具 |
|---|---|---|---|
| **1. 日常办公与 AI 助手** | Gemini 4 Neon & 长上下文 | 百万级上下文窗口、深度分析、复杂编程与推理、更大文件上传 | [gemini.google.com](https://gemini.google.com) |
| | Deep Research & Tasks | 更高额度的全网深度研究报告与定时/自动化任务 | Gemini App / API `deep-research-preview-04-2026` |
| | Workspace & Chrome 集成 | Gmail、Docs、Sheets、Vids 及 Chrome 自动浏览多步骤网页任务 | Google Workspace / Chrome |
| | Gemini Notebook | 单笔记本最高 300 资料源；更高额度的音频/视频概览、闪卡、测验、幻灯片 | [notebooklm.google.com](https://notebooklm.google.com) |
| **2. 开发者与算力资源** | **Google Cloud 抵用金** | 通过 Google Developer Program **每月送 $10** GCP 额度 | [developers.google.com/program](https://developers.google.com/program) |
| | **Google Colab 算力** | **每月送 200 Compute Units**，可用更强 GPU 与更长运行时长 | [colab.research.google.com](https://colab.research.google.com) |
| | **AI 编程与代理平台** | Antigravity、AI Studio、Android Studio 更高 Gemini 4 Neon / Agent 额度与实验模型优先体验 | Antigravity / [aistudio.google.com](https://aistudio.google.com) |
| **3. 图像、视频与音乐创作** | Google Flow | 更高文生图、文生视频、图生视频及 4K 画质增强额度 | [labs.google/flow](https://labs.google/flow) |
| | Google Flow Music | 每月 **10,000 点** 音乐生成点数 | Google Flow Music |
| | Google Photos AI | 更高每日照片转视频、风格重绘（Remix）额度（部分地区受限） | Google Photos |
| **4. 云存储与家庭共享** | 5 TB（可选 10 TB）云盘 | Gmail / Drive / Photos 共享，最多 **6 人家庭共享**（成员各自享 AI 权益） | [one.google.com](https://one.google.com) |
| **5. 附赠生态会员** | YouTube Premium Lite | 减少广告、后台播放、离线下载（仅限本人，不含音乐/Shorts） | YouTube |
| | Google Home Premium 标准版 | 价值 $10/月；30 天智能家居事件记录 + Gemini 生成联动规则 | Google Home App |
| | Google Health Premium | Gemini 个性化 AI 健康教练（睡眠/运动/恢复分析，需兼容设备） | Google Health / Fitbit |

> **按需加量说明**：月度基础 AI 额度用完后，Pro 会员可按需单独购买 **AI Credits** 用于 Gemini、Google Flow 和 Google Antigravity，无需升级到更贵的 Ultra 档位。

---

## 二、文档导航

- [**完整资源与激活指南 (`docs/resources-guide.md`)**](docs/resources-guide.md) — 5 大类权益逐项使用方法、激活步骤、以及 **Pro 订阅额度 vs AI Studio API 计费边界** 的重要避坑说明。
- [**CLI 与 Agent Skills 实战手册 (`docs/cli-and-skills-guide.md`)**](docs/cli-and-skills-guide.md) — `google-gemini/gemini-api-cli` 安装/鉴权/高频命令，以及 `google-gemini/gemini-skills`（官方技能 + Gemini Docs MCP）配置方法。
- [**开发者算力指南：GCP $10 抵用金 + Colab 200 CU (`docs/colab-gcp-guide.md`)**](docs/colab-gcp-guide.md) — 如何领取每月 $10 GCP 抵用金、设置预算告警防超支、以及 200 个 Colab 计算单元的最佳利用策略。
- [**Workspace MCP & CLI 选型与配置指南 (`docs/workspace-mcp-cli-guide.md`)**](docs/workspace-mcp-cli-guide.md) — Google 官方 Workspace MCP Servers & `gws` CLI 接入说明，以及与 `rclone` / `gemini-api` / `gcloud` 的工具分工推荐。
- [**端到端实测报告 (`docs/test-report.md`)**](docs/test-report.md) — 全部 8 个 Demo（7 个 Python SDK + Colab Pro GPU）的实测结果、截图与 `v1` / `v1beta` 边界记录。

---

## 三、项目结构与 Demo 清单

```text
google-ai-pro-demos/
├── LICENSE                                # MIT 协议
├── README.md                              # 本说明文档
├── .env.example                           # 环境变量模板（GEMINI_API_KEY）
├── pyproject.toml                         # uv / Python 3.11+ 依赖配置
├── docs/
│   ├── resources-guide.md                 # 5 大类权益详解与激活路径
│   ├── cli-and-skills-guide.md            # gemini-api-cli & gemini-skills 指南
│   ├── colab-gcp-guide.md                 # GCP $10 抵用金 + Colab 200 CU + 私人 OAuth 指南
│   ├── workspace-mcp-cli-guide.md         # 官方 Workspace MCP & gws CLI 选型与配置
│   ├── test-report.md                     # 8 个 Demo 端到端实测报告
│   └── images/                            # Colab GPU 与 Nano Banana 实测结果图
├── scripts/
│   ├── check_env.sh                       # 一键环境与凭证来源体检
│   ├── setup_rclone_client.sh             # 一键为 rclone 写入 GCP 私人 OAuth 凭据
│   └── cli_demos/                         # gemini-api CLI 演示（均支持 --dry-run）
│       ├── 01_text_and_structured.sh      # 文本、多轮对话、JSON Schema 结构化输出
│       ├── 02_media_generation.sh         # Nano Banana 2.1 生图/修图、TTS、Lyria 3.5、Omni 1.2 视频
│       ├── 03_analyze_and_transcribe.sh   # 文档/YouTube 分析 + 音视频转写 (SRT/MD)
│       └── 04_agents_and_research.sh      # Deep Research + Antigravity 远程 Linux 沙盒
├── demos/                                 # Python SDK (google-genai >= 3.5.0) 演示
│   ├── common.py                          # 环境加载、输出目录与 --dry-run 辅助
│   ├── 01_text_chat_streaming.py          # Gemini 4 流式输出 & 服务端多轮状态
│   ├── 02_structured_and_decisions.py     # Pydantic 结构化输出 & Decisions API 校准决策
│   ├── 03_image_generation.py             # Nano Banana 2.1 文生图 + 对话式编辑
│   ├── 04_tts_and_music.py                # Gemini 3.8 多人对话 TTS + Lyria 3.5 音乐
│   ├── 05_video_omni_flash.py             # Gemini Omni 1.2 Flash 视频生成
│   ├── 06_deep_research_agent.py          # Deep Research 后台深度研究
│   ├── 07_managed_agent_sandbox.py        # Antigravity 沙盒 Agent + 挂载 gemini-skills
│   └── 08_colab_gpu_starter.ipynb         # Colab 200 CU GPU 检测与 Gemini API 起手式
└── outputs/                               # 生成的图片、音频、视频、报告（git 忽略）
```

---

## 四、快速开始

### 1. 检查本机环境

```bash
bash scripts/check_env.sh
```

### 2. 安装 `gemini-api` CLI（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/google-gemini/gemini-api-cli/main/scripts/install.sh | bash
gemini-api configure --api-key "<你的 AI Studio API Key>"
gemini-api whoami
```

> **鉴权优先级提示**：如果环境变量里设置了 `GEMINI_API_KEY`，它会覆盖 OS Keychain 中的配置。随时可用 `gemini-api whoami` 确认当前生效的密钥来源。

### 3. 安装 Python 依赖并配置 Key

```bash
# 安装依赖 (google-genai >= 3.5.0)
uv sync

# 将 GEMINI_API_KEY 写入本项目 .env 或 ~/.env（demos/common.py 会按 env > 项目 .env > ~/.env 顺序自动加载）
cp .env.example .env
# 编辑 .env 填入 GEMINI_API_KEY
```

### 4. 先免 Key 预览（`--dry-run`），再实际运行

所有 CLI 脚本与 Python Demo 均支持 `--dry-run`，可在未配置 Key 或不消耗额度的情况下校验参数并预览请求结构：

```bash
# CLI Demo 预览
bash scripts/cli_demos/01_text_and_structured.sh --dry-run
bash scripts/cli_demos/02_media_generation.sh --dry-run

# Python Demo 预览
uv run python demos/01_text_chat_streaming.py --dry-run
uv run python demos/02_structured_and_decisions.py --dry-run

# 实际运行（生成结果保存在 outputs/）
uv run python demos/01_text_chat_streaming.py
uv run python demos/03_image_generation.py
```

### 5. 体验 Colab 200 Compute Units

将 [`demos/08_colab_gpu_starter.ipynb`](demos/08_colab_gpu_starter.ipynb) 上传到 [Google Colab](https://colab.research.google.com)，在右上角选择高配 GPU 运行时（如 L4 / A100），即可验证 Pro 算力并调用 Gemini API。
