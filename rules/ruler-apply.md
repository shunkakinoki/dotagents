# /ruler-apply — Regenerate agent instructions with Ruler

Use this command whenever `.ruler/` files or command documentation changes, or after pulling updates that touch repository rules.

## When to Run
- After editing any file under `.ruler/` (including `commands/` docs referenced from there)
- Before committing changes that rely on regenerated instruction files such as `AGENTS.md`
- After rebasing or pulling main when rules may have changed

## Command Sequence
```fish
# Regenerate agent instruction files
pnpm run ruler:apply

# Double-check that regeneration left the tree clean
pnpm run ruler:check
```

## What to Inspect
- Review `git status` for modified instruction outputs (e.g., `AGENTS.md`, `.cursor/...`).
- If files changed, skim the diff to ensure new content reflects your rule updates.
- Commit regenerated files together with the rule change so other contributors stay in sync.

## Troubleshooting
- If `pnpm run ruler:check` reports a dirty tree, run `git status --short` to see which files still differ.
- For merge conflicts in generated files, resolve them in the source `.ruler/` Markdown first, re-run `/ruler-apply`, then commit the regenerated outputs.
- When `.gitignore` changes unexpectedly, confirm `[gitignore].enabled` in `.ruler/ruler.toml` matches the desired setting before re-running the command.
