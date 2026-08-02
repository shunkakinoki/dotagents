# Skills Management

External skills are declared in `dotagents/SKILLS.txt` (canonical) and locked
in `dotagents/skills-lock.json` (generated, committed). Skills install globally
via the [skills CLI](https://github.com/vercel-labs/skills). The CLI installs
per project only, so this repository scripts the global install
(see https://github.com/vercel-labs/skills/issues/549).

## SKILLS.txt Format

```text
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
cd dotagents && make skills-lock && make skills-install && make skills-lock

# 4. Commit SKILLS.txt and skills-lock.json together
```

## Removing Skills

```bash
# 1. Remove from SKILLS.txt, then:
bunx skills remove <name> --global --yes
cd dotagents && make skills-lock
```

## Restoring (fresh machine or CI)

```bash
cd dotagents && make skills-install
```

- Idempotent: skips skills already present in `~/.agents/skills`
- `make skills-refresh` reinstalls everything
- `make sync` runs `make skills-install` automatically
- Installs track each source's default branch; the skills CLI does not record
  commit SHAs in its lock yet, so entries are not pinned to a commit
