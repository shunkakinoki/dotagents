---
name: issue-create
description: Create Linear issues with proper assignment and labeling
---

# /issue-create — Create Linear issues

Create Linear issues with proper assignment and labeling.

## Default Assignment

Assign all issues to `shunkakinoki`.

## Labels

| Category | Labels |
|----------|--------|
| Primary | Bug, Enhancement, Documentation |
| Status | Duplicate, Invalid, Wontfix, Question |
| Automation | Dependencies, Dependabot, Renovate, Automerge |
| Other | Good First Issue, Help Wanted |

## Issue Structure

```markdown
## Problem
[User-facing impact or goal]

## Acceptance Criteria
- [ ] Condition 1
- [ ] Condition 2

## Technical Notes
[Implementation hints, specs, affected services]

## Testing
[Validation steps]
```

## Guidelines

- Apply one primary label (Bug/Enhancement/Documentation)
- Cross-link related GitHub issues/PRs
- Close only after verifying acceptance criteria
