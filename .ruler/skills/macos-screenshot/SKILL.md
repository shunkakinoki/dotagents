---
name: macos-screenshot
allowed-tools: nodes, exec, message
description: Capture and send screenshots from remote macOS nodes without context bloat
---

# /macos-screenshot — Capture macOS screen

Capture screenshots from remote macOS nodes and send them to users. Avoids context bloat by using proper file-based workflows instead of base64 encoding.

## ⚠️ Anti-Pattern: Never Do This

```
# WRONG: Base64 encoding a screenshot will blow up your context
nodes.run: base64 -i /tmp/screenshot.png  # 200K+ tokens = instant failure
```

## Correct Workflow

### Step 1: Capture Screen

Use `screen_record` with minimal duration (1ms) to capture a single frame:

```json
{
  "action": "screen_record",
  "node": "<node-id>",
  "durationMs": 1
}
```

Returns: `FILE:/tmp/clawdbot-screen-record-<uuid>.mp4`

### Step 2: Extract Frame

Use ffmpeg on the gateway host to extract a PNG frame:

```bash
ffmpeg -i /tmp/clawdbot-screen-record-<uuid>.mp4 \
  -frames:v 1 -update 1 -y /tmp/screenshot.png 2>/dev/null
```

### Step 3: Send Image

Send the image file directly via the message tool:

```json
{
  "action": "send",
  "channel": "telegram",
  "target": "<chat-id>",
  "media": "/tmp/screenshot.png"
}
```

## Complete Example

```python
# 1. Capture
result = nodes(action="screen_record", node="mac-xxx", durationMs=1)
# Returns: FILE:/tmp/clawdbot-screen-record-abc123.mp4

# 2. Extract frame
exec("ffmpeg -i /tmp/clawdbot-screen-record-abc123.mp4 -frames:v 1 -update 1 -y /tmp/mac-ss.png 2>/dev/null")

# 3. Send to user
message(action="send", channel="telegram", target="123456", media="/tmp/mac-ss.png")
```

## Analyzing Screenshots

To analyze what's on screen, use the `image` tool after extraction:

```json
{
  "image": "/tmp/screenshot.png",
  "prompt": "Describe what's visible on this macOS screen"
}
```

## Node Discovery

Find available macOS nodes:

```json
{
  "action": "status"
}
```

Look for nodes with `platform: "macos"` and `connected: true`.

## Troubleshooting

| Issue | Cause | Fix |
|-------|-------|-----|
| Context overflow (200K+) | Used base64 encoding | Use file-based workflow |
| `screen_record` timeout | Node disconnected | Check `nodes status` |
| ffmpeg not found | Missing on gateway | Install ffmpeg |
| Empty/black screenshot | Screen locked | Unlock Mac first |

## Key Points

- **Never** base64 encode images into the conversation
- **Always** use file paths with the `media` parameter
- Screen recording permission required on macOS node
- Clean up temp files periodically to save disk space
