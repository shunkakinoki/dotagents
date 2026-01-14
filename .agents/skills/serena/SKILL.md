---
name: serena
allowed-tools: Read, Glob, Grep, Edit, MultiEdit, Write, Bash, TodoWrite, mcp__serena__*, mcp__context7__*
description: Structured problem-solving with Serena MCP
---

# /serena — Problem-solving with Serena MCP

Use Serena MCP for structured app development and debugging.

## Usage

```bash
/serena <problem> [options]
/serena debug "memory leak"     # 5-8 thoughts
/serena design "auth system"    # 8-12 thoughts
/serena implement "add feature" # 6-10 thoughts
/serena review "optimize code"  # 4-7 thoughts
```

## Options

| Flag | Mode | Use Case |
|------|------|----------|
| `-q` | Quick (3-5 thoughts) | Simple bugs |
| `-d` | Deep (10-15 thoughts) | Complex systems |
| `-c` | Code-focused | Refactoring |
| `-s` | Step-by-step | Full features |
| `-v` | Verbose | Show process |
| `-r` | Research | Tech decisions |
| `-t` | Todos | Create task list |

## Problem Detection

| Keywords | Pattern | Thoughts |
|----------|---------|----------|
| error, bug, broken | Debug | 5-8 |
| architecture, system | Design | 8-12 |
| build, create, add | Implement | 6-10 |
| performance, slow | Optimize | 4-7 |
| analyze, check | Review | 4-7 |

## Workflow

1. Auto-detect problem type
2. Use Serena MCP tools for code analysis
3. Research with Context7 if needed
4. Provide actionable solution
5. Create todos if `-s` flag used

## Guidelines

- Use `-q` for simple problems (saves tokens)
- Use `--focus=AREA` for domain-specific analysis
- Combine related problems in single session
