---
name: continuous-learning
allowed-tools: Read, Write, Glob, Grep, Bash, TodoWrite
description: Extract and persist reusable knowledge from debugging sessions into the skills repository
---

# /continuous-learning — Extract debugging knowledge

Persist non-obvious solutions discovered during tasks as new skills in the skills repository.

## Quick Workflow

```bash
# 1. Create skill directory in dotagents repo
mkdir -p ~/dotfiles/dotagents/skills/<skill-name>

# 2. Write SKILL.md
cat > ~/dotfiles/dotagents/skills/<skill-name>/SKILL.md << 'SKILL'
---
name: <skill-name>
allowed-tools: Read, Write, Bash, TodoWrite
description: <one-line description with specific trigger words>
---

# /<skill-name> — <Short title>

<Brief description of what this skill does>

## Quick Workflow

```bash
# Key commands or steps
```

## When to Use

| Trigger | Example |
|---------|---------|
| <condition> | <example> |

## Guidelines

- Key point 1
- Key point 2
SKILL

# 3. Commit and create PR
cd ~/dotfiles/dotagents
git checkout -b feat/<skill-name>-skill
git add skills/<skill-name>
git commit -m "feat: add <skill-name> skill"
git push -u origin feat/<skill-name>-skill
gh pr create --title "feat: add <skill-name> skill" --body "Add skill for..."
```

## When to Extract

| Trigger | Example |
|---------|---------|
| Non-obvious solution | Required investigation beyond docs |
| Misleading error | Error didn't point to root cause |
| Reusable pattern | Workflow applicable across projects |
| Tool integration quirk | Undocumented behavior |

## Extraction Criteria

Ask before extracting:

1. **Discovered?** — Not just read from documentation
2. **Reusable?** — Helps in future similar situations
3. **Non-trivial?** — Would take time to rediscover
4. **Verifiable?** — Has clear verification steps

Extract only if **all four** are yes.

## Skill Format Requirements

Match existing skills in `~/dotfiles/dotagents/skills/`:

```yaml
---
name: kebab-case-name
allowed-tools: Read, Write, Bash, TodoWrite  # tools the skill needs
description: One-line description with specific keywords
---
```

## Description Best Practices

| Bad | Good |
|-----|------|
| "Database issues" | "Fix PrismaClientKnownRequestError in serverless" |
| "Build problems" | "Resolve vite circular dependency with barrel files" |

## Anti-Patterns

- **Documentation lookups** — Just reading official docs
- **Trivial fixes** — Typos, missing imports
- **Unverified** — Hasn't been confirmed to work

## Guidelines

- One skill per directory with SKILL.md
- Match format of existing skills (pr-create, changesets, etc.)
- Create PR to add skill to repository
- Run `/continuous-learning` after solving complex problems
