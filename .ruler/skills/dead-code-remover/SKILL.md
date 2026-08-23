---
name: dead-code-remover
allowed-tools: Read, Bash, Edit, Write, Grep, Glob
description: Remove statically unreachable code immediately, and instrument suspected-but-unproven dead code with probe logging so a later run can confirm and remove it. Narrow mechanical maintenance routine intended to run on a schedule.
---

# /dead-code-remover - Remove dead code, probe suspected dead code

Two lanes each run: (1) delete code that is provably unreachable, (2) plant
probes on code that looks dead but cannot be proven dead statically, and
harvest probes planted by earlier runs.

## Official skills (skills.sh)

- `tech-debt` (anthropics/knowledge-work-plugins): debt triage framing
- `refactor` (github/awesome-copilot): safe mechanical refactor procedure

## Lane 1: provably dead - delete now

Static signals, by ecosystem:

```bash
bunx knip                 # JS/TS: unused files, exports, deps
cargo machete             # Rust: unused deps
```

Plus: exports with zero imports (`rg` the symbol), branches behind
always-false flags, code behind removed feature flags, unreferenced assets.

Provable means: no dynamic dispatch, no reflection, no string-keyed lookup,
not a public API of a published package, not referenced from config,
templates, or CI. If any of those apply, it goes to Lane 2.

Delete it, then verify: build, typecheck, full test suite. One theme per PR
(e.g. "remove unused exports in packages/x"), max ~400 deleted lines.

## Lane 2: suspected dead - probe, then harvest

For code that looks dead but is only provably-unused at runtime:

1. Plant a probe at the entry point with a greppable marker:

```ts
// DEADCODE-PROBE 2026-08-23 remove-after 2026-08-30
console.warn("[deadcode-probe] <symbol> reached");
```

Use the codebase's existing logger if one exists. Probes ship in their own
PR labeled `agent:probe`.

2. On every run, harvest expired probes:

```bash
rg -n "DEADCODE-PROBE" --no-heading
```

For each probe past its `remove-after` date, check the log store (or Sentry
breadcrumbs, or grep production logs if accessible) for the probe message.

- Never fired: delete the probe and the code it guards, in a normal Lane 1 PR.
- Fired: delete the probe only, and record the symbol under "Confirmed alive"
  below so no future run re-probes it.

## Hard rules

- Never delete: public API of published packages, migration code, error
  handlers for rare-but-real paths, platform-conditional code for platforms
  still supported.
- Deleting a file also means deleting its tests, mocks, stories, and exports.
  Leftover references fail the verify step.
- Probe windows are 7 days minimum. Do not remove a probe early.

## PR conventions

- Branch: `chore/dead-code-<slug>`
- Commit: `chore: remove dead <thing>` / `chore: probe suspected dead <thing>`
- Labels: `refactor` + `agent:mechanical` (removals), `agent:probe` (probes)
- PR body: evidence per deletion (tool output or zero-reference proof; for
  harvested probes, the probe date range checked and where logs were checked).

## Tuning

This file is the routine. When a PR is rejected or a deletion gets reverted,
add the case below and tighten the rules.

Confirmed alive (never re-probe):

- (none yet)
