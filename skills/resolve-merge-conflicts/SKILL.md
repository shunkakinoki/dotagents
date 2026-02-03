---
name: resolve-merge-conflicts
allowed-tools: Read, Bash, Write, Glob, Grep, TodoWrite
description: Fix all merge conflicts non-interactively and make the repo buildable and tested
---

# /resolve-merge-conflicts — Automated merge conflict resolution

Fix all merge conflicts on the current Git branch non-interactively and make the repo buildable and tested.

## Prerequisites

- Operate from the repository root. If not in a Git repo, stop and report.
- Do not ask the user for input. Choose sensible defaults and explain decisions in a brief summary.
- Prefer minimal, correct changes that preserve both sides' intent when possible.
- Use non-interactive flags for any tools you invoke.
- Do not push or tag; only commit locally.

## Workflow

### 1. Detect conflicts

```bash
git status --porcelain | cat
```

Collect files with conflict markers (`U` statuses or files containing `<<<<<<<` / `=======` / `>>>>>>>`).

### 2. Resolve conflicts per file

Open each conflicting file and remove conflict markers. Merge both sides logically when feasible. If mutually exclusive, pick the variant that:

- Compiles and passes type checks, and
- Preserves existing public APIs and behavior.

#### Language-aware strategy

| File type | Strategy |
|-----------|----------|
| `package.json` / `pnpm-lock.yaml` / `yarn.lock` | Merge keys conservatively; run install to regenerate lockfiles |
| `.lock` files (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`) | Prefer regenerating via the package manager rather than manual edits |
| Generated files and build artifacts | Prefer keeping them out of version control if applicable; otherwise prefer current branch (ours) |
| Config files | Preserve union of safe settings; avoid deleting required fields |
| Text / Markdown | Include both unique content, deduplicate headings |
| Binary files | Prefer current branch (ours) unless project docs indicate otherwise |

### 3. Validate

- **Node/TypeScript/JS**: Install deps if manifests changed (use `--frozen-lockfile false` equivalents), then run lint/typecheck/build/tests if available.
- **Other ecosystems** (Python, Go, etc.): Run their standard build/tests when available.

### 4. Finalize

- Stage all resolved files and any regenerated lockfiles.
- Create a single commit with message: `chore: resolve merge conflicts`.
- Output a concise summary of files touched and notable resolution choices.

## Resolution guidance

- Assume the user is not available; make best-effort decisions.
- If a resolution is ambiguous and blocks build/tests, prefer the variant that compiles and green-tests.
- If a file still contains conflict markers after the first pass, revisit and resolve them before proceeding.
- For large refactors causing conflicts, prefer keeping consistent imports, types, and module boundaries.
- Use exhaustive switch guards in TypeScript and explicit type annotations where needed.
- Keep edits minimal and readable; avoid reformatting unrelated code.

## Deliverables

- A clean working tree with all conflicts resolved.
- Successful build/tests where applicable.
- One local commit containing the resolutions.
