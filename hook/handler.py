import json
import logging
import os
from datetime import datetime
from typing import List

logger = logging.getLogger("hooks.gateway-restart-notify")
_TRUTHY = {"1", "true", "yes", "on"}


def _enabled() -> bool:
    return str(os.getenv("GATEWAY_NOTIFY_ENABLED", "false")).strip().lower() in _TRUTHY


def _use_home_targets() -> bool:
    return str(os.getenv("GATEWAY_NOTIFY_USE_HOME", "true")).strip().lower() in _TRUTHY


def _split_targets(raw: str) -> List[str]:
    result: List[str] = []
    for item in (raw or "").split(","):
        item = item.strip()
        if item and item not in result:
            result.append(item)
    return result


def _resolve_home_targets(platforms: List[str]) -> List[str]:
    try:
        from gateway.config import load_gateway_config
        cfg = load_gateway_config()
    except Exception as e:
        logger.warning("Failed to load Hermes config for gateway notify: %s", e)
        return []

    requested = {str(p).strip().lower() for p in platforms if str(p).strip()}
    targets: List[str] = []
    for platform, _pconfig in cfg.platforms.items():
        if requested and platform.value not in requested:
            continue
        home = cfg.get_home_channel(platform)
        if not home:
            continue
        target = f"{platform.value}:{home.chat_id}"
        if target not in targets:
            targets.append(target)
    return targets


def _resolve_targets(context: dict) -> List[str]:
    explicit = _split_targets(os.getenv("GATEWAY_NOTIFY_TARGETS", ""))
    if explicit:
        return explicit
    if _use_home_targets():
        return _resolve_home_targets(list(context.get("platforms") or []))
    return []


def _build_message(context: dict) -> str:
    try:
        from hermes_cli.config import load_config
        cfg = load_config()
        model_name = cfg.get("model", {}).get("default", "unknown")
    except Exception:
        model_name = "unknown"

    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    platforms = ", ".join(context.get("platforms") or []) or "unknown"
    template = os.getenv("GATEWAY_NOTIFY_TEMPLATE", "").strip()
    if template:
        try:
            return template.format(time=now, model=model_name, platforms=platforms)
        except Exception as e:
            logger.warning("Invalid GATEWAY_NOTIFY_TEMPLATE; falling back to default: %s", e)

    return (
        "🚀 Hermes gateway 已重启并恢复在线\n\n"
        f"⏰ Time: {now}\n"
        f"🤖 Model: {model_name}\n"
        f"🌐 Platforms: {platforms}\n\n"
        "如果你上一条消息因为重启被打断，直接回复“继续”即可。"
    )


async def handle(event_type: str, context: dict) -> None:
    if event_type != "gateway:startup":
        return
    if not _enabled():
        logger.info("gateway-restart-notify: disabled")
        return

    targets = _resolve_targets(context or {})
    if not targets:
        logger.info("gateway-restart-notify: no targets resolved")
        return

    message = _build_message(context or {})

    try:
        from tools.send_message_tool import send_message_tool
    except Exception as e:
        logger.error("gateway-restart-notify: failed to import send_message_tool: %s", e)
        return

    for target in targets:
        try:
            raw = send_message_tool({"action": "send", "target": target, "message": message})
            result = json.loads(raw) if isinstance(raw, str) else raw
            if isinstance(result, dict) and result.get("error"):
                logger.warning("gateway-restart-notify: send to %s failed: %s", target, result.get("error"))
            else:
                logger.info("gateway-restart-notify: notification sent to %s", target)
        except Exception as e:
            logger.error("gateway-restart-notify: send to %s crashed: %s", target, e)
