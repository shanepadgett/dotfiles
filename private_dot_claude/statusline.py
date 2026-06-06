#!/usr/bin/env python3
import json
import sys
from datetime import datetime, timezone

PRICING = {
    "claude-sonnet-4-6":         {"input": 3.00,  "output": 15.00, "cache_write": 3.75,  "cache_read": 0.30},
    "claude-opus-4-6":           {"input": 15.00, "output": 75.00, "cache_write": 18.75, "cache_read": 1.50},
    "claude-opus-4-7":           {"input": 15.00, "output": 75.00, "cache_write": 18.75, "cache_read": 1.50},
    "claude-opus-4-8":           {"input": 15.00, "output": 75.00, "cache_write": 18.75, "cache_read": 1.50},
    "claude-haiku-4-5-20251001": {"input": 0.80,  "output": 4.00,  "cache_write": 1.00,  "cache_read": 0.08},
}
DEFAULT_PRICING = {"input": 3.00, "output": 15.00, "cache_write": 3.75, "cache_read": 0.30}


def get_model_id(data):
    model = data.get("model")
    if isinstance(model, dict):
        return model.get("id")
    return model


def calc_cost(tokens, model_id=None):
    p = PRICING.get(model_id, DEFAULT_PRICING)
    return (
        (tokens.get("input_tokens", 0) / 1_000_000) * p["input"]
        + (tokens.get("output_tokens", 0) / 1_000_000) * p["output"]
        + (tokens.get("cache_creation_input_tokens", 0) / 1_000_000) * p["cache_write"]
        + (tokens.get("cache_read_input_tokens", 0) / 1_000_000) * p["cache_read"]
    )


def fmt_cost(cost):
    if cost < 0.01:
        return "${:.4f}".format(cost)
    return "${:.2f}".format(cost)


def fmt_resets(resets_at_str):
    try:
        resets_at = datetime.fromisoformat(resets_at_str.replace("Z", "+00:00"))
        now = datetime.now(timezone.utc)
        delta = resets_at - now
        total_secs = int(delta.total_seconds())
        if total_secs <= 0:
            return "now"
        h, rem = divmod(total_secs, 3600)
        m = rem // 60
        if h > 0:
            return "{}h{}m".format(h, m)
        return "{}m".format(m)
    except Exception:
        return "?"


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    model_id = get_model_id(data)
    context_window = data.get("context_window", {})
    current_usage = context_window.get("current_usage")
    parts = []

    # Last prompt cost
    if current_usage is not None:
        cost = calc_cost(current_usage, model_id)
        parts.append("Last: {}".format(fmt_cost(cost)))

    # Total chat cost — use provided total_cost_usd if available, else calculate
    cost_info = data.get("cost", {})
    total_cost_usd = cost_info.get("total_cost_usd")
    if total_cost_usd is not None:
        parts.append("Chat: {}".format(fmt_cost(total_cost_usd)))
    else:
        total_tokens = {
            "input_tokens": context_window.get("total_input_tokens", 0),
            "output_tokens": context_window.get("total_output_tokens", 0),
            "cache_creation_input_tokens": context_window.get("total_cache_creation_input_tokens", 0),
            "cache_read_input_tokens": context_window.get("total_cache_read_input_tokens", 0),
        }
        if any(v > 0 for v in total_tokens.values()):
            parts.append("Chat: {}".format(fmt_cost(calc_cost(total_tokens, model_id))))

    # Usage pool from rate_limits (prefer 5-hour window, fall back to 7-day)
    rate_limits = data.get("rate_limits", {})
    window = rate_limits.get("five_hour") or rate_limits.get("seven_day")
    if window:
        used_pct = window.get("used_percentage")
        resets_at = window.get("resets_at")
        if used_pct is not None:
            label = "5h" if "five_hour" in rate_limits else "7d"
            pool_str = "Pool({}): {:.0f}%".format(label, used_pct)
            if resets_at:
                pool_str += " resets {}".format(fmt_resets(resets_at))
            parts.append(pool_str)

    if parts:
        print("  |  ".join(parts))


if __name__ == "__main__":
    main()
