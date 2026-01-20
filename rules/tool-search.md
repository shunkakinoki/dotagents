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