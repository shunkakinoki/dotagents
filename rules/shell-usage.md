# Shell Usage Standard (Fish)

This repository uses the Fish shell for interactive commands and automation snippets, aligned with the system configuration. Prefer Fish for new scripts and examples.

## Policy
- Default shell: Fish (`#!/usr/bin/env fish`).
- Provide Fish snippets for automation examples; keep Bash as optional fallback when helpful.
- Keep one-file, shell-agnostic command sequences unchanged when they work in both shells.

## Conventions
- Variables: `set NAME value` (no `=`). Export: `set -x NAME value`.
- Arrays/lists: `set items a b c`; append: `set items $items d`.
- Conditionals: `if test -f file; ...; end`; switches: `switch $var; case value; ...; end`.
- Substitution: `set VAR (command ...)`.
- PATH: `set -x PATH /new/bin $PATH`.

## Shebangs
- Use `#!/usr/bin/env fish` for executable scripts.

## Compatibility Notes
- Avoid `set -euo pipefail`; Fish handles errors differently. Use explicit checks or `status` as needed.
- When porting Bash snippets, verify quoting and list handling.

