---
name: remove-ai-slop
allowed-tools: Read, Bash, Glob, Grep, Edit, TodoWrite
description: Remove AI-generated slop from the current branch's diff against main
---

# /remove-ai-slop — Remove AI code slop

Check the diff against main, and remove all AI generated slop introduced in this branch.

## Workflow

```bash
# 1. Get the diff of changed files against main
git diff main --name-only

# 2. For each changed file, review the diff
git diff main -- <file>

# 3. Edit files to remove slop, then verify
git diff main -- <file>
```

## What to remove

- **Unnecessary comments** — Comments that over-explain obvious code, restate what the code already says, or are inconsistent with the commenting style in the rest of the file
- **Defensive overkill** — Extra `try/catch` blocks, null checks, or validation that is abnormal for that area of the codebase, especially when called by trusted or already-validated codepaths
- **Type hacks** — Casts to `any` (or equivalent) added to work around type issues instead of fixing the actual types
- **Style inconsistencies** — Any patterns, naming, formatting, or conventions that don't match the rest of the file

## How to judge

Before editing a file, read the full file to understand its existing style. Only remove things that are clearly inconsistent with how the rest of the file (or codebase) is written. If the whole file was AI-generated, use surrounding files as the style reference.

## Output

Report at the end with only a 1-3 sentence summary of what you changed.
