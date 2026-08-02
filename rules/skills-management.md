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

# 3. Install (regenerates skills-lock.json from SKILLS.txt automatically)
cd dotagents && make skills-install

# Install-all repos (no selection) need a one-time bootstrap to enter the lock:
# bunx skills add owner/repo --global --yes --skill '*'

# 4. Commit SKILLS.txt and skills-lock.json together
```

## Removing Skills

```bash
# 1. Remove from SKILLS.txt, then:
bunx skills remove <name> --global --yes
cd dotagents && make skills-lock
```

## Updating Installed Skills

```bash
cd dotagents && make skills-update
```

Runs `bun x skills update --global` and refreshes `skills-lock.json`; commit
the resulting diff.

## Restoring (fresh machine or CI)

```bash
cd dotagents && make skills-install
```

- Idempotent: skips skills already present in `~/.agents/skills`
- `make skills-refresh` reinstalls everything
- `make sync` runs `make skills-install` automatically
- Installs track each source's default branch; the skills CLI does not record
  commit SHAs in its lock yet, so entries are not pinned to a commit
