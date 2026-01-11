---
name: commit-lint
description: Validate commit messages against conventional commit format
---

# /commit-lint — Commit message validation

Ensure commits follow conventional commit format and pass quality checks.

## Commit Format

```
<type>[scope]: <description>

[body]

[footer]
```

## Commit Types

| Type | Purpose |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation |
| `style` | Formatting (no code change) |
| `refactor` | Code restructuring |
| `test` | Adding/fixing tests |
| `chore` | Build/tooling changes |
| `perf` | Performance improvement |
| `ci` | CI configuration |
| `build` | Build system changes |
| `revert` | Revert previous commit |

## Pre-commit Checks

Auto-detected based on lock files (bun/pnpm/yarn/npm):

```bash
$PM run format   # Biome formatting
$PM run lint     # Linting checks
$PM run check    # Quality verification
```

## Hook Detection

| File | System |
|------|--------|
| `lefthook.yml` | lefthook (automatic) |
| `.pre-commit-config.yaml` | pre-commit (automatic) |
| Neither | Manual validation |

## Examples

```bash
feat: add user authentication
fix(auth): resolve login validation error
docs: update API documentation
feat!: change API interface

BREAKING CHANGE: Method now requires email parameter
```

## Guidelines

- Keep header under 72 characters
- Use present tense: "Add" not "Added"
- Solo-authored commits only (no co-authorship)
- AI attribution goes in PR description, not commits
