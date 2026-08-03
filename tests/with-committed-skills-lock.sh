#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$REPO_ROOT/scripts/with-committed-skills-lock.sh"
TEST_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/dotagents-lock-test.XXXXXX")"

cleanup() {
  rm -rf "$TEST_ROOT"
}
trap cleanup EXIT

fail() {
  echo "not ok - $1" >&2
  exit 1
}

assert_eq() {
  local expected=$1
  local actual=$2
  local message=$3

  [[ "$actual" == "$expected" ]] || fail "$message: expected '$expected', got '$actual'"
}

FIXTURE="$TEST_ROOT/repo"
CAPTURE="$TEST_ROOT/capture"
MOCK_COMMAND="$TEST_ROOT/capture-lock"
mkdir -p "$FIXTURE"
git -C "$FIXTURE" init --quiet
git -C "$FIXTURE" config user.email test@example.com
git -C "$FIXTURE" config user.name 'Dotagents Test'
printf 'committed\n' >"$FIXTURE/skills-lock.json"
git -C "$FIXTURE" add skills-lock.json
git -C "$FIXTURE" commit --quiet -m initial
printf 'user-owned\n' >"$FIXTURE/skills-lock.json"

cat >"$MOCK_COMMAND" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "$SKILLS_LOCK_FILE" >"$CAPTURE.path"
cat "$SKILLS_LOCK_FILE" >"$CAPTURE.contents"
printf 'generated\n' >"$SKILLS_LOCK_FILE"
exit "${MOCK_STATUS:-0}"
EOF
chmod +x "$MOCK_COMMAND"

DOTAGENTS_ROOT="$FIXTURE" \
  CAPTURE="$CAPTURE" \
  "$SCRIPT" "$MOCK_COMMAND"

assert_eq 'committed' "$(cat "$CAPTURE.contents")" 'sync command should receive committed lock'
assert_eq 'user-owned' "$(cat "$FIXTURE/skills-lock.json")" 'working lock should remain unchanged'
TEMP_LOCK="$(cat "$CAPTURE.path")"
[[ ! -e "$TEMP_LOCK" ]] || fail 'temporary lock should be removed after success'

cat >"$FIXTURE/Makefile" <<'EOF'
SKILLS_LOCK_FILE ?= missing

.PHONY: capture
capture:
	@printf '%s\n' "$(SKILLS_LOCK_FILE)" >"$$CAPTURE.path"
	@cat "$(SKILLS_LOCK_FILE)" >"$$CAPTURE.contents"
	@printf 'generated\n' >"$(SKILLS_LOCK_FILE)"
EOF

DOTAGENTS_ROOT="$FIXTURE" \
  CAPTURE="$CAPTURE" \
  "$SCRIPT" make -C "$FIXTURE" capture

assert_eq 'committed' "$(cat "$CAPTURE.contents")" 'make should inherit temporary lock override'
assert_eq 'user-owned' "$(cat "$FIXTURE/skills-lock.json")" 'make should preserve working lock'
TEMP_LOCK="$(cat "$CAPTURE.path")"
[[ ! -e "$TEMP_LOCK" ]] || fail 'make temporary lock should be removed'

set +e
DOTAGENTS_ROOT="$FIXTURE" \
  CAPTURE="$CAPTURE" \
  MOCK_STATUS=42 \
  "$SCRIPT" "$MOCK_COMMAND"
status=$?
set -e

assert_eq '42' "$status" 'sync failure should propagate'
assert_eq 'user-owned' "$(cat "$FIXTURE/skills-lock.json")" 'failure should preserve working lock'
TEMP_LOCK="$(cat "$CAPTURE.path")"
[[ ! -e "$TEMP_LOCK" ]] || fail 'temporary lock should be removed after failure'

echo 'ok - committed skills lock isolation'
