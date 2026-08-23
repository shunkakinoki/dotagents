# Orchestration

Agent maintenance pipeline: planner -> issue queue -> executors -> review -> retro.
Routine skills live inline in `dotagents/.ruler/skills/`; official skills are
referenced from skills.sh via `SKILLS.txt`.

## Roles and models

| Role | Model | Skill | Cadence |
|------|-------|-------|---------|
| Planner | Fable/Sol (frontier) | `/improve-dispatch` | daily per repo, one lane |
| Executor | Opus/Sonnet/Luna (max) | `/plan-executor` | on wake, herdr panels |
| Retro | Fable/Sol | `/routine-retro` | weekly |

Wake-ups come from each machine's hermes/openclaw schedule; herdr hosts the
executor panels. Planning is centralized (one planner run per repo per day);
execution is distributed (any machine may claim).

## Queue conventions

- GitHub issues are the queue. `agent:plan` = open work; unassigned = unclaimed.
- Claim = self-assign (atomic, cross-machine dedupe). One issue, one PR, one run.
- PRs: `Closes #<n>`, lane label + `agent:mechanical`, conventional commit title.
- Broken plans get `agent:plan-stale` + a comment, never improvisation.

## Maintenance lanes

`/dup-unifier`, `/dead-code-remover`, `/abstraction-police` - narrow,
mechanical, behavior-preserving, size-capped. Planner runs their scan phase;
executors run their fix phase.

## Invariants

- Routines are versioned skills; tuning happens by PR against the skill file
  (`/routine-retro`), driven by review outcomes, evidence-cited.
- Humans merge. Agents never merge their own PRs or push to default branches.
- No manufactured work: empty scan or empty queue means exit, not invention.
