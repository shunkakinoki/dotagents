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