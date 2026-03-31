# dotagents
Rules for Agents

## Sync workflow

1. `make ruler-prepare` - copies `rules/`, `commands/`, `skills/` into `.ruler/`
2. `make ruler-apply-global` - runs Ruler to generate agent instruction files (`~/.claude/CLAUDE.md`, etc.) from `.ruler/`
3. `make sync` - syncs commands, skills, MCP config, and dot directories to `$HOME`

After adding or editing a rule in `rules/`, run all three in order:

```bash
make ruler-prepare
make ruler-apply-global
make sync
```
