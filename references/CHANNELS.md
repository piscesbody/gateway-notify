# Supported Hermes Targets

This project uses **Hermes target syntax**, not OpenClaw-specific messaging commands.

## Target formats

### 1. Platform name only

Use the platform home channel:

```text
feishu
telegram
discord
slack
```

This requires the corresponding home channel to already be configured in Hermes.

### 2. Explicit target

Use `platform:chat_id` format:

```text
feishu:oc_xxx
telegram:-1001234567890
discord:123456789012345678
slack:C1234567890
```

### 3. Telegram topic / thread

```text
telegram:-1001234567890:17585
```

## Recommended Hermes targets

### Feishu

If you already use a Feishu home channel:

```text
feishu
```

If you want an explicit Feishu chat:

```text
feishu:oc_xxx
```

### Telegram

Use home channel:

```text
telegram
```

Use explicit chat ID:

```text
telegram:-1001234567890
```

Use topic/thread:

```text
telegram:-1001234567890:17585
```

### Discord

Use home channel:

```text
discord
```

Use explicit channel ID:

```text
discord:123456789012345678
```

### Slack

Use home channel:

```text
slack
```

Use explicit channel ID:

```text
slack:C1234567890
```

## Environment variable example

```bash
GATEWAY_NOTIFY_ENABLED=true
GATEWAY_NOTIFY_TARGETS=feishu,telegram
```

Or:

```bash
GATEWAY_NOTIFY_ENABLED=true
GATEWAY_NOTIFY_TARGETS=feishu:oc_xxx
```

## Important note

This project sends notifications through **Hermes delivery paths**.

It does not depend on:

- `openclaw message`
- `imsg`
- `wacli`

unless you intentionally build a custom Hermes hook that shells out to those tools yourself.
