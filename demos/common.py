"""所有 Python Demo 的公共工具：环境变量加载、输出目录管理、--dry-run 校验。"""

from __future__ import annotations

import argparse
import base64
import json
import os
import sys
from pathlib import Path
from typing import Any

PROJECT_ROOT = Path(__file__).resolve().parent.parent
OUTPUTS_DIR = PROJECT_ROOT / "outputs" / "python"


def load_env() -> None:
    """按优先级加载环境变量：已有 env > 项目 .env > ~/.env。"""
    try:
        from dotenv import load_dotenv
    except ImportError:
        return

    for candidate in (
        PROJECT_ROOT / ".env",
        Path.home() / ".env",
    ):
        if candidate.is_file():
            load_dotenv(candidate, override=False)


def parse_common_args(description: str) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="离线打印请求参数与配置预览，不发起真实 API 调用。",
    )
    return parser.parse_args()


def print_dry_run(title: str, payload: dict[str, Any]) -> None:
    print(f"[DRY-RUN] {title}")
    print(json.dumps(payload, ensure_ascii=False, indent=2))
    print()


def get_client(api_version: str | None = None):
    """创建 google-genai Client（要求 google-genai >= 3.5.0）。"""
    load_env()
    if not os.environ.get("GEMINI_API_KEY"):
        print(
            "错误：未检测到 GEMINI_API_KEY。\n"
            "请在本项目 .env、~/.env 或环境变量中设置 GEMINI_API_KEY，或加上 --dry-run 预览请求。",
            file=sys.stderr,
        )
        sys.exit(1)

    from google import genai

    if api_version:
        return genai.Client(http_options={"api_version": api_version})
    return genai.Client()


def ensure_outputs_dir() -> Path:
    OUTPUTS_DIR.mkdir(parents=True, exist_ok=True)
    return OUTPUTS_DIR


def save_base64_media(data: str | bytes, filename: str) -> Path:
    """将 API 返回的 base64 字符串或原始 bytes 保存到 outputs/python/。"""
    out_path = ensure_outputs_dir() / filename
    raw = base64.b64decode(data) if isinstance(data, str) else data
    out_path.write_bytes(raw)
    return out_path
