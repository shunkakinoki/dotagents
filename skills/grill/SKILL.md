---
name: grill
description: Run a decision-forcing interview only when the user explicitly asks to be grilled, pressure-tested, or stress-tested.
---

# Grill

Use this skill only for an explicit request to grill, pressure-test, or stress-test a plan or design, or when the user directly invokes this skill. Complexity, ambiguity, or missing details alone never activate it.

## Interview Contract

1. Research discoverable facts in the repository, issue, docs, and code before asking the user. Ask only for judgments or facts that cannot be discovered.
2. Ask one decision-forcing question at a time. State the recommended answer and the reason briefly, then wait for the answer.
3. Prefer the host's structured input surface for bounded decisions:
   - On TBH or Codex, use `request_user_input` when it is exposed and the decision fits 2-3 short, mutually exclusive choices. Put the recommended answer first.
     Send one question per call with `id`, `header`, `question`, and `options`; omit `Other` and `None` because the client provides a free-form escape. Never set the top-level `auto_resolution_ms` in a grilling interview: a grilling decision always waits for the human answer, because auto-resolving to the recommended default is never safe when the whole point of the interview is the user's judgment.
   - On Claude Code, use `AskUserQuestion` for the same bounded choice.
   - Use plain chat only when the structured surface is unavailable or the answer needs free-form discussion.
   Never pose a bounded checkpoint as plain assistant text or as a free-form question before offering structured choices.
4. Use comparison tables only when the user explicitly requested one or the question concerns agent-product behavior, such as Claude Code versus Codex.
5. Follow dependent decisions until the skill decides the decision tree is exhausted. Never ask a final "are we done?" meta-question.
6. Summarize the settled contract: goals, non-goals, decisions, constraints, risks, validation, and unresolved items.

Ending the interview never authorizes implementation. Implement only after a separate explicit user request.
