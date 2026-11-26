"""Demo 02: Pydantic 结构化输出 + Decisions API (gemini-decision-1 校准决策)。"""

from __future__ import annotations

from pydantic import BaseModel, Field

from common import get_client, parse_common_args, print_dry_run


class ResourcePlan(BaseModel):
    benefit_name: str = Field(description="Google AI Pro 权益名称")
    monthly_quota: str = Field(description="月度额度")
    best_use_case: str = Field(description="最适合个人开发者的使用场景")
    cost_saving_tip: str = Field(description="省钱/防超支建议")


class ProPlanSummary(BaseModel):
    items: list[ResourcePlan]


def main() -> None:
    args = parse_common_args("Pydantic 结构化输出 + Decisions API 演示")

    structured_req = {
        "model": "gemini-4-hydrogen",
        "input": "整理 Google AI Pro 中最适合开发者的 3 项核心资源：GCP $10 抵用金、Colab 200 Compute Units、Antigravity 更高额度。",
        "response_format": {
            "type": "text",
            "mime_type": "application/json",
            "schema": ProPlanSummary.model_json_schema(),
        },
        "store": False,
    }

    decision_req = {
        "api_version": "v1beta",
        "model": "gemini-decision-1",
        "input": "用户计划用 Google AI Pro 附带的 YouTube Premium Lite 分享给 5 位家庭成员一起使用。",
        "questions": {
            "is_allowed": {
                "type": "noul",
                "instructions": "根据 Google AI Pro 规则，YouTube Premium Lite 是否允许家庭共享？",
            },
            "needs_warning": {
                "type": "noul",
                "instructions": "是否应该提醒用户该权益仅限订阅者本人使用？",
            },
        },
    }

    if args.dry_run:
        print_dry_run("1. Pydantic 结构化输出", structured_req)
        print_dry_run("2. Decisions API 校准决策 (v1beta)", decision_req)
        return

    client_v1 = get_client()
    print("=== 1. Pydantic 结构化输出 (gemini-4-hydrogen) ===")
    resp = client_v1.interactions.create(**structured_req)
    parsed = ProPlanSummary.model_validate_json(resp.output_text)
    print(parsed.model_dump_json(indent=2, ensure_ascii=False))

    client_beta = get_client(api_version="v1beta")
    print("\n=== 2. Decisions API 校准是非判断 (gemini-decision-1, 0 output tokens) ===")
    decision = client_beta.decisions.create(
        model=decision_req["model"],
        input=decision_req["input"],
        questions=decision_req["questions"],
    )
    for key, ans in decision.answers.items():
        print(f"- {key}: P(yes)={ans.noul:.3f}, confidence={ans.confidence:.3f}")


if __name__ == "__main__":
    main()
