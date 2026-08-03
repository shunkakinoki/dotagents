#!/usr/bin/env bash

set -euo pipefail

if (($# == 0)); then
  echo "Usage: $0 <command> [args...]" >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTAGENTS_ROOT="${DOTAGENTS_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
CURRENT_LOCK="${SKILLS_LOCK_FILE:-$DOTAGENTS_ROOT/skills-lock.json}"
TEMP_LOCK="$(mktemp "${TMPDIR:-/tmp}/dotagents-skills-lock.XXXXXX")"

cleanup() {
  local status=$?
  trap - EXIT
  rm -f "$TEMP_LOCK" "$TEMP_LOCK.tmp"
  exit "$status"
}
trap cleanup EXIT

if git -C "$DOTAGENTS_ROOT" show HEAD:skills-lock.json >"$TEMP_LOCK" 2>/dev/null; then
  echo "Using committed skills-lock.json for synchronization."
else
  echo "Git metadata unavailable; using the current skills lock for synchronization."
  cp -f "$CURRENT_LOCK" "$TEMP_LOCK"
fi

SKILLS_LOCK_FILE="$TEMP_LOCK" "$@"
