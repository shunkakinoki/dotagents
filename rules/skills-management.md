# Skills Management

## SKILLS.txt Format

```
# repo                              <- install all skills
# repo skill1 skill2 skill3         <- install selected (space-separated)
```

Each skill becomes `--skill <name>` flag passed to `bunx skills add`.

## Adding a Repo

```fish
# 1. List available skills
npx skills add owner/repo --global --list

# 2. Add to dotagents/SKILLS.txt
# Repos with <10 skills: install all (no selection)
# Repos with 10+ skills: always specify selections

# 3. Run sync
cd dotagents && make sync
```

## Validation

`make skills-validate` checks all selected skills exist in their repos.
