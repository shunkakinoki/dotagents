# Paperclip Routines

Routines are recurring tasks. Each time a routine fires it creates an execution issue assigned to the routine's agent.

## Creating a Routine

```sh
curl -sS -X POST "$PAPERCLIP_API_URL/api/companies/$PAPERCLIP_COMPANY_ID/routines" \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Weekly CEO briefing",
    "assigneeAgentId": "{agentId}",
    "projectId": "{projectId}",
    "status": "active",
    "concurrencyPolicy": "coalesce_if_active",
    "catchUpPolicy": "skip_missed"
  }'
```

## Adding Triggers

### Schedule (cron)

```json
{
  "kind": "schedule",
  "cronExpression": "0 9 * * 1",
  "timezone": "America/New_York"
}
```

### Webhook

```json
{
  "kind": "webhook",
  "signingMode": "hmac_sha256",
  "replayWindowSec": 300
}
```

## Concurrency Policies

| Policy | Behaviour |
|--------|-----------|
| `coalesce_if_active` (default) | New run coalesced to existing active run |
| `skip_if_active` | New run skipped if active run exists |
| `always_enqueue` | Always create new issue |

## Catch-Up Policies

| Policy | Behaviour |
|--------|-----------|
| `skip_missed` (default) | Missed runs dropped |
| `enqueue_missed_with_cap` | Missed runs enqueued, cap at 25 |

## Manual Run

```sh
curl -sS -X POST "$PAPERCLIP_API_URL/api/routines/{routineId}/run" \
  -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  -d '{"source": "manual"}'
```
