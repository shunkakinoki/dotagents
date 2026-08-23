---
name: dup-unifier
allowed-tools: Read, Bash, Edit, Write, Grep, Glob
description: Scan the codebase for similar-yet-slightly-divergent abstractions and put up small PRs that unify them. Narrow mechanical maintenance routine intended to run on a schedule.
---

# /dup-unifier - Unify divergent duplicate abstractions

Find pairs or clusters of code that started as the same idea and drifted apart
(copy-pasted helpers, parallel components, re-implemented utilities), then
unify each cluster in its own small PR.

## Scan

Run in order, cheapest first:

```bash
bunx jscpd --min-tokens 50 --reporters json --output .tmp/jscpd .
```

- `jscpd` catches literal near-duplicates
- `ast-grep` catches structural duplicates that differ in identifiers:
  scan for repeated shapes (same function skeleton, same hook pattern,
  same error-handling wrapper) across files
- Grep for naming smells: `*Util`, `*Helper`, `format*`, `parse*`, `is*`,
  `get*` defined in more than one module with near-identical bodies

Rank candidates by: (uses x divergence risk) descending. Skip vendored code,
generated files, tests that intentionally duplicate fixtures, and anything in
`.gitignore`d paths.

## Unify

One cluster per PR. For the top candidate:

1. Pick the canonical location (most imported, or the shared package if one
   exists). Do not invent a new `utils/` dumping ground for a single pair.
2. Merge the variants: the union of behavior only if every difference is
   intentional; otherwise prefer the newest/most-tested variant and note the
   dropped behavior in the PR body.
3. Point all call sites at the canonical version. Delete the copies.
4. Verify: typecheck, lint, and the test suites of every touched package.

## Hard rules

- Behavior-preserving only. If unification would change observable behavior,
  stop and open an issue instead of a PR.
- Max ~300 changed lines per PR. Bigger clusters get split across days.
- Never unify two things that merely look alike but serve different domains
  (false-positive duplication). When in doubt, skip and record why below.
- No new abstraction layers. Unifying two functions must not produce a
  factory, base class, or config object.

## PR conventions

- Branch: `chore/dup-unify-<slug>`
- Commit: `refactor: unify duplicated <thing> into <location>`
- Label: `refactor` + `agent:mechanical`
- PR body: the cluster (file:line for each copy), the chosen canonical
  location and why, and any dropped divergence.

## Tuning

This file is the routine. When a PR from this routine is rejected, add the
reason to the list below and adjust the rules so it does not recur.

Known false positives (do not attempt again):

- (none yet)
