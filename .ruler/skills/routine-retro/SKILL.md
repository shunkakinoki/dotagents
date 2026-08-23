---
name: routine-retro
allowed-tools: Read, Bash, Edit, Write, Grep, Glob
description: Weekly tuning loop for the agent maintenance pipeline. Compare merged vs rejected agent PRs, diagnose why rejects were rejected, and open a PR against the routine skills themselves so the pipeline improves next week.
---

# /routine-retro - Tune the routines from PR outcomes

The routines (`improve-dispatch`, `plan-executor`, `dup-unifier`,
`dead-code-remover`, `abstraction-police`) are versioned files in
`dotagents/.ruler/skills/`. This routine edits them based on evidence.

## Gather (per repo, last 7 days)

```bash
gh pr list --label agent:mechanical --state merged --json number,title,labels
gh pr list --label agent:mechanical --state closed --search "-is:merged" --json number,title,labels,comments
gh issue list --label agent:plan-stale --state all --json number,title,comments
```

## Diagnose

For each closed-unmerged PR and each stale plan, answer:

1. Which routine produced it (lane label)?
2. Why did it fail - false positive scan, plan not self-contained, size cap
   blown, behavior change, reviewer taste?
3. Which rule or pattern in that routine's SKILL.md would have prevented it?

Read review comments; the reviewer's stated reason outranks your inference.

## Tune

Open ONE PR against dotagents that:

- Appends concrete cases to the affected routines' Tuning sections
  (known false positives / confirmed alive / intentional leaks)
- Tightens scan patterns or hard rules where a failure class repeats
- Reports the week's numbers in the PR body: filed / claimed / merged /
  rejected per lane

## Hard rules

- Evidence only: every tuning change cites the PR or issue number that
  motivated it.
- Never loosen a hard rule (size caps, behavior preservation, one-per-PR)
  to raise merge rate; only tighten or clarify.
- If a lane merged nothing for 2 consecutive weeks, propose pausing that
  lane in the PR body rather than silently continuing.
