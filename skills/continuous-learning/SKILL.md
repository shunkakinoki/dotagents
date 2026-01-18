---
name: continuous-learning
allowed-tools: Read, Write, Glob, Grep, Bash, TodoWrite
description: Extract and persist reusable knowledge from debugging sessions into skill files
---

# /continuous-learning — Extract debugging knowledge into skills

Autonomously identify non-obvious solutions discovered during tasks and persist them as reusable skill files for future sessions.

## When to Extract

Extract knowledge when you encounter:

| Trigger | Example |
|---------|---------|
| Non-obvious solution | Debugging required investigation beyond docs |
| Misleading error | Error message didn't point to root cause |
| Project-specific pattern | Workaround unique to this codebase |
| Tool integration quirk | Behavior not documented in official docs |
| Performance discovery | Optimization found through profiling |

## Extraction Decision

Ask yourself:

1. **Did I discover this?** — Not just read it from documentation
2. **Is it reusable?** — Will this help in future similar situations
3. **Is it non-trivial?** — Would take time to rediscover
4. **Can I verify it?** — Solution has clear verification steps

If **all four** are yes, extract the knowledge.

## Skill File Format

```markdown
---
name: <kebab-case-name>
description: <one-line description with specific trigger words>
triggers:
  - "<exact error message or symptom>"
  - "<another trigger condition>"
verified: <date>
---

# Problem

<What went wrong and why it's non-obvious>

# Solution

<Step-by-step fix with code examples>

# Verification

<How to confirm the fix worked>

# Context

- **Environment**: <OS, runtime, versions>
- **Discovery**: <How this was found>
- **Caveats**: <Edge cases or limitations>
```

## Storage Locations

| Scope | Path | Use Case |
|-------|------|----------|
| Project | `.claude/skills/<name>.md` | Project-specific patterns |
| User | `~/.claude/skills/<name>.md` | Cross-project knowledge |

## Quick Extraction Flow

```bash
# 1. Create skill directory if needed
mkdir -p .claude/skills

# 2. Write skill file
cat > .claude/skills/my-discovery.md << 'EOF'
---
name: my-discovery
description: Fix for XYZ error when ABC happens
triggers:
  - "exact error message here"
verified: 2025-01-18
---

# Problem
...
EOF
```

## Description Best Practices

Write descriptions for semantic matching:

| Bad | Good |
|-----|------|
| "Database issues" | "Fix PrismaClientKnownRequestError in serverless" |
| "Build problems" | "Resolve vite circular dependency with barrel files" |
| "API errors" | "Handle 429 rate limit with exponential backoff" |

## Example: Extracted Skill

```markdown
---
name: prisma-serverless-pool
description: Fix connection pool exhaustion in serverless with Prisma
triggers:
  - "P2024: Timed out fetching a new connection"
  - "too many connections for role"
verified: 2025-01-15
---

# Problem

Serverless functions spawn multiple Prisma clients, each opening 5 connections by default. Under load, this exhausts database connection limits.

# Solution

1. Use connection pooling service (PgBouncer, Prisma Accelerate)
2. Configure connection limit in URL:
   ```
   DATABASE_URL="postgresql://...?connection_limit=1"
   ```
3. Implement singleton pattern:
   ```typescript
   const globalForPrisma = globalThis as unknown as { prisma: PrismaClient }
   export const prisma = globalForPrisma.prisma ?? new PrismaClient()
   if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
   ```

# Verification

1. Load test deployment with concurrent requests
2. Monitor connection count stays within limits
3. No P2024 errors under sustained load

# Context

- **Environment**: Node.js 18+, Prisma 5.x, Vercel/AWS Lambda
- **Discovery**: Production incident with connection timeouts
- **Caveats**: Singleton pattern only helps in dev; pooling required for prod
```

## Retrospective Trigger

Run `/continuous-learning` at session end or after solving complex problems. Ask:

> "Did I solve anything non-obvious that I'd want to remember?"

If yes, extract it before the session ends.

## Anti-Patterns

Avoid extracting:

- **Documentation lookups** — Just reading official docs
- **Trivial fixes** — Typos, missing imports
- **Highly specific** — Only applies to one exact scenario
- **Unverified** — Hasn't been confirmed to work

## Guidelines

- One skill per file, focused on single problem
- Include exact error messages in triggers
- Date your verification
- Update skills when they become stale
- Delete skills that no longer apply
