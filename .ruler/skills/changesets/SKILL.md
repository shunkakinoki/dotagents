---
name: changesets
allowed-tools: Read, Glob, Grep, Write, Bash, TodoWrite
description: Generate changeset entries following Changesets semantics
---

# /changesets — Generate changeset entries

Generate release documentation entries following Changesets semantics.

## Format

```markdown
---
"package-name": minor
---

Short description of user-visible change (1-2 sentences max).
```

## Level Inference

| Commit Type | Level |
|-------------|-------|
| `feat!:` or `BREAKING CHANGE` | `major` |
| `feat:` | `minor` |
| `fix:`, `docs:`, `chore:`, etc. | `patch` |

## Package Detection

- Monorepo: `packages/<name>/...` → `"<name>"`
- Single package or unknown: `"repo"`

## Examples

```markdown
---
"viem": patch
---

Added estimateOperatorFee action for OP Stack chains
```

```markdown
---
"core": major
---

Replaced legacy serializer with new wire format
```

## Guidelines

- Lead with user-visible outcome
- Avoid commit jargon and issue numbers
- Use active voice: "Adds..." not "Added..."
- Include in same commit as code changes
