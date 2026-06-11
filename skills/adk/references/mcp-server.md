# ADK MCP Server

The ADK has **no user-facing MCP command**. The former `adk mcp` and `adk mcp:init` commands were removed — they now error as unknown commands, and there are no generated `.mcp.json` / `.vscode/mcp.json` / `.cursor/mcp.json` config files.

## What Exists Today

The only MCP (Model Context Protocol) server in the ADK is **internal**: a stateful Streamable-HTTP server mounted at `/mcp` on the `adk dev` server. It exists to serve Agent(0) (the ADK's embedded agent harness, which connects to it as a remote MCP via opencode) — not external AI assistants.

- It runs in-process with the dev server, so its tools have direct access to dev server state.
- Its tool surface is small and internal (e.g., a Dev Console screenshot tool). Source of truth: `packages/cli/src/server/mcp/index.ts` in the ADK repo.
- You do not configure, start, or connect to it yourself. It starts and stops with `adk dev`.

## What To Use Instead

If you are an AI assistant (or scripting agent) working with an ADK project, use the CLI directly — every relevant command supports `--format json`:

```bash
# Debugging
adk logs --format json              # local dev log store
adk traces --format json            # execution traces
adk conversations --format json     # recent conversations

# Testing
adk chat --single "<message>" --format json

# Discovery
adk integrations search <query> --format json
adk integrations info <name> --format json

# Management
adk integrations add <name>@<version>
adk workflows run <name> '<payload>'
adk status --format json
```

For programmatic access to a running dev server from a separate process, discover it via `adk ps --format json` or `adk dashboard --no-browser --format json`.

## See Also

- **[CLI Reference](./cli.md)** - All ADK CLI commands
- **[Agent Configuration](./agent-config.md)** - agent.config.ts setup
