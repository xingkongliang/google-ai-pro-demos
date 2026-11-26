# 开发者算力实战指南：GCP $10/月抵用金 + Colab 200 Compute Units

Google AI Pro 对开发者最有性价比的两项硬算力权益是 **每月 $10 Google Cloud 抵用金** 与 **每月 200 个 Google Colab 计算单元（Compute Units）**。

---

## 一、Google Cloud 每月 $10 抵用金（Google Developer Program）

### 1. 领取与绑定步骤（直接用于 Gemini API & GCP）

1. 使用开通 Google AI Pro 的**主订阅者** Google 账号登录 [Google AI Studio](https://aistudio.google.com/)（也可通过 [Google Developer Program](https://developers.google.com/program) Benefits 页进入）。
2. 在 AI Studio 左侧边栏找到 **"Claim your free API credits"** 卡片，按引导关联你的 GCP Billing Account。
3. **预付激活门槛**：激活 Gemini API 付费层并解锁抵用金时，需要创建一个预付结算账号并完成一笔**最低预存（通常为 $5 USD）**。
   - **扣费顺序**：系统**优先扣除每月赠送的 $10 抵用金**，只有当赠金全部用完后才会动用你的预存款。
4. **累积与有效期**：每月 $10 抵用金**可以累积**，每笔月度赠金自发放起**有效期 12 个月**（并非当月清零）。
5. **家庭共享限制**：仅**主订阅者本人**享有每月 $10 开发者抵用金，家庭组成员不单独获得该额度。
6. 在 [Google Cloud Console → Billing → Credits](https://console.cloud.google.com/billing) 可随时查看当前可用赠金余额与到期时间。

### 2. 必做防超支：设置 $10 预算告警

抵用金用完后若继续产生费用会扣绑定的信用卡，强烈建议立刻设置预算告警：

1. 打开 **Billing → Budgets & alerts → Create Budget**。
2. 预算金额设为 **$10**，告警阈值设为 **50% ($5)、80% ($8)、100% ($10)**。
3. 勾选发送邮件通知，确保每月消费清晰可控。

### 3. 本地安装 `gcloud` CLI（可选）

```bash
# macOS (Homebrew)
brew install --cask google-cloud-sdk

# 登录并选择项目
gcloud auth login
gcloud projects list
gcloud config set project <YOUR_PROJECT_ID>
```

### 3.5 创建个人通用 GCP 项目 + 为 `rclone` 配置私人 OAuth `client_id`（免费）

在 [Google Cloud Console](https://console.cloud.google.com/) 创建 1 个免费个人项目即可同时服务 `rclone` 与官方 Workspace MCP / `gws` CLI：

1. **新建项目**：顶部项目选择器 → **新建项目**（例如 `personal-workspace-hub`）→ 创建后切换到该项目。
2. **启用 API**：左侧 **API 和服务 → 库**，搜索并启用：
   - **Google Drive API**（`rclone` 必需）
   - 可顺手启用 **Gmail API**、**Google Docs API**、**Google Sheets API**、**Google Calendar API**（供后续 Workspace MCP / `gws` 共用）
3. **配置 OAuth 同意屏幕（Google Auth Platform）**：
   - 左侧 **Google Auth Platform → 概览 / 品牌**：填应用名（如 `Personal Workspace Tools`）和你的联系邮箱，受众选 **外部（External）**。
   - **受众（Audience）** 页：在 **测试用户（Test users）** 中添加你自己的 Gmail 地址。
   - *说明*：保持“测试”状态最省事，但 Refresh Token 约 **7 天**过期需重登一次；想长期有效，先在 **Branding** 页补齐应用主页与已授权网域并保存，再回 **Audience** 页点 **发布应用（Publish app）**（无需提交审核，未验证正式版支持 100 用户；发布后需跑一次 `rclone config reconnect gdrive: --auto-confirm` 刷掉旧的 7 天 Token）。
4. **创建桌面端 OAuth 客户端并下载 JSON**：
   - 左侧 **客户端（Clients）→ 创建客户端** → 应用类型选 **桌面应用（Desktop app）**，名称填 `mac-desktop-cli`（**不要勾选** `Use this client for an AI-powered agent`）→ 创建后点击 **下载 JSON（Download JSON）**。
5. **一键写入 `rclone` 并验证**：
   ```bash
   bash scripts/setup_rclone_client.sh ~/Downloads/client_secret_xxxx.json
   ```
   浏览器弹出后点同意授权（若提示未验证应用，点 **高级 → 继续**），完成后 `rclone about gdrive:` 将不再提示 `shared client_id` 警告。

### 4. $10/月最划算的开发者用法

- **Cloud Run**：部署个人 Webhook、轻量 FastAPI / Next.js 服务（配合免费额度，月费几乎为 $0–$2）。
- **Cloud Storage + Artifact Registry**：存放个人镜像、实验数据集备份。
- **Gemini API Paid Tier / Vertex AI 实验**：小规模自动化脚本与多模态接口调试。

---

## 二、Google Colab 每月 200 Compute Units（CU）

### 1. Compute Units 消耗规律（经验参考）

Colab 根据所选硬件按小时扣除 Compute Units（具体费率以 Colab 实时面板为准）：

| 加速器 | 大致消耗速度 | 200 CU 约可用时长 | 适用场景 |
|---|---|---|---|
| **CPU (Standard / High-RAM)** | ~0.07–0.15 CU/小时 | > 1000 小时 | 数据清洗、调用 Gemini API 批处理 |
| **T4 GPU (16 GB)** | ~1.5–2.0 CU/小时 | ~100–130 小时 | 常规 PyTorch 推理、中小模型测试、Whisper |
| **L4 GPU (24 GB)** | ~4–5 CU/小时 | ~40–50 小时 | 图像/视频模型推理、7B–14B 量化模型、LoRA 微调 |
| **A100 GPU (40/80 GB)** | ~11–15 CU/小时 | ~13–18 小时 | 大显存训练、重型多模态评测 |

### 2. 省算力最佳实践

1. **开发调试先用 CPU，真正跑模型再切 GPU**：改代码、装依赖时别挂着 A100 发呆。
2. **跑完自动释放运行时**：在最后一个 cell 末尾加上 `from google.colab import runtime; runtime.unassign()`，防止后台挂机空烧 CU。
3. **利用 5 TB Google Drive 持久化产物**：Pro 自带 5 TB 云盘，在 Colab 中直接 `drive.mount('/content/drive')`，把权重、数据集和 Checkpoint 存在 Drive 中，避免每次重下。
4. **开启后台执行（Background execution）**：长任务关闭浏览器标签页也能继续跑，完成后自动断开。

### 3. 配套入门 Notebook

直接将本项目的 [`demos/08_colab_gpu_starter.ipynb`](../demos/08_colab_gpu_starter.ipynb) 上传到 Colab，一键完成：
- GPU 型号与显存检测（`nvidia-smi` + PyTorch CUDA 基准）
- 挂载 5 TB Google Drive
- 通过 Colab Secrets 安全读取 `GEMINI_API_KEY` 并调用 `gemini-4-neon`
- 任务结束自动释放 GPU 运行时示例
