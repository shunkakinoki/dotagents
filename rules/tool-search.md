# Tool Search

- **Files**: `fd` — `fd '*.ts'`, `fd config.json`
- **Text**: `rg` — `rg "pattern" -A 3`, `rg -i "todo"`
- **Code structure**: `ast-grep --lang ts -p 'function $NAME($ARGS) { $$$ }'`
- **Interactive**: `fzf` — `fd '*.ts' | fzf`
- **JSON/YAML**: `jq`, `yq`

Use `ast-grep` for code patterns (avoids false positives from comments/strings). Fall back to `rg` for plain text, docs, and unsupported languages.

## Images

- When the model cannot read an image, OCR it before replying. Never claim you cannot see an image without attempting OCR first.
- `tesseract image.png -` for a quick read; add `--psm 4` for multi-column screenshots and terminal captures.
- If `tesseract` is missing, run it via `nix shell nixpkgs#tesseract --command tesseract ...`.
