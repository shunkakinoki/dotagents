# Tool Search

- **Files**: `fd` — `fd '*.ts'`, `fd config.json`
- **Text**: `rg` — `rg "pattern" -A 3`, `rg -i "todo"`
- **Code structure**: `ast-grep --lang ts -p 'function $NAME($ARGS) { $$$ }'`
- **Interactive**: `fzf` — `fd '*.ts' | fzf`
- **JSON/YAML**: `jq`, `yq`

Use `ast-grep` for code patterns (avoids false positives from comments/strings). Fall back to `rg` for plain text, docs, and unsupported languages.
