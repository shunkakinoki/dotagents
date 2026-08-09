# Code Comments

- Write only non-obvious WHY: hidden constraints, why a workaround exists, surprising behavior.
- No WHAT comments. `// get the user ID` is zero information.
- No change history. That belongs in `git log` and the PR.
- No task ID references. Put the needed context in the comment itself.
- Never pad uncertain code with comments. Flag uncertainty in the PR body, not the source.
- Docs and README: current behavior only, no rationale trails or migration history.
