---
name: abstraction-police
allowed-tools: Read, Bash, Edit, Write, Grep, Glob
description: Find leaky abstractions - internals escaping through interfaces, callers reaching around APIs, boundaries that force callers to know implementation details - and fix one leak per PR. Narrow mechanical maintenance routine intended to run on a schedule.
---

# /abstraction-police - Fix leaky abstractions

A leak is when a caller must know how something works to use it. Find leaks,
fix the boundary, one leak per PR.

## Official skills (skills.sh)

- `api-and-interface-design` (addyosmani/agent-skills): interface design rules
- `refactor` (github/awesome-copilot): safe mechanical refactor procedure

## Leak patterns to scan for

- **Reach-around**: callers importing from `foo/internal/*`, `foo/lib/*`, or
  deep paths when `foo` has an index/public surface.
  `rg "from ['\"].*/(internal|lib|dist)/" --type ts`
- **Type leakage**: public function signatures exposing internal types (ORM
  entities, raw API response shapes, third-party client types) instead of
  domain types.
- **Config leakage**: callers passing implementation-specific options through
  a supposedly generic interface (`{ redisTtl }` on a generic cache).
- **Error leakage**: raw driver/library errors crossing a boundary uncaught,
  forcing callers to catch `PrismaClientKnownRequestError` and friends.
- **Sibling knowledge**: module A grepping/parsing module B's files, env
  vars, or storage format instead of calling B.
- **Boolean/mode flags** that make one function behave as two
  (`doThing(x, true, false)`), forcing callers to know internal branches.

Rank by blast radius: leaks on boundaries with the most callers first.

## Fix

For the top leak:

1. Define the honest interface: what callers actually need, in domain terms.
2. Fix the boundary - wrap the internal type, translate the error, narrow
   the config, export the missing public function.
3. Migrate every call site. A fix that leaves both the leak and the new path
   alive is worse than no fix; finish the migration or split it across
   sequential PRs with the leak marked deprecated in the first.
4. Enforce where cheap: an eslint `no-restricted-imports` rule, an
   `@internal` tag, or a lint on the deep-import pattern, so the leak cannot
   silently return.
5. Verify: typecheck, lint, tests of every touched package.

## Hard rules

- Behavior-preserving. Error translation must preserve information (cause
  chaining), not swallow it.
- No speculative interfaces. Fix the leak that exists; do not design for
  hypothetical future backends.
- If the "leak" is load-bearing (perf escape hatch, intentional low-level
  API), skip it and record it below.
- Max one boundary per PR, ~300 changed lines. Large migrations become a
  deprecation PR followed by call-site PRs on later runs.

## PR conventions

- Branch: `chore/abstraction-<slug>`
- Commit: `refactor: seal <boundary> leak (<pattern>)`
- Labels: `refactor` + `agent:mechanical`
- PR body: the leak pattern, list of offending call sites, the new
  interface, and the enforcement added.

## Tuning

This file is the routine. When a PR is rejected, record the case below and
adjust the patterns or hard rules.

Intentional leaks (do not touch):

- (none yet)
