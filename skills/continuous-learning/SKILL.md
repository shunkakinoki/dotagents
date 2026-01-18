---
name: continuous-learning
allowed-tools: Read, Write, Glob, Grep, Bash, TodoWrite
description: Extract and persist reusable knowledge from debugging sessions into the skills repository
---

# /continuous-learning — Extract debugging knowledge

Persist non-obvious solutions discovered during tasks as new skills in the skills repository.

## When to Use

| Trigger | Example |
|---------|---------|
| Solved obscure bug after hours of debugging | Finally fixed that race condition no Stack Overflow mentioned |
| Found undocumented API behavior | Discovered retry logic needed for flaky endpoint |
| Created reusable workflow | Built a deployment pipeline others could use |
| Discovered tool gotcha | Learned bun handles imports differently than node |
| Session ending with valuable insight | About to close terminal with hard-won knowledge |

## Before Creating

Check if skill already exists:

```bash
ls ~/dotfiles/dotagents/skills/
```

If a similar skill exists, consider updating it instead of creating a new one.

## Quick Workflow

```bash
# 1. Check skill doesn't already exist
ls ~/dotfiles/dotagents/skills/ | grep -i <skill-name> && echo "Skill exists!" && exit 1

# 2. Create skill directory
cd ~/dotfiles/dotagents
git checkout main && git pull origin main
mkdir -p skills/<skill-name>

# 3. Write SKILL.md
cat > skills/<skill-name>/SKILL.md << 'SKILL'
---
name: <skill-name>
allowed-tools: Read, Write, Bash, TodoWrite
description: <one-line description with specific trigger words>
---

# /<skill-name> — <Short title>

<Brief description of what this skill does>

## When to Use

| Trigger | Example |
|---------|---------|
| <condition> | <example> |

## Quick Workflow

```bash
# Key commands or steps
```

## Guidelines

- Key point 1
- Key point 2
SKILL

# 4. Commit, create PR, and return to main
git checkout -b feat/<skill-name>-skill
git add skills/<skill-name>
git commit -m "feat: add <skill-name> skill"
git push -u origin feat/<skill-name>-skill
gh pr create --title "feat: add <skill-name> skill" --body "Add skill for..."
git checkout main
```

## Extraction Criteria

Ask before extracting:

1. **Exists?** — Check if skill already exists in the repository
2. **Discovered?** — Not just read from documentation
3. **Reusable?** — Helps in future similar situations
4. **Non-trivial?** — Would take time to rediscover
5. **Verifiable?** — Has clear verification steps

Extract only if skill doesn't exist and **all four criteria** are yes.

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

- **Duplicate skills** — Check existing skills first
- **Documentation lookups** — Just reading official docs
- **Trivial fixes** — Typos, missing imports
- **Unverified** — Hasn't been confirmed to work

## Guidelines

- Check existing skills before creating new ones
- One skill per directory with SKILL.md
- Match format of existing skills (pr-create, changesets, etc.)
- Create PR and checkout back to main
- Run `/continuous-learning` after solving complex problems
