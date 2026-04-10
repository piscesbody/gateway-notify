# Manual Setup Guide (Hermes)

This manual explains how to install the restart notification hook directly into **Hermes Agent**.

## Step 1: Create the hook directory

```bash
mkdir -p ~/.hermes/hooks/gateway-restart-notify
```

## Step 2: Create `HOOK.yaml`

Create `~/.hermes/hooks/gateway-restart-notify/HOOK.yaml`:

```yaml
name: gateway-restart-notify
description: Send a notification to configured targets when Hermes gateway starts.
events:
  - gateway:startup
```

## Step 3: Create `handler.py`

Create `~/.hermes/hooks/gateway-restart-notify/handler.py`.

This handler should:

- listen for `gateway:startup`
- build a restart notification message
- send it through Hermes `send_message`
- no-op when notifications are disabled

### Minimal example

```python
import json
import logging
import os
from datetime import datetime

logger = logging.getLogger("hooks.gateway-restart-notify")


def _enabled() -> bool:
    return os.getenv("GATEWAY_NOTIFY_ENABLED", "false").lower() in {"1", "true", "yes", "on"}


async def handle(event_type: str, context: dict) -> None:
    if event_type != "gateway:startup":
        return
    if not _enabled():
        return

    from tools.send_message_tool import send_message_tool

    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    message = (
        "🚀 Hermes gateway 已重启并恢复在线\n\n"
        f"⏰ Time: {now}\n"
        "如果你上一条消息因为重启被打断，直接回复“继续”即可。"
    )

    raw = send_message_tool({
        "action": "send",
        "target": "feishu",
        "message": message,
    })
    logger.info("notify result: %s", raw)
```

## Step 4: Configure environment variables

Add to `~/.hermes/.env`:

```bash
GATEWAY_NOTIFY_ENABLED=true
GATEWAY_NOTIFY_TARGETS=feishu
```

You can also target explicit destinations:

```bash
GATEWAY_NOTIFY_TARGETS=feishu:oc_xxx,telegram:-1001234567890
```

## Step 5: Restart Hermes gateway

```bash
hermes gateway restart
```

## Optional: custom template

```bash
GATEWAY_NOTIFY_TEMPLATE=🚀 Hermes restarted at {time}\nModel: {model}\nPlatforms: {platforms}
```

Supported placeholders:

- `{time}`
- `{model}`
- `{platforms}`

## Important limitation

This hook **does not automatically resume** a reply that was interrupted by restart.
It only notifies the user that Hermes is back online.
