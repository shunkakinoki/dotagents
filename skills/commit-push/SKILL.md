---
name: commit-push
description: Commit and push workflow
---

# /commit-push — Commit and push workflow

Stage, commit with conventional format, and push with upstream tracking.

## Quick Workflow

```bash
git add .
git commit -m "feat: add new feature"
git push -u origin <branch>   # First push
git push                      # Subsequent pushes
```

## Commit Types

| Type | Purpose |
|------|---------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `docs:` | Documentation |
| `refactor:` | Code restructuring |
| `chore:` | Build/tooling |
| `perf:` | Performance |
| `test:` | Tests |

## Pre-commit (auto-detected package manager)

```bash
$PM run format && $PM run lint && $PM run check
```

## Examples

```bash
# Feature
feat: add user authentication

# Bug fix with scope
fix(auth): resolve login error

# Breaking change
feat!: change API interface

BREAKING CHANGE: Method requires email parameter
```

## Troubleshooting

```bash
git commit --amend -m "new message"  # Fix last commit
git reset --soft HEAD~1              # Undo commit, keep changes
```

## Guidelines

- Atomic commits (one logical change)
- Present tense: "Add" not "Added"
- Under 72 characters
- No co-authorship in commits
- Reference issues: `Closes #123`
