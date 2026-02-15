# Shell Usage — Fish

Default shell: Fish (`#!/usr/bin/env fish`).

- Variables: `set NAME value`, export: `set -x NAME value`
- Substitution: `set VAR (command ...)`
- Conditionals: `if test -f file; ...; end`
- No `set -euo pipefail` — use explicit checks
