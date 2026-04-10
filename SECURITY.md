# Security & Privacy (Hermes Fork)

## What this fork does

This Hermes-compatible fork creates a startup hook that:

1. listens for `gateway:startup`
2. builds a short restart notification
3. sends that notification via Hermes delivery paths

## What data it uses

The hook may read:

- current timestamp
- current Hermes model name
- list of connected platforms
- environment variables in `~/.hermes/.env` related to notification targets

## What it does NOT access

This fork does **not** need to read:

- your chat history
- your secrets for unrelated providers
- your personal files outside Hermes config/hook paths
- your old OpenClaw config

## Delivery model

This project uses Hermes-native delivery:

- Hermes hook event: `gateway:startup`
- Hermes message routing: `send_message`
- Hermes home-channel resolution

It does **not** require shelling out to OpenClaw CLI commands.

## Environment variables

Typical configuration:

```bash
GATEWAY_NOTIFY_ENABLED=true
GATEWAY_NOTIFY_TARGETS=feishu
```

Optional:

```bash
GATEWAY_NOTIFY_TEMPLATE=... 
```

## Safety notes

- The default installer writes only the notification-related env vars.
- The installer does **not** auto-restart Hermes unless you pass `--restart`.
- The hook is restart-notify only; it does not replay or resume interrupted replies.

## Recommended review checklist

Before using this fork, review:

- `scripts/setup_gateway_notify.sh`
- `hook/HOOK.yaml`
- `hook/handler.py`
- `references/MANUAL.md`

## Limitation disclosure

This fork improves restart visibility, but it does **not** change Hermes core restart semantics. Ordinary in-flight replies may still be interrupted by gateway restart.

## Questions?

Open an issue on your fork or upstream adaptation repo.
