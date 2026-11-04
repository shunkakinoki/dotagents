# Desktop Apps

Use `agent-desktop` to see and operate desktop apps. Before the first use, run
`agent-desktop skills get desktop` and `agent-desktop skills get platform`, and follow them.
Retry a failed command only when `error.disposition.retry` is safe. See JSON output for the envelope, error codes, and exit codes.

Use `agent-desktop <command> --help` for flags for one command. The binary's guides
match its installed version.

The `agent-desktop` MCP server exposes every command over stdio, using command names
such as `desktop_snapshot`, `desktop_click`, and `desktop_session_start`. Each tool
takes the command's arguments and returns its JSON envelope. Global flags passed
to `agent-desktop mcp`, such as `--session`, `--headed`, or `--trace`, apply to every call.
