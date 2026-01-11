---
allowed-tools: Read, Bash
description: Apply labels to PRs based on conventional commit types
---

# /pr-label — Label pull requests

Apply labels to PRs based on conventional commit types.

## Label Mapping

| Commit Type | Label |
|-------------|-------|
| `feat:` | enhancement |
| `fix:` | bug |
| `docs:` | documentation |
| `chore(deps):`, `build(deps):` | dependencies |
| Author: dependabot | dependabot |
| Author: renovate | renovate |
| Title contains `[automerge]` | automerge |

## Available Labels

**Primary**: bug, documentation, enhancement

**Status**: duplicate, invalid, wontfix, question, good first issue, help wanted

**Automation**: dependencies, dependabot, renovate, automerge, codex, refactor

## Usage

```bash
gh pr edit <number> --add-label <label>
```

## Guidelines

- Apply one primary label based on commit type prefix
- Do not add unrelated labels automatically
- Labels are provisioned via Pulumi from `labels.ts`
