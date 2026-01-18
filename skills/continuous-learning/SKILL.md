---
name: continuous-learning
allowed-tools: Read, Write, Glob, Grep, Bash, TodoWrite
description: Extract and persist reusable knowledge from debugging sessions into skill files
---

# /continuous-learning — Extract debugging knowledge

Persist non-obvious solutions discovered during tasks as reusable skill files.

## Quick Workflow

```bash
# 1. Create skill directory
mkdir -p .claude/skills

# 2. Write skill file
cat > .claude/skills/my-discovery.md << 'SKILL'
---
name: my-discovery
description: Fix for XYZ error when ABC happens
triggers:
  - "exact error message here"
verified: 2025-01-18
---

# Problem
<What went wrong>

# Solution
<Step-by-step fix>

# Verification
<How to confirm it worked>
SKILL
```

## When to Extract

| Trigger | Example |
|---------|---------|
| Non-obvious solution | Required investigation beyond docs |
| Misleading error | Error didn't point to root cause |
| Project-specific pattern | Workaround unique to codebase |
| Tool integration quirk | Undocumented behavior |

## Extraction Criteria

Ask before extracting:

1. **Discovered?** — Not just read from documentation
2. **Reusable?** — Helps in future similar situations
3. **Non-trivial?** — Would take time to rediscover
4. **Verifiable?** — Has clear verification steps

Extract only if **all four** are yes.

## Storage Locations

| Scope | Path |
|-------|------|
| Project | `.claude/skills/<name>.md` |
| User | `~/.claude/skills/<name>.md` |

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

- One skill per file, focused on single problem
- Include exact error messages in triggers
- Date your verification
- Run `/continuous-learning` after solving complex problems
