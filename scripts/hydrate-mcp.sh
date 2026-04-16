#!/usr/bin/env bash
set -euo pipefail

ROOT="${DOTAGENTS_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
MCP_SRC="${MCP_SRC:-${ROOT}/.ruler/mcp.json}"

MCP_TARGET_DIRS="${MCP_TARGET_DIRS:-${HOME}/.cursor ${HOME}/.claude ${HOME}/.codex}"
MCP_SETTINGS_TARGETS="${MCP_SETTINGS_TARGETS:-${HOME}/.cursor/settings.local.json ${HOME}/.claude/settings.local.json ${ROOT}/../.claude/settings.local.json}"

for target in $MCP_TARGET_DIRS; do
  if mkdir -p "$target" && cp -f "$MCP_SRC" "$target/mcp.json"; then
    echo "Synced $MCP_SRC → $target/mcp.json"
  else
    echo "Failed syncing $MCP_SRC → $target/mcp.json" >&2
    exit 1
  fi
done

keys="$(jq -c '.mcpServers | keys' "$MCP_SRC")"
for settings in $MCP_SETTINGS_TARGETS; do
  if [ -f "$settings" ]; then
    jq --argjson keys "$keys" '.enabledMcpjsonServers = $keys' "$settings" >"$settings.tmp"
    mv -f "$settings.tmp" "$settings"
    echo "Updated enabledMcpjsonServers in $settings"
  fi
done
