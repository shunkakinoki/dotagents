

<!-- Source: .ruler/commit-push.md -->

# /commit-push — Commit and push workflow

Stage, commit with conventional format, and push with upstream tracking.

## Quick Workflow

```bash
git add .
git commit -m "feat: add new feature"
git push -u origin <branch>   # First push
git push                      # Subsequent pushes
```

## Commit Types

| Type | Purpose |
|------|---------|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `docs:` | Documentation |
| `refactor:` | Code restructuring |
| `chore:` | Build/tooling |
| `perf:` | Performance |
| `test:` | Tests |

## Pre-commit (auto-detected package manager)

```bash
$PM run format && $PM run lint && $PM run check
```

## Examples

```bash
# Feature
feat: add user authentication

# Bug fix with scope
fix(auth): resolve login error

# Breaking change
feat!: change API interface

BREAKING CHANGE: Method requires email parameter
```

## Troubleshooting

```bash
git commit --amend -m "new message"  # Fix last commit
git reset --soft HEAD~1              # Undo commit, keep changes
```

## Guidelines

- Atomic commits (one logical change)
- Present tense: "Add" not "Added"
- Under 72 characters
- No co-authorship in commits
- Reference issues: `Closes #123`



<!-- Source: .ruler/ruler-apply.md -->

# /ruler-apply — Regenerate agent instructions with Ruler

Use this command whenever `.ruler/` files or command documentation changes, or after pulling updates that touch repository rules.

## When to Run
- After editing any file under `.ruler/` (including `commands/` docs referenced from there)
- Before committing changes that rely on regenerated instruction files such as `AGENTS.md`
- After rebasing or pulling main when rules may have changed

## Command Sequence
```fish
# Regenerate agent instruction files
pnpm run ruler:apply

# Double-check that regeneration left the tree clean
pnpm run ruler:check
```

## What to Inspect
- Review `git status` for modified instruction outputs (e.g., `AGENTS.md`, `.cursor/...`).
- If files changed, skim the diff to ensure new content reflects your rule updates.
- Commit regenerated files together with the rule change so other contributors stay in sync.

## Troubleshooting
- If `pnpm run ruler:check` reports a dirty tree, run `git status --short` to see which files still differ.
- For merge conflicts in generated files, resolve them in the source `.ruler/` Markdown first, re-run `/ruler-apply`, then commit the regenerated outputs.
- When `.gitignore` changes unexpectedly, confirm `[gitignore].enabled` in `.ruler/ruler.toml` matches the desired setting before re-running the command.



<!-- Source: .ruler/shell-usage.md -->

# Shell Usage Standard (Fish)

This repository uses the Fish shell for interactive commands and automation snippets, aligned with the system configuration. Prefer Fish for new scripts and examples.

## Policy
- Default shell: Fish (`#!/usr/bin/env fish`).
- Provide Fish snippets for automation examples; keep Bash as optional fallback when helpful.
- Keep one-file, shell-agnostic command sequences unchanged when they work in both shells.

## Conventions
- Variables: `set NAME value` (no `=`). Export: `set -x NAME value`.
- Arrays/lists: `set items a b c`; append: `set items $items d`.
- Conditionals: `if test -f file; ...; end`; switches: `switch $var; case value; ...; end`.
- Substitution: `set VAR (command ...)`.
- PATH: `set -x PATH /new/bin $PATH`.

## Shebangs
- Use `#!/usr/bin/env fish` for executable scripts.

## Compatibility Notes
- Avoid `set -euo pipefail`; Fish handles errors differently. Use explicit checks or `status` as needed.
- When porting Bash snippets, verify quoting and list handling.



<!-- Source: .ruler/tool-search.md -->

# Tool Search Guidelines

This document defines the preferred tools and methodologies for searching and analyzing code within the repository. These tools are optimized for different types of search tasks and should be used according to the patterns outlined below.

## Core Search Tools

### File Discovery
- **Primary**: `fd` - Fast and user-friendly alternative to `find`
  - Search for files by name, extension, or pattern
  - Respects `.gitignore` by default
  - Examples: `fd config.json`, `fd '*.ts'`, `fd -e md`

### Text Search
- **Primary**: `rg` (ripgrep) - High-performance text search
  - Full-text search across files
  - Regular expression support
  - Context options (`-A`, `-B`, `-C` for lines after/before/around matches)
  - Examples: `rg "function.*export"`, `rg -i "todo" -A 3`

### Code Structure Analysis
- **Primary**: `ast-grep` - AST-based code search and analysis
  - **Default to TypeScript contexts** for this codebase
  - Language-specific parsing for accurate structural matches
  - Pattern-based matching using AST nodes rather than text

#### Language Mapping for ast-grep:
- **TypeScript files** (`.ts`): `ast-grep --lang ts -p '<pattern>'`
- **React/TSX files** (`.tsx`): `ast-grep --lang tsx -p '<pattern>'`
- **JavaScript files** (`.js`, `.mjs`): `ast-grep --lang javascript -p '<pattern>'`
- **Rust files** (`.rs`): `ast-grep --lang rust -p '<pattern>'`
- **Python files** (`.py`): `ast-grep --lang python -p '<pattern>'`
- **Go files** (`.go`): `ast-grep --lang go -p '<pattern>'`

#### When to Use ast-grep Over Text Search:
- Finding function definitions, class declarations, or specific code patterns
- Refactoring operations that require understanding code structure
- Type-aware searches (finding usages of specific types, interfaces, etc.)
- Complex code transformations
- Avoiding false positives from comments or strings

#### ast-grep Pattern Examples:
```bash
# Find all function declarations
ast-grep --lang ts -p 'function $NAME($ARGS) { $$$ }'

# Find React components with specific props
ast-grep --lang tsx -p '<$COMP $PROPS>$$$</$COMP>'

# Find class methods
ast-grep --lang ts -p 'class $CLASS { $METHOD($ARGS) { $$$ } }'
```

### Interactive Selection
- **Primary**: `fzf` - Fuzzy finder for interactive selection
  - Pipe search results through fzf for interactive filtering
  - Examples: `fd '*.ts' | fzf`, `rg -l "export" | fzf`

### Data Processing
- **JSON**: `jq` - Command-line JSON processor
  - Parse, filter, and transform JSON data
  - Examples: `cat package.json | jq '.dependencies'`

- **YAML/XML**: `yq` - YAML/XML processor (similar to jq)
  - Handle YAML and XML files with jq-like syntax
  - Examples: `cat config.yaml | yq '.database.host'`

## Tool Selection Decision Tree

### 1. Code Structure Search
- **Use ast-grep when:**
  - Searching for specific code patterns (functions, classes, imports)
  - Need to understand code semantics, not just text matches
  - Working with TypeScript/JavaScript code (most common in this repo)
  - Performing refactoring or code transformation tasks
  - Need to avoid false positives from comments or string literals

### 2. Plain Text Search
- **Use ripgrep (rg) when:**
  - Searching for plain text content (documentation, comments, logs)
  - Simple string matching across multiple files
  - Need contextual lines around matches
  - Working with non-code files (markdown, configuration, etc.)
  - ast-grep doesn't support the target language

### 3. File Discovery
- **Use fd when:**
  - Finding files by name patterns
  - Listing files by extension
  - Exploring directory structures
  - Building file lists for further processing

## Best Practices

### Performance Optimization
- **Combine tools efficiently**: `fd '*.ts' | xargs ast-grep --lang ts -p 'pattern'`
- **Use appropriate scoping**: Limit searches to relevant directories when possible
- **Leverage caching**: Tools like `fd` and `rg` are already optimized for speed

### Accuracy and Precision
- **Prefer structural over textual**: Use ast-grep for code analysis, rg for content search
- **Validate language detection**: Ensure ast-grep uses the correct `--lang` parameter
- **Test patterns incrementally**: Start with simple patterns and refine as needed

### Integration Workflows
```bash
# Example: Find all TypeScript files with export statements, then select interactively
fd '*.ts' | xargs ast-grep --lang ts -l -p 'export $$$' | fzf

# Example: Search for TODO comments and show context
rg -i "todo|fixme" -C 2 --type typescript

# Example: Find and process configuration files
fd 'config.*\.json' | xargs jq '.version' | sort -u
```

### Error Handling
- **Fallback strategy**: If ast-grep fails or language is unsupported, fall back to rg
- **Validate tool availability**: Check tool installation before usage
- **Handle edge cases**: Account for mixed-language files and unusual extensions

## Tool Installation Verification

Before using these tools in scripts or automation:

```bash
# Check tool availability
command -v fd >/dev/null 2>&1 || { echo "fd not installed"; exit 1; }
command -v rg >/dev/null 2>&1 || { echo "ripgrep not installed"; exit 1; }
command -v ast-grep >/dev/null 2>&1 || { echo "ast-grep not installed"; exit 1; }
command -v fzf >/dev/null 2>&1 || { echo "fzf not installed"; exit 1; }
```

## Additional Tools

While the core tools above cover most use cases, these additional tools may be useful for specialized tasks:

- **`grep`**: Fallback for basic text search when rg is unavailable
- **`find`**: Fallback for file discovery when fd is unavailable  
- **`sed`/`awk`**: Text processing and transformation
- **`sort`/`uniq`**: Result deduplication and sorting
- **`xargs`**: Efficient command chaining for large result sets

## Repository-Specific Considerations

Given this repository's focus on TypeScript/JavaScript development:
- **Default to TypeScript context** when using ast-grep
- **Prioritize structural search** for code analysis tasks
- **Use ripgrep for documentation** and configuration file searches
- **Combine tools effectively** for complex search workflows

This tool selection strategy ensures efficient, accurate, and maintainable search operations across the entire codebase.



<!-- Source: .ruler/workspace-file-references.md -->

# Workspace File Reference Rule

## Overview

This rule governs how workspace files (such as `.code-workspace` files) should reference directories and paths.

## Rule

**DO NOT** refer to the dotagents directory (`../dotagents` or similar) in workspace files. The dotagents directory is for reference only and should not be included as a workspace folder.

Instead, use the current directory path with "." (e.g., `"."`) or reference the appropriate workspace/directory directly.

## Examples

### Incorrect:
```json
{
  "folders": [
    {
      "name": "dotagents",
      "path": "../dotagents"
    }
  ]
}
```

### Correct:
```json
{
  "folders": [
    {
      "name": "dotfiles",
      "path": "."
    }
  ]
}
```

## Rationale

The dotagents directory contains configuration and reference materials that should not be part of the active workspace. Including it can cause confusion and unnecessary clutter in the workspace structure.
