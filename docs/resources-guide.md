# Google AI Pro 完整资源与激活使用指南

本手册逐项拆解 Google AI Pro 的 5 大类权益，给出**激活入口、适用场景、使用技巧**，并厘清最容易踩坑的 **订阅额度 vs API 计费边界**。

---

## 0. 关键避坑：Pro 订阅权益 vs Gemini API 计费

很多开发者开通 Google AI Pro 后，会误以为在 AI Studio 生成的 `GEMINI_API_KEY` 直接无限白嫖 Pro 额度。两者的边界如下：

| 维度 | Google AI Pro 消费者/平台权益 | Gemini Developer API (`GEMINI_API_KEY`) |
|---|---|---|
| **涵盖产品** | Gemini App、Workspace、Notebook、Flow / Flow Music、Antigravity IDE/CLI、Colab 200 CU、Google Developer Program $10/月 GCP 抵用金 | 你自己写的 Python/TS 程序、`gemini-api` CLI 调用 |
| **计费方式** | 包含在月费内；超额可按需购买 **AI Credits** | Free Tier（有速率/模型限制）或 Paid Tier（按 Token / 次计费，绑定 GCP Billing） |
| **如何省钱联动** | 直接在 Antigravity / AI Studio Web / Colab 中享受高额度 | **Pro 不额外自带无限 API 额度**，但主订阅者可在 AI Studio 左侧栏认领每月 **$10 GCP 抵用金**直接抵扣 Gemini API 调用费（可累积、每笔有效期 12 个月；需预存 $5 激活结算层，扣费时优先扣赠金，详见 `docs/colab-gcp-guide.md`） |

---

## 1. 日常办公与 AI 助手

### 1.1 Gemini 4 Neon & 百万级上下文
- **入口**：[gemini.google.com](https://gemini.google.com) 或手机端 Gemini App
- **怎么用最值**：
  - 在模型选择器中切换到 **Gemini 4 Neon**，处理复杂架构设计、长篇代码重构、数学/逻辑推理。
  - 直接上传整本 PDF、几十个代码文件或长音视频，利用百万级上下文做跨文档对比与抽取。

### 1.2 Deep Research & Gemini Tasks
- **Deep Research**：在 Gemini 界面开启 Deep Research，输入调研主题（如“对比 2026 年主流 WebRTC SFU 架构与成本”），它会先生成研究计划，确认后自动全网检索几十个来源并输出带引用的多页报告，可一键导出到 Google Docs。
- **Gemini Tasks**：设置定时/周期性自动化任务（如每周汇总某技术领域新发布、每日定时提醒与简报）。

### 1.3 Google Workspace 全家桶 & Chrome 自动浏览
- **Gmail**：撰写、润色、总结长邮件线程。
- **Docs / Sheets / Vids**：在 Docs 内直接生成初稿与改写；在 Sheets 用自然语言生成复杂公式、透视表与数据清洗；在 Vids 中一键把文档变成演示视频草稿。
- **Chrome 自动浏览**：在 Chrome 侧边栏唤醒 Gemini，让它自动执行多步骤网页操作（填表、比价、跨标签页整理资料）。

### 1.4 Gemini Notebook（NotebookLM）
- **入口**：[notebooklm.google.com](https://notebooklm.google.com)
- **Pro 专属优势**：
  - 单个笔记本最多支持 **300 个资料来源**（PDF、网页、YouTube、Google Docs、音频）。
  - 更高额度生成 **Audio Overview（双人播客式音频概览）**、**Video Overview**、**闪卡（Flashcards）**、**测验（Quizzes）** 和 **幻灯片（Slides）**。
- **推荐工作流**：把某个新领域的论文/文档/官方文档 URL 全部塞进一个 Notebook，先听 10 分钟音频概览建立全局直觉，再针对细节追问并带原文溯源。

---

## 2. 开发者与算力资源（高实用度）

> 详细命令行操作与避坑指南见 [docs/colab-gcp-guide.md](colab-gcp-guide.md)。

### 2.1 Google Cloud 每月 $10 抵用金
- **激活方式**：
  1. 用开通 Google AI Pro 的同一个 Google 账号登录 [Google Developer Program](https://developers.google.com/program)。
  2. 在 Benefits 页面认领每月的 **$10 Google Cloud Credits**，绑定到你的 GCP Billing Account。
- **推荐用途**：Cloud Run 个人轻量服务、Cloud Storage 备份、Artifact Registry、轻量 GCE 实例或实验性 Vertex AI / API 调用。

### 2.2 Google Colab 每月 200 Compute Units
- **入口**：[colab.research.google.com](https://colab.research.google.com)
- **激活方式**：用同一账号登录即自动到账，点击右上角 **View resources** 查看剩余 Compute Units。
- **推荐用途**：跑 PyTorch / LoRA 微调实验、本地无法塞进显存的大模型推理验证、批量音视频处理。详见 [`demos/08_colab_gpu_starter.ipynb`](../demos/08_colab_gpu_starter.ipynb)。

### 2.3 AI 编程与代理平台
- **Google Antigravity**：使用当前登录账号即可享受更高的 Gemini 4 Neon 及 Agent 调用额度，优先体验实验模型。
- **Google AI Studio**（[aistudio.google.com](https://aistudio.google.com)）：可视化调试 Prompt、测试多模态输入、生成 `GEMINI_API_KEY`，且 AI Studio Build 内置 `gemini-skills`。
- **Android Studio**：内置 Gemini 编程助手更高额度。

---

## 3. 图像、视频与音乐创作

### 3.1 Google Flow（图像与视频创作工作台）
- **入口**：[labs.google/flow](https://labs.google/flow)
- **能力**：文生图、文生视频、图生视频、镜头控制、以及 **4K 画质增强**。
- **开发者等价接口**：在脚本/程序中可通过 `gemini-nano-banana-2.1`（生图/修图）和 `gemini-omni-1.2-flash`（3s–15s 视频生成与首尾帧过渡）实现自动化，见 `demos/03_image_generation.py` 与 `demos/05_video_omni_flash.py`。

### 3.2 Google Flow Music（10,000 点/月）
- **能力**：每月 10,000 点音乐生成点数，支持人声歌曲与纯音乐创作。
- **开发者等价接口**：API 侧对应 `lyria-3.5`，见 `demos/04_tts_and_music.py` 和 `scripts/cli_demos/02_media_generation.sh`。

### 3.3 Google Photos AI
- **能力**：更高的每日照片转视频、风格重绘（Remix）额度。
- **注意**：部分功能受账号地区/设备语言限制。

---

## 4. 云存储与家庭共享（5 TB / 最多 6 人）

- **管理入口**：[one.google.com/settings](https://one.google.com/settings)
- **配置步骤**：
  1. 在 Google One 设置中开启 **与家人共享 Google One（Share Google One with family）**。
  2. 前往 [families.google.com](https://families.google.com) 邀请最多 **5 位**家庭成员（含本人共 6 人）。
  3. 家庭成员将共享 5 TB（或 10 TB）存储池（各人文件彼此私密隔离，仅统计总容量），且**各自独立享受其中的 AI 功能权益**。

---

## 5. 附赠生态会员（白嫖福利清单）

| 会员 | 激活/确认方式 | 注意事项 |
|---|---|---|
| **YouTube Premium Lite** | 在 Google One 权益页激活或直接用同账号登录 YouTube 确认徽章 | 仅限**订阅者本人**使用，**不可家庭共享**；不含 YouTube Music 与 Shorts 免广告 |
| **Google Home Premium 标准版** | 打开 Google Home App → 设置 → 订阅，确认自动关联 | 价值 $10/月；含 30 天事件历史记录 + 用 Gemini 语音/文字自动创建家居自动化规则 |
| **Google Health Premium** | 打开 Google Health / Fitbit App 用同账号登录激活 | 需配合支持的穿戴设备采集睡眠/心率/运动数据，才能发挥 AI 健康教练分析价值 |

---

## 6. 如何让本地 AI Agent 帮你整理 Gmail / Google Drive / Colab / Photos

> 完整调研、官方 MCP 端点列表与 6 工具选型矩阵详见专题文档：[**Google Workspace MCP & CLI 调研与选型指南 (`docs/workspace-mcp-cli-guide.md`)**](workspace-mcp-cli-guide.md)。

**重要前提**：`GEMINI_API_KEY` 仅用于调用 Gemini 模型推理，**不包含**任何读取你个人 Google 账号数据的权限。若想让本地 AI Agent 帮你整理邮箱、云盘或 Colab 脚本，需要通过 **OAuth 授权**或**本地同步盘**开放对应范围：

| 目标资源 | 能否接入本地 Agent | 推荐方案（2026-11-26 更新） | 适用整理任务 |
|---|---|---|---|
| **Google Drive & Colab 脚本** (`Colab Notebooks/`) | **可以**（最推荐） | 1. **`rclone`**（批量整理首选）：`rclone config` 授权后支持只读扫描、同步、移动、去重（`dedupe`）与空间分析（`ncdu`）<br>2. **官方 Workspace MCP / `gws` CLI**：适合轻量检索与对话式访问<br>3. **Google Drive 桌面版**：挂载到本地 `~/Library/CloudStorage/GoogleDrive-*` | 梳理 `Colab Notebooks/` 里的 `.ipynb`、按主题分目录、去重、清理大体积临时文件 |
| **Gmail / Docs / Sheets / Calendar** | **可以** | 1. **Google 官方 Workspace CLI (`gws`)**（`googleworkspace/cli`，单入口能力最全）<br>2. **Google 官方 Workspace MCP Servers**（`gmailmcp.googleapis.com/mcp/v1` 等，内置 HITL 人工确认） | 搜索账单/订阅邮件、按主题归类总结、读写 Docs/Sheets、查询日程与待办 |
| **Google Photos（云图片）** | **受限** | 官方 Workspace MCP/CLI **不含 Photos**，且 Library API 已收紧全库遍历权限；建议通过 **Google Takeout** 导出到本地后由 Agent 批量整理，或直接在 Photos 内使用 Pro 自带的 Gemini 搜索 | 本地批量去重、按时间/内容重命名、多模态打标 |

### 安全建议
- **先只读盘点，再批量移动**：整理 Drive / Colab 文件时，先让 Agent 输出整理清单（dry-run 方案），确认无误后再执行移动或归档，不要直接执行不可逆删除。
- **凭证隔离**：OAuth token 属于高敏感个人数据凭证，只保留在工具默认配置目录（如 `~/.config/rclone/`、`~/.config/gws/`），严禁复制到项目目录或提交进 git。
