# Gateway Notify for Hermes

Hermes-compatible fork of the original **gateway-notify** idea.

This version is adapted for **Hermes Agent** and sends a startup notification when the Hermes gateway comes back online after a restart.

## Why this fork exists

The original project was designed for **OpenClaw**. Hermes has a different gateway architecture, hook system, and message delivery path, so this fork reframes the project around Hermes-native primitives:

- `gateway:startup` hook events
- `~/.hermes/hooks/` user hook directory
- Hermes `send_message` tool
- Hermes home-channel routing for platforms like Feishu / Telegram

## What problem it solves

When Hermes gateway restarts, users often see a period of silence and cannot immediately tell whether:

- the gateway is already back online
- the restart finished successfully
- the previous reply was interrupted by restart

This project fixes the **"restart后无提示"** problem by proactively sending a startup notification after the gateway reconnects.

## What it does

On `gateway:startup`, this hook can send a message containing:

- restart time
- current model
- connected platforms
- a hint to reply **"继续"** if the previous message was interrupted

## What it does NOT do

This project **does not automatically resume an interrupted in-flight reply**.

It solves:
- ✅ restart notification
- ✅ restart visibility
- ✅ user awareness that Hermes is back online

It does **not** solve:
- ❌ automatic continuation of a partially-generated reply after restart

That limitation comes from Hermes gateway task cancellation during restart.

## Features

- 🚀 Automatic notification on Hermes gateway startup
- 💬 Uses Hermes-native messaging delivery
- 🌐 Works with Hermes-connected platforms
- 🧩 Built on Hermes gateway hooks
- 🏠 Supports home-channel delivery
- ⚙️ Simple environment-variable configuration

## Hermes compatibility

This fork is intended for **Hermes Agent**, not OpenClaw.

Hermes-native concepts used by this fork:

- `gateway:startup` hook event
- `HOOK.yaml` + `handler.py` hook layout
- `send_message` tool for delivery
- platform home channels
- `~/.hermes/.env` configuration

## Quick Start

### 1. Install the hook

Copy the hook into your Hermes hooks directory:

```bash
mkdir -p ~/.hermes/hooks/gateway-restart-notify
```

Add:

- `HOOK.yaml`
- `handler.py`

### 2. Enable it

In `~/.hermes/.env`:

```bash
GATEWAY_NOTIFY_ENABLED=true
GATEWAY_NOTIFY_TARGETS=feishu
```

### 3. Restart Hermes gateway

```bash
hermes gateway restart
```

After the gateway comes back online, it will send a startup notification.

## Configuration

### Minimal setup

Send to configured home channels:

```bash
GATEWAY_NOTIFY_ENABLED=true
```

### Send only to Feishu

```bash
GATEWAY_NOTIFY_ENABLED=true
GATEWAY_NOTIFY_TARGETS=feishu
```

### Explicit targets

```bash
GATEWAY_NOTIFY_ENABLED=true
GATEWAY_NOTIFY_TARGETS=feishu:oc_xxx,telegram:-1001234567890
```

### Optional custom template

Available placeholders:

- `{time}`
- `{model}`
- `{platforms}`

Example:

```bash
GATEWAY_NOTIFY_TEMPLATE=🚀 Hermes restarted at {time}\nModel: {model}\nPlatforms: {platforms}
```

## Example notification

```text
🚀 Hermes gateway 已重启并恢复在线

⏰ Time: 2026-04-10 12:14:39
🤖 Model: gpt-5.4
🌐 Platforms: telegram, feishu

如果你上一条消息因为重启被打断，直接回复“继续”即可。
```

## Architecture notes

This fork is intentionally Hermes-specific.

The original OpenClaw version used OpenClaw-specific messaging commands and OpenClaw hook conventions.
This Hermes version instead relies on:

- Hermes gateway lifecycle hooks
- Hermes configuration loading
- Hermes delivery routing
- Hermes platform adapters

## Recommended positioning for this repo

If you want this fork to be clear on GitHub, I recommend describing it as:

> Hermes-compatible port of gateway-notify. Adds restart notifications for Hermes gateway so users know the agent is back online after a restart.

## Future work

Possible future improvements:

- persist a “restart pending” marker for richer restart context
- optionally notify only when a reply was interrupted
- add installer scripts for Hermes hook layout
- provide both English and Chinese setup docs

## License

MIT

## Credits

Based on the original **gateway-notify** concept by the original project author, adapted here for **Hermes Agent**.
