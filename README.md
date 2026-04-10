# dotagents
Rules for Agents

## Sync workflow

```bash
make sync
```

This runs the full pipeline: prepares `.ruler/`, generates agent instruction files (`~/.claude/CLAUDE.md`, etc.) via Ruler, reconciles managed external skills from `SKILLS.txt` against the actual installed skill directories, then syncs commands, local repo skills, MCP config, and dot directories to `$HOME`.

To force a clean reinstall of external skills, run:

```bash
make skills-refresh
```
