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
# Install everything declared in SKILLS.txt that is missing (idempotent;
# regenerates skills-lock.json automatically)
make skills-install

# Update installed skills to latest and refresh the lock
make skills-update

# Regenerate skills-lock.json from SKILLS.txt without installing
# (requires ~/.agents/.skill-lock.json, created by the first global install)
make skills-lock

# Force a reinstall of everything in the lock
make skills-refresh
```

To add skills: edit `SKILLS.txt`, run `make skills-install`, and commit both files. Install-all repos (no selection) need a one-time bootstrap before they appear in the lock: `bunx skills add owner/repo --global --yes --skill '*'` (the `make skills-lock` warning prints the exact command), then `make skills-lock`. To remove: delete from `SKILLS.txt`, run `bunx skills remove <name> --global --yes`, then `make skills-lock`.

Installs track each source's default branch: the skills CLI does not record commit SHAs in its lock yet, so entries are not pinned to a commit.
