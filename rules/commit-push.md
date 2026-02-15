# /commit-push — Commit and push workflow

```bash
git add .
git commit -m "type: description"  # feat|fix|docs|refactor|chore|perf|test
git push -u origin <branch>
```

- Atomic commits, present tense, under 72 chars
- No co-authorship. Reference issues: `Closes #123`
- Pre-commit: `$PM run format && $PM run lint && $PM run check`
