# Skills Management

External skills are declared in `dotagents/SKILLS.txt` (canonical) and locked
in `dotagents/skills-lock.json` (generated, committed). Skills install globally
via the skills CLI (https://github.com/vercel-labs/skills/issues/549).

## SKILLS.txt Format

```
repo                              <- install all skills
repo skill1,skill2,skill3         <- install selected (comma-separated)
```

## Adding Skills

```bash
# 1. List available skills in a repo
bunx skills add owner/repo --global --list

# 2. Add the repo (and selection) to dotagents/SKILLS.txt
# Repos with <10 skills: install all (no selection)
# Repos with 10+ skills: always specify selections

# 3. Regenerate the lock, install, then re-lock to capture resolved metadata
cd dotagents && bun run skills:lock && bun run skills:install && bun run skills:lock

# 4. Commit SKILLS.txt and skills-lock.json together
```

## Removing Skills

```bash
# 1. Remove from SKILLS.txt, then:
bunx skills remove <name> --global --yes
cd dotagents && bun run skills:lock
```

## Restoring (fresh machine or CI)

```bash
cd dotagents && bun run skills:install
```

- Idempotent: skips skills already present in `~/.agents/skills`
- `--force` reinstalls everything
- `make sync` runs it automatically
