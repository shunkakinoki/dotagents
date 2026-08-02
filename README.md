# dotagents
Rules for Agents

## Sync workflow

```bash
make sync
```

This runs the full pipeline: prepares `.ruler/`, generates agent instruction files (`~/.claude/CLAUDE.md`, etc.) via Ruler, installs external skills from `skills-lock.json`, then syncs commands, local repo skills, MCP config, and dot directories to `$HOME`.

## External skills

External skills are declared in `SKILLS.txt` (canonical: repo plus comma-separated selection, no selection installs all) and locked in `skills-lock.json`, both committed. Installs go through the [skills CLI](https://github.com/vercel-labs/skills); global scope is scripted here because the CLI's own lock restore is project-only (see [vercel-labs/skills#549](https://github.com/vercel-labs/skills/issues/549)).

```bash
# Regenerate skills-lock.json from SKILLS.txt
make skills-lock

# Install everything in the lock that is missing (idempotent)
make skills-install

# Force a reinstall of everything in the lock
make skills-refresh
```

To add skills: edit `SKILLS.txt`, run `make skills-lock && make skills-install && make skills-lock` (the second lock captures resolved metadata), and commit both files. To remove: delete from `SKILLS.txt`, run `bunx skills remove <name> --global --yes`, then `make skills-lock`.
