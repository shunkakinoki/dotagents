#!/usr/bin/env bash
set -euo pipefail

ROOT="${DOTAGENTS_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MCP_SRC="${MCP_SRC:-${ROOT}/.ruler/mcp.json}"
SLACK_CALLBACK_PORT="${SLACK_MCP_CALLBACK_PORT:-3118}"

ENV_FILE="${DOTAGENTS_ENV_FILE:-}"
if [ -z "$ENV_FILE" ]; then
  for candidate in "${ROOT}/.env" "${ROOT}/../.env" "${HOME}/dotfiles/.env"; do
    if [ -f "$candidate" ]; then
      ENV_FILE="$candidate"
      break
    fi
  done
fi

if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
  set -a
  # shellcheck source=/dev/null
  . "$ENV_FILE"
  set +a
fi

MCP_TARGET_DIRS="${MCP_TARGET_DIRS:-${HOME}/.cursor ${HOME}/.claude ${HOME}/.codex}"
MCP_SETTINGS_TARGETS="${MCP_SETTINGS_TARGETS:-${HOME}/.cursor/settings.local.json ${HOME}/.claude/settings.local.json ${ROOT}/../.claude/settings.local.json}"

rendered_mcp="$(mktemp "${TMPDIR:-/tmp}/dotagents-mcp.XXXXXX")"
cleanup() {
  rm -f "$rendered_mcp"
}
trap cleanup EXIT

if [ -n "${SLACK_MCP_CLIENT_ID:-}" ]; then
  jq --arg client_id "$SLACK_MCP_CLIENT_ID" --arg callback_port "$SLACK_CALLBACK_PORT" \
    '.mcpServers.Slack = {
      type: "http",
      url: "https://mcp.slack.com/mcp",
      oauth: {
        clientId: $client_id,
        callbackPort: ($callback_port | tonumber)
      }
    }' \
    "$MCP_SRC" >"$rendered_mcp"
  echo "Injected Slack MCP into rendered config"
else
  cp -f "$MCP_SRC" "$rendered_mcp"
  echo "Slack MCP not rendered; set SLACK_MCP_CLIENT_ID to enable it locally"
fi

for target in $MCP_TARGET_DIRS; do
  if mkdir -p "$target" && cp -f "$rendered_mcp" "$target/mcp.json"; then
    echo "Synced $MCP_SRC → $target/mcp.json"
  else
    echo "Failed syncing $MCP_SRC → $target/mcp.json" >&2
    exit 1
  fi
done

keys="$(jq -c '.mcpServers | keys' "$rendered_mcp")"
for settings in $MCP_SETTINGS_TARGETS; do
  if [ -f "$settings" ]; then
    jq --argjson keys "$keys" '.enabledMcpjsonServers = $keys' "$settings" >"$settings.tmp"
    mv -f "$settings.tmp" "$settings"
    echo "Updated enabledMcpjsonServers in $settings"
  fi
done
