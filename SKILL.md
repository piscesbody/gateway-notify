---
name: gateway-notify
description: "Set up automatic restart notifications for Hermes gateway. Use when the user wants a message after Hermes gateway comes back online so restart events are visible in Feishu, Telegram, or other configured channels."
---

# Gateway Notify for Hermes

Set up a Hermes hook that sends a startup notification whenever the **Hermes gateway** restarts and reconnects.

## What It Does

Installs a `gateway:startup` hook into `~/.hermes/hooks/gateway-restart-notify` and configures notification targets through `~/.hermes/.env`.

The hook sends a short message after gateway startup with:

- current time
- current model
- connected platforms
- a prompt telling the user to reply **"继续"** if the previous message was interrupted by restart

## What It Solves

This skill solves:

- “Hermes gateway restarted but I got no signal that it was back”
- “I don't know whether restart succeeded”
- “The previous reply disappeared during restart and I want a visible recovery hint”

## What It Does NOT Solve

This skill does **not** resume an interrupted in-flight reply automatically.

It is a **restart notification** solution, not a **restart resume** mechanism.

## Quick Start

Install for a platform home channel:

```bash
scripts/setup_gateway_notify.sh feishu
```

Install for an explicit target:

```bash
scripts/setup_gateway_notify.sh feishu oc_xxx
scripts/setup_gateway_notify.sh telegram -1001234567890
scripts/setup_gateway_notify.sh feishu:oc_xxx
```

Restart the gateway after setup:

```bash
hermes gateway restart
```

## What the setup script does

The script:

1. Creates `~/.hermes/hooks/gateway-restart-notify/`
2. Copies `HOOK.yaml` and `handler.py`
3. Writes `GATEWAY_NOTIFY_ENABLED=true` into `~/.hermes/.env`
4. Writes `GATEWAY_NOTIFY_TARGETS=...` into `~/.hermes/.env`
5. Optionally restarts gateway if `--restart` is passed

## Hermes-native implementation details

This port is built on Hermes-native primitives:

- `gateway:startup` event
- `~/.hermes/hooks/` hook discovery
- `HOOK.yaml` + `handler.py`
- `send_message` tool path
- home-channel routing

## Recommended usage

Best for users who frequently restart Hermes gateway and want confirmation in messaging apps like:

- Feishu
- Telegram
- Discord
- Slack
- any Hermes-connected platform supported by `send_message`

## Configuration

Minimal:

```bash
GATEWAY_NOTIFY_ENABLED=true
```

Explicit targets:

```bash
GATEWAY_NOTIFY_ENABLED=true
GATEWAY_NOTIFY_TARGETS=feishu,telegram
```

Custom template:

```bash
GATEWAY_NOTIFY_TEMPLATE=🚀 Hermes restarted at {time}\nModel: {model}\nPlatforms: {platforms}
```

Available placeholders:

- `{time}`
- `{model}`
- `{platforms}`

## Manual setup

See:

- `references/MANUAL.md`
- `references/MANUAL_zh.md`

## Supported target syntax

See:

- `references/CHANNELS.md`

## Notes

If the user wants true automatic continuation after restart, this skill alone is not enough. That would require Hermes core support for persisting and resuming in-flight reply state.
