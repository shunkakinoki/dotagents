---
name: goal-driven-parallel-agents
allowed-tools: Task, TodoWrite
description: Turn complex work into a goal-first plan with parallel agents and synthesized results
---

# Goal-driven parallel agents

Use this skill when a task is large, exploratory, creative, or multi-part enough that independent agents can make it better or faster. Do not use it for tiny edits, direct questions, or work that is mostly sequential.

## Core Workflow

1. Rewrite the request as a concrete parent goal.
2. Create that goal with the available goal mechanism (`/goal`, `create_goal`, or equivalent).
3. Split the work into independent workstreams that can run concurrently.
4. Spawn agents in parallel, giving each agent a dedicated sub-goal and output contract.
5. Synthesize returned results as they arrive.
6. Integrate the chosen result, verify it, and close the parent goal.

## Parent Goal Template

```text
Goal: Deliver [artifact/outcome] that satisfies [user intent] and [quality bar].

Constraints:
- [Required format, stack, files, deadline, or environment]
- [Non-goals and boundaries]

Definition of done:
- [Observable completed behavior or artifact]
- [Verification command, review step, screenshot, or source check]
- [Risks resolved or explicitly documented]
```

## Parallelization Rules

Parallelize work that can be evaluated independently:

- Research current facts, examples, libraries, APIs, or prior art.
- Explore alternative designs or implementation approaches.
- Inspect separate modules, files, or failure surfaces.
- Draft assets, tests, documentation, or review notes while implementation proceeds.
- Perform final review or verification after an implementation candidate exists.

Keep work in the parent thread when it is tightly coupled:

- One agent must make a single small code edit.
- Steps depend on a previous result.
- Multiple agents would write the same file or compete for the same decision.
- The task is too small for delegation overhead to pay off.

## Agent Sub-goal Template

Give every spawned agent a self-contained goal:

```text
You have a dedicated sub-goal for the parent goal: [parent goal summary].

Sub-goal: [specific independent outcome].

Scope:
- Inputs: [files, screenshots, links, constraints, user requirements]
- Boundaries: [what not to edit, assume, or decide]
- Coordination: [whether to read-only inspect, propose, or implement assigned files]

Return:
- Recommendation or result
- Evidence used
- Files touched, if any
- Risks, tradeoffs, or follow-up checks
```

## Synthesis Rules

- Treat agents as advisors or implementers, not final decision makers.
- Compare returned results against the parent goal and user constraints.
- Resolve contradictions explicitly.
- Prefer the simplest result that meets the definition of done.
- Keep one integrated final answer or change set, even when many agents contributed.

## Completion Checklist

- Parent goal exists and captures the real outcome.
- Parallel agents each had a dedicated sub-goal.
- Results were synthesized into one coherent direction.
- Verification was run or the gap was disclosed.
- Goal status was updated only when genuinely complete or blocked.
