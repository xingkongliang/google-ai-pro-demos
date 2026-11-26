# Google Workspace MCP Servers & Workspace CLI (`gws`) 选型与配置指南

> 适用场景：让本地 AI Agent（Claude Code / Antigravity / Cursor / Codex 等）安全访问并整理个人 Gmail、Google Drive（含 `Colab Notebooks/`）、Docs、Sheets、Slides、Calendar、Tasks 等 Google Workspace 资源。

---

## 一、官方资源入口

Google 已将 **Google Workspace MCP Servers**、**Google Workspace CLI (`gws`)** 与 **Google Cloud Agent Gateway** 推向正式可用（GA），为 AI Agent 提供替代传统 REST 集成的标准通道：

- **Workspace MCP 配置指南**：[developers.google.com/workspace/guides/configure-mcp-servers](https://developers.google.com/workspace/guides/configure-mcp-servers)
- **Workspace CLI 官方指南**：[developers.google.com/workspace/guides/workspace-cli](https://developers.google.com/workspace/guides/workspace-cli)（开源仓：[github.com/googleworkspace/cli](https://github.com/googleworkspace/cli)）
- **企业级 Agent 安全架构博客**：[cloud.google.com/blog/products/identity-security/deploying-agents-safely-in-your-enterprise](https://cloud.google.com/blog/products/identity-security/deploying-agents-safely-in-your-enterprise)

---

## 二、官方托管远程 Workspace MCP Servers

Google 按产品提供独立的 Streamable HTTP MCP 端点，配置到支持 MCP 的客户端后触发 OAuth 2.0 登录即可使用：

| 产品 | 官方远程 MCP 端点 |
|---|---|
| **Gmail** | `https://gmailmcp.googleapis.com/mcp/v1` |
| **Google Drive** | `https://drivemcp.googleapis.com/mcp/v1` |
| **Google Docs** | `https://docsmcp.googleapis.com/mcp/v1` |
| **Google Sheets** | `https://sheetsmcp.googleapis.com/mcp/v1` |
| **Google Slides** | `https://slidesmcp.googleapis.com/mcp/v1` |
| **Google Calendar** | `https://calendarmcp.googleapis.com/mcp/v1` |
| **Google Chat** | `https://chatmcp.googleapis.com/mcp/v1` |
| **Google Contacts (People)** | `https://people.googleapis.com/mcp/v1` |

客户端 `mcp.json` 配置示例：

```json
{
  "mcpServers": {
    "gmail": {
      "type": "http",
      "url": "https://gmailmcp.googleapis.com/mcp/v1"
    },
    "google-drive": {
      "type": "http",
      "url": "https://drivemcp.googleapis.com/mcp/v1"
    }
  }
}
```

前置条件：在 Google Cloud Console 创建/选择 GCP 项目 → 启用对应产品 API 与 MCP 服务 → 配置 OAuth 2.0 Client ID。

---

## 三、官方 Google Workspace CLI（`gws`）快速上手

`gws` 运行时动态加载 Google API Discovery 元数据，支持结构化 JSON 输出，不占用 MCP 上下文 Token，一套 CLI 即可被所有终端 Agent 和脚本复用。

```bash
# 1. 安装（Node.js 18+）
npm install -g @googleworkspace/cli
gws --version

# 2. 将 GCP 桌面端 OAuth JSON 放入 ~/.config/gws/client_secret.json（权限 600）
# 注意：其中 project_id 必须为真实 GCP Project ID 或数字项目编号（而非显示名），否则会报 403

# 3. 浏览器登录授权（建议先用 --readonly 测试，确认无误再按需开读写）
gws auth login --readonly -s gmail,drive,docs,sheets,slides,calendar,tasks
gws auth status

# 4. 常用查询示例
gws gmail users getProfile --params '{"userId":"me"}'
gws drive files list --params '{"q":"name contains '\''.ipynb'\'' and trashed = false","fields":"files(id,name,modifiedTime,webViewLink)","pageSize":20}' --format table
gws schema drive.files.list
```

**已知个人账号边界**：
- **Google Keep API**：仅限付费企业版 Workspace，个人 `@gmail.com` 账号不可用。
- **Google Photos / NotebookLM**：目前不包含在官方 Workspace MCP / CLI 中。

---

## 四、工具选型对比与推荐分工

| 工具 | 定位 | 适用场景 | 推荐分工 |
|---|---|---|---|
| **官方 Workspace CLI (`gws`)** | 官方本地终端 CLI（实测版本 `0.22.5`） | 全量 Workspace API 能力、本地脚本与多 Coding Agent 复用 | **首选**：Gmail、Docs、Sheets、Slides、Calendar、Tasks 及 Drive 条件检索 |
| **官方 Workspace MCP** | 官方远程 MCP 端点 | 不便执行终端命令的纯聊天客户端；协议层内置敏感动作人工确认（HITL） | **按需**：对话式轻办公 |
| **`rclone`** | 云盘同步与批量文件管理（实测版本 `1.75.2`） | 断点续传、批量同步、移动、去重（`dedupe`）、空间排查（`about` / `ncdu`） | **首选**：5 TB Google Drive 大文件与 `Colab Notebooks/` 整理 |
| **`gemini-api`** | 官方 Gemini 模型 API CLI | 终端一行命令调 Gemini 4、生图/TTS/音乐/视频、转写、Deep Research、沙盒 | **专用**：模型调用（不管个人网盘/邮箱） |
| **`gcloud`** | GCP 基础设施运维 CLI | 管理每月 **$10 GCP 抵用金**、部署 Cloud Run、管理 Cloud Storage | **按需**：上云部署时安装 |
