---
name: improve-dispatch
allowed-tools: Read, Bash, Grep, Glob
description: Planner routine for a frontier model (Fable/Sol). Survey the repo with the official improve skill or a narrow maintenance routine, then file each resulting plan as a GitHub issue that executor agents can claim. Read-only on source code; never implements.
---

# /improve-dispatch - Plan work, file it as claimable issues

Run by the planner lane (frontier model, scheduled once per repo per day).
Output is GitHub issues, not code. Executors (`/plan-executor`) pick them up.

## Routine lanes

Pick ONE lane per run (rotate daily or as scheduled):

| Lane | Skill | Label |
|------|-------|-------|
| architecture / roadmap | official `improve` (shadcn, via skills.sh) | `agent:plan` |
| duplicate abstractions | `/dup-unifier` scan phase only | `agent:plan` + `refactor` |
| dead code | `/dead-code-remover` scan phase only | `agent:plan` + `refactor` |
| leaky abstractions | `/abstraction-police` scan phase only | `agent:plan` + `refactor` |

For the maintenance lanes, run only the scan/rank step of the routine and
stop before implementation - the executor runs the fix step.

## Dedupe before filing

```bash
gh issue list --label agent:plan --state open --json title,body
```

Skip any candidate already covered by an open issue or an open agent PR.
Never file more than 3 issues per run per repo.

## Issue format

Every issue must be executable by a model with zero context from this session:

- Title: imperative, specific (`Unify duplicated retry helper into packages/core`)
- Body: the plan - files with line refs, the change, verification commands,
  acceptance criteria, PR conventions (branch name, labels, size cap)
- Labels: `agent:plan` + lane label
- Do not assign anyone; unassigned means unclaimed

## Hard rules

- Read-only: no edits, no commits, no branches. Issues are the only output.
- Every plan self-contained; a plan referencing "the survey above" is broken.
- If a lane's scan finds nothing worth filing, say so and exit; do not
  manufacture work.
