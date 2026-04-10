# 手动安装指南（Hermes）

本手册说明如何把“网关重启通知”Hook 手动安装到 **Hermes Agent** 中。

## 步骤 1：创建 Hook 目录

```bash
mkdir -p ~/.hermes/hooks/gateway-restart-notify
```

## 步骤 2：创建 `HOOK.yaml`

在 `~/.hermes/hooks/gateway-restart-notify/HOOK.yaml` 中写入：

```yaml
name: gateway-restart-notify
description: Send a notification to configured targets when Hermes gateway starts.
events:
  - gateway:startup
```

## 步骤 3：创建 `handler.py`

在 `~/.hermes/hooks/gateway-restart-notify/handler.py` 中实现逻辑。

这个处理器应该：

- 监听 `gateway:startup`
- 生成启动通知消息
- 使用 Hermes 的 `send_message` 路径发送消息
- 在未启用时安静退出

### 最小示例

```python
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

## 步骤 4：配置环境变量

在 `~/.hermes/.env` 中加入：

```bash
GATEWAY_NOTIFY_ENABLED=true
GATEWAY_NOTIFY_TARGETS=feishu
```

也可以写明确目标：

```bash
GATEWAY_NOTIFY_TARGETS=feishu:oc_xxx,telegram:-1001234567890
```

## 步骤 5：重启 Hermes gateway

```bash
hermes gateway restart
```

## 可选：自定义模板

```bash
GATEWAY_NOTIFY_TEMPLATE=🚀 Hermes 已重启\n时间：{time}\n模型：{model}\n平台：{platforms}
```

支持占位符：

- `{time}`
- `{model}`
- `{platforms}`

## 重要限制

这个 Hook **不会自动恢复** 被重启打断的那条回复。

它解决的是：
- 重启后无提示
- 用户不知道 Hermes 是否恢复在线

它不能解决的是：
- 自动接着发完被中断的回复
