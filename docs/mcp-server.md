# ADK MCP Server

The ADK includes a built-in MCP (Model Context Protocol) server that enables AI assistants like Claude Code, Cursor, and VS Code to interact with your ADK project.

## Quick Setup

```bash
# From your ADK project root (auto-detects project)
adk mcp:init --all

# Or specify project directory (for monorepos)
adk mcp:init --all --project-dir ./bot
```

This generates configuration files for:
- **Claude Code**: `.mcp.json`
- **VS Code**: `.vscode/mcp.json`
- **Cursor**: `.cursor/mcp.json`

## What It Provides

Once configured, AI assistants gain tools to:

- **Debug** - Query traces, get dev logs, check build status
- **Test** - Send messages to your running bot and receive responses
- **Discover** - Search and explore integrations on the Botpress Hub
- **Manage** - Add integrations, start workflows, get agent info
- **Docs** - Search Botpress documentation (proxied from Mintlify)

The MCP server exposes its own tool descriptions - your AI assistant will see what's available.

## Commands

### adk mcp

Start the MCP server (called automatically by AI assistants via config).

```bash
adk mcp [--cwd <path>]
```

### adk mcp:init

Generate MCP configuration files.

```bash
adk mcp:init [options]
```

**Options:**
- `--tool <name>` - Generate for specific tool (claude-code, vscode, cursor)
- `--all` - Generate for all supported tools
- `--force` - Overwrite existing config
- `--project-dir <path>` - ADK project subdirectory (for monorepos)

## Monorepo Setup

When your ADK project is in a subdirectory:

```
my-monorepo/
├── bot/              # ADK project (agent.config.ts here)
├── frontend/
└── .mcp.json         # Config created at root
```

The generated config includes `--cwd` to target the correct directory:

```json
{
  "mcpServers": {
    "adk": {
      "command": "adk",
      "args": ["mcp", "--cwd", "./bot"]
    }
  }
}
```

## Requirements

- **ADK CLI** installed and in PATH
- **For project tools:** Valid ADK project with `agent.config.ts`
- **For messaging/workflow tools:** `adk dev` server running

## Troubleshooting

**"Not in an ADK project directory"**
- Ensure `--cwd` points to directory with `agent.config.ts`

**"Dev server is not running"**
- Start the dev server: `adk dev`

**"No chat or webchat integration found"**
- Add an integration: `adk add chat` or `adk add webchat`

**Inspect the MCP server:**

```bash
npx @modelcontextprotocol/inspector adk mcp
```

## See Also

- **[CLI Reference](./cli.md)** - All ADK CLI commands
- **[Agent Configuration](./agent-config.md)** - agent.config.ts setup
