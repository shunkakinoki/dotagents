# Company Skills Workflow

Use this reference when a board user, CEO, or manager asks you to find a skill, install it into the company library, or assign it to an agent.

## What Exists

- Company skill library: install, inspect, update, and read imported skills for the whole company.
- Agent skill assignment: add or remove company skills on an existing agent.
- Hire/create composition: pass `desiredSkills` when creating or hiring an agent.

## Core Endpoints

- `GET /api/companies/:companyId/skills`
- `GET /api/companies/:companyId/skills/:skillId`
- `POST /api/companies/:companyId/skills/import`
- `POST /api/agents/:agentId/skills/sync`
- `POST /api/companies/:companyId/agent-hires`
- `POST /api/companies/:companyId/agents`

## Install A Skill Into The Company

### Source types

| Source format | Example | When to use |
|---|---|---|
| **skills.sh URL** | `https://skills.sh/org/repo/skill-name` | Preferred — managed registry |
| **Key-style string** | `org/repo/skill-name` | Shorthand for skills.sh |
| **GitHub URL** | `https://github.com/org/repo` | When skill is on GitHub but not skills.sh |

```sh
curl -sS -X POST "$PAPERCLIP_API_URL/api/companies/$PAPERCLIP_COMPANY_ID/skills/import" \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"source": "https://skills.sh/org/repo/skill-name"}'
```

## Assign Skills To An Existing Agent

```sh
curl -sS -X POST "$PAPERCLIP_API_URL/api/agents/<agent-id>/skills/sync" \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"desiredSkills": ["org/repo/skill-name"]}'
```

## Include Skills During Hire Or Create

```sh
curl -sS -X POST "$PAPERCLIP_API_URL/api/companies/$PAPERCLIP_COMPANY_ID/agents" \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "QA Agent",
    "role": "qa",
    "adapterType": "codex_local",
    "adapterConfig": { "cwd": "/abs/path/to/repo" },
    "desiredSkills": ["org/repo/skill-name"]
  }'
```
