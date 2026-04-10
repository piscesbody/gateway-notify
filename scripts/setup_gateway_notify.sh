#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
HOOK_SRC_DIR="$REPO_ROOT/hook"
HOOK_DST_DIR="$HOME/.hermes/hooks/gateway-restart-notify"
ENV_FILE="$HOME/.hermes/.env"

usage() {
  cat <<'EOF'
Usage:
  scripts/setup_gateway_notify.sh <target>
  scripts/setup_gateway_notify.sh <platform> <chat_id>
  scripts/setup_gateway_notify.sh <target> --restart

Examples:
  scripts/setup_gateway_notify.sh feishu
  scripts/setup_gateway_notify.sh telegram
  scripts/setup_gateway_notify.sh feishu oc_xxx
  scripts/setup_gateway_notify.sh telegram -1001234567890
  scripts/setup_gateway_notify.sh feishu:oc_xxx --restart

Target format:
  platform             -> use Hermes home channel for that platform
  platform:chat_id     -> use explicit destination
  telegram:chat:thread -> Telegram topic/thread target
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

RESTART_AFTER=false
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --restart)
      RESTART_AFTER=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      ARGS+=("$arg")
      ;;
  esac
done

if [[ ${#ARGS[@]} -eq 0 || ${#ARGS[@]} -gt 2 ]]; then
  usage
  exit 1
fi

if [[ ${#ARGS[@]} -eq 1 ]]; then
  TARGET="${ARGS[0]}"
else
  PLATFORM="${ARGS[0]}"
  CHAT_ID="${ARGS[1]}"
  if [[ "$PLATFORM" == *:* ]]; then
    echo "Error: first argument should be a platform name when passing two arguments."
    exit 1
  fi
  TARGET="${PLATFORM}:${CHAT_ID}"
fi

if [[ ! -f "$HOOK_SRC_DIR/HOOK.yaml" || ! -f "$HOOK_SRC_DIR/handler.py" ]]; then
  echo "Error: hook source files not found in $HOOK_SRC_DIR"
  exit 1
fi

validate_target() {
  local target="$1"
  if [[ "$target" =~ ^[a-z]+$ ]]; then
    return 0
  fi
  if [[ "$target" =~ ^[a-z]+:.+$ ]]; then
    return 0
  fi
  return 1
}

if ! validate_target "$TARGET"; then
  echo "Error: invalid target: $TARGET"
  echo "Expected platform or platform:chat_id"
  exit 1
fi

mkdir -p "$HOOK_DST_DIR"
cp "$HOOK_SRC_DIR/HOOK.yaml" "$HOOK_DST_DIR/HOOK.yaml"
cp "$HOOK_SRC_DIR/handler.py" "$HOOK_DST_DIR/handler.py"

mkdir -p "$(dirname "$ENV_FILE")"
touch "$ENV_FILE"

upsert_env() {
  local key="$1"
  local value="$2"
  python3 - <<PY
from pathlib import Path
path = Path(r'''$ENV_FILE''')
key = "$1"
value = "$2"
text = path.read_text(encoding='utf-8') if path.exists() else ''
lines = text.splitlines()
found = False
new_lines = []
for line in lines:
    stripped = line.strip()
    if stripped.startswith(f"{key}=") or stripped.startswith(f"# {key}="):
        new_lines.append(f"{key}={value}")
        found = True
    else:
        new_lines.append(line)
if not found:
    if new_lines and new_lines[-1].strip() != '':
        new_lines.append('')
    new_lines.append(f"{key}={value}")
path.write_text("\n".join(new_lines) + "\n", encoding='utf-8')
PY
}

upsert_env GATEWAY_NOTIFY_ENABLED true
upsert_env GATEWAY_NOTIFY_TARGETS "$TARGET"

echo "✓ Installed Hermes hook to: $HOOK_DST_DIR"
echo "✓ Enabled restart notifications"
echo "✓ Target: $TARGET"

echo
if [[ "$RESTART_AFTER" == true ]]; then
  echo "Restarting Hermes gateway..."
  hermes gateway restart
else
  echo "Next step: run 'hermes gateway restart' to activate the hook."
fi
