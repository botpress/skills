# CLI Reference

Command-line interface for building AI agents with the Botpress ADK.

## Quick Start

```bash
# 1. Log in non-interactively when possible
export BOTPRESS_TOKEN=pat_abc123
adk login --token "$BOTPRESS_TOKEN"

# 2. Create a new agent with defaults
adk init my-bot --yes --skip-link
cd my-bot

# 3. Link explicitly when you know the IDs
adk link --workspace ws_123 --bot bot_456

# 4. Start development
adk dev --logs --no-open

# 5. Deploy
adk deploy --yes
```

## Commands

### adk init

Create a new ADK agent project.

```bash
adk init [name]
```

**Options:**

- `name` - Project name (optional, prompts if omitted)
- `-t, --template <template>` - Template to use: `blank` or `hello-world`
- `-y, --yes` - Skip prompts and use sensible defaults
- `--defaults` - Alias for `--yes`
- `--skip-link` - Skip the linking step after project creation

**Defaults when using `--yes` / `--defaults`:**

- Project name: `my-agent` (if omitted)
- Template: `hello-world` (if omitted)
- Linking: skipped unless you run `adk link` later

**Examples:**

```bash
adk init customer-support

# Non-interactive setup for AI agents and CI
adk init customer-support --yes --skip-link

# Use the current hello-world template
adk init customer-support --template hello-world
```

**Automation notes:**

- `adk init` installs dependencies automatically after scaffolding.
- The CLI auto-selects a package manager based on lockfiles when possible, otherwise it falls back to the first available manager.
- If authentication is missing, `adk init` may still invoke login first.
- The non-interactive path only works after login has already been completed.
- For unattended setup, log in first with `adk login --token "$BOTPRESS_TOKEN"`, then run `adk init <name> --yes --skip-link`.

**Creates:**

```
my-agent/
├── agent.config.ts      # Agent configuration (includes dependencies)
└── src/
    ├── actions/         # Functions
    ├── conversations/   # Conversation handlers
    ├── knowledge/       # Knowledge bases
    ├── tables/          # Data storage
    ├── triggers/        # Event subscriptions
    └── workflows/       # Long-running processes
```

**Note:** Additional directories like `tools/`, `assets/`, etc. can be created manually as needed.

### adk login

Authenticate with Botpress.

```bash
adk login [options]
```

**Options:**

- `--token <token>` - Personal access token
- `--profile <name>` - Profile name (default: "default")
- `--api-url <url>` - API URL (default: https://api.botpress.cloud)

**Examples:**

```bash
# Interactive login
adk login

# Non-interactive with token
adk login --token pat_abc123

# Non-interactive with environment variable
export BOTPRESS_TOKEN=pat_abc123
adk login --token "$BOTPRESS_TOKEN"

# Multiple profiles
adk login --profile staging
adk login --profile production
```

**Automation notes:**

- Preferred AI/CI path: `adk login --token <token>`.
- `BOTPRESS_TOKEN` is best used as `adk login --token "$BOTPRESS_TOKEN"`.
- Bare `BOTPRESS_TOKEN` is only auto-used in non-interactive or no-TTY contexts.
- Without a token, `adk login` falls back to the interactive browser/manual flow.

**Profile Management:**

```bash
adk profiles list          # List all profiles
adk profiles set staging   # Switch profile
```

### adk dev

Start development mode with hot reloading.

```bash
adk dev [options]
```

**Options:**

- `-p, --port <port>` - Bot port (default: 3000)
- `--port-console <port>` - UI console port (default: 3001)
- `-l, --logs` - Stream logs to stderr (no TUI)
- `--no-open` - Do not auto-open the dev console in a browser

**What it does:**

1. Generates bot project in `.adk/bot/`
2. Creates/restores development bot
3. Syncs tables
4. Checks integrations
5. Starts UI server at http://localhost:3001
6. Watches files and hot-reloads

**Example:**

```bash
adk dev

# CI mode (no TUI)
adk dev --logs

# CI mode without opening a browser
adk dev --logs --no-open
```

**Automation notes:**

- `--logs` is the most AI-friendly mode, but `adk dev` is not fully headless.
- Dev can still hit interactive flows such as preflight, knowledge-base sync, or config prompts depending on project state.
- Treat `adk dev` as CI-friendly rather than guaranteed prompt-free.
- Event-driven integrations are not always perfectly mirrored in local dev; if an event flow behaves strangely, verify it against a deployed bot too.

### adk deploy

Deploy agent to Botpress Cloud.

```bash
adk deploy [options]
```

**Options:**

- `-e, --env <environment>` - Target environment (default: "production")
- `-y, --yes` - Auto-approve preflight changes without prompting

**What it does:**

1. Runs `adk build`
2. Validates configuration
3. Runs preflight checks
4. Deploys bot to Botpress Cloud
5. Syncs knowledge bases
6. Syncs tables

**Requires:**

- Logged in (`adk login`)
- `agent.json` with botId and workspaceId

**Example:**

```bash
adk deploy

# Auto-approve preflight changes
adk deploy --yes
```

**Automation notes:**

- `--yes` only auto-approves preflight changes.
- Deploy still validates configuration and may require interaction if config values are missing.
- Do not assume `adk deploy --yes` is fully non-interactive.

### adk build

Build agent for production.

```bash
adk build
```

Generates types, bundles code, validates configuration.

### adk link

Link local agent to existing remote bot.

```bash
adk link [options]
```

**Options:**

- `--workspace <id>` - Workspace ID
- `--bot <id>` - Bot ID
- `--dev <id>` - Dev bot ID (optional)
- `--api-url <url>` - Botpress API URL (e.g., https://api.botpress.cloud)
- `-f, --force` - Overwrite existing agent.json if present

**Example:**

```bash
# Interactive (recommended)
adk link

# Scriptable when you already know the IDs
adk link --workspace ws_123 --bot bot_456
```

Creates `agent.json` with bot and workspace IDs.

Current project scaffolds do not add `agent.json` to `.gitignore` automatically, so add that manually if your team does not want it committed.

**Automation notes:**

- `adk link --workspace <id> --bot <id>` is the best AI-driven path.
- If only one workspace exists, `adk link` may auto-select it.
- Even with flags, the command still uses the interactive Ink flow internally, so do not assume it is safe in every no-TTY environment.

### adk chat

Chat with your **local development bot**.

> ⚠️ `adk chat` (and `adk chat --single`) targets the linked dev bot — the one started by `adk dev` and identified by `devId`. It does **not** hit the deployed production bot. Never use it as a post-deploy smoke test or as any kind of "did the deploy work?" verification: a `--single` round-trip can pass against the dev bot while production is broken. For deployed bots, use `adk status --format json` for metadata and direct the user to the Dev Console for live verification.

```bash
adk chat                                # interactive
adk chat --single "<message>"           # one-shot
adk chat --single "<message>" --format json
```

**Requires:**

- `adk dev` run at least once (creates devId)

**Example:**

```bash
adk chat

# Output:
> Hello!
Bot: Hi! How can I help you today?
```

### adk add

Add integration to agent.

```bash
adk add <integration> [options]
```

**Options:**

- `--alias <name>` - Custom alias

**Aliases:** `adk i`, `adk install`

**Examples:**

```bash
# Add latest version
adk add slack

# Specific version
adk add slack@2.5.5

# With alias
adk add slack@2.5.5 --alias my-slack

# Interface
adk add interface:translator@1.0.0
```

Updates `agent.config.ts` dependencies, run `adk dev` to configure in UI.

### adk remove

Remove integration.

```bash
adk remove [integration]
```

**Alias:** `adk rm`

**Example:**

```bash
adk remove slack
```

### adk upgrade

Upgrade integration(s).

```bash
adk upgrade [integration]
```

**Alias:** `adk up`

**Example:**

```bash
# Upgrade specific
adk upgrade slack

# Interactive (all)
adk upgrade
```

### adk search

Search for integrations in the Botpress hub.

```bash
adk search <query>
```

**Description:** Search available integrations by name or keyword.

**Example:**

```bash
# Search for Slack integration
adk search slack

# Output:
# Found 1 integration matching "slack"
#
# Name     Version  Title  Description
# ─────────────────────────────────────
# slack    3.0.0    Slack  Automate interactions with your team.
#
# Run adk info <name> to see integration details
```

### adk list

List integrations (installed or available).

```bash
adk list [options]
```

**Options:**

- `--available` - List all available integrations from the hub (doesn't require being in a project)

**Description:**

- When run in a project directory: Lists installed integrations
- With `--available` flag: Lists all integrations available in the Botpress hub

**Example:**

```bash
# List installed integrations (in project)
adk list

# List all available integrations
adk list --available

# Output:
# Available Integrations (50+)
#
# Name           Version  Title
# ───────────────────────────────────
# slack          3.0.0    Slack
# whatsapp       4.5.6    WhatsApp
# linear         2.0.0    Linear
# ...
```

### adk info

Show detailed information about an integration.

```bash
adk info <integration>
```

**Description:** Display comprehensive details including actions, channels, events, and usage instructions.

**Example:**

```bash
adk info slack

# Output:
# Slack v3.0.0
#
# Automate interactions with your team.
#
# • 9 actions
# • 3 channels
# • 6 events
#
# Actions
#   addReaction - Add a reaction to a message
#   findTarget - Find a target in Slack
#   getUserProfile - Get user information
#   ...
#
# Channels
#   channel, dm, thread
#
# Events
#   memberJoinedChannel
#   reactionAdded
#   ...
```

### adk self-upgrade

Upgrade the ADK CLI itself to the latest version.

```bash
adk self-upgrade
```

**Aliases:** `adk self-update`

**What it does:**

1. Checks npm registry for latest version
2. Downloads binary from GitHub releases
3. Replaces current CLI executable
4. Verifies installation

**Example:**

```bash
adk self-upgrade

# Output:
📦 Current version: 1.13.10
📦 Latest version: 1.13.16
📥 Downloading adk v1.13.16 for darwin-arm64...
✅ Successfully upgraded!

   v1.13.10 → v1.13.16

   Run adk --version to verify
```

**Note:** The ADK automatically checks for updates every 24 hours and shows a notification when a new version is available. On Windows, you may need to restart your terminal after upgrading.

**This is different from `adk upgrade`** which upgrades integrations, not the CLI itself.

### adk kb

Manage knowledge bases and synchronization.

```bash
adk kb sync [options]
```

**Commands:**

- `adk kb sync` - Sync knowledge base sources with remote

**Options:**

- `--dev` - Sync with development bot (required: must use --dev or --prod)
- `--prod` - Sync with production bot (required: must use --dev or --prod)
- `--dry-run` - Preview changes without applying them
- `-y, --yes` - Skip confirmation prompts
- `--force` - Force re-sync all knowledge bases

**What it does:**

1. Detects knowledge bases defined in your project
2. Identifies sources (directories, websites, tables)
3. Syncs content to Botpress Cloud
4. Handles orphaned sources (sources removed from code)

**Example:**

```bash
# Sync to development bot
adk kb sync --dev

# Sync to production bot
adk kb sync --prod

# Auto-confirm sync
adk kb sync --dev -y

# Preview changes without applying
adk kb sync --dev --dry-run

# Force re-sync all knowledge bases
adk kb sync --dev --force
```

**Source Types:**

- `Directory` - Local files from a directory
- `Website` - Pages from sitemap or URLs
- `Table` - Data from bot tables

**Note:** KB sync is also run automatically during `adk dev` and `adk deploy`.

### adk assets sync

Sync assets with remote storage.

```bash
adk assets sync [options]
```

**Options:**

- `--dry-run` - Preview changes
- `-y, --yes` - Skip confirmation
- `--bail-on-failure` - Stop on first error
- `--force` - Force re-upload all files

**Example:**

```bash
# Interactive
adk assets sync

# Auto-confirm
adk assets sync -y
```

**Other asset commands:**

```bash
adk assets list          # List all assets
adk assets status        # Show sync status
adk assets pull          # Download remote assets to local directory
```

### adk assets list

List all asset files.

```bash
adk assets list [options]
```

**Options:**

- `--local` - Show only local assets
- `--remote` - Show only remote assets

### adk assets status

Show asset synchronization status.

```bash
adk assets status
```

### adk assets pull

Download remote assets to local directory.

```bash
adk assets pull
```

### adk mcp

Start the MCP (Model Context Protocol) server for AI assistant integration.

```bash
adk mcp [--cwd <path>]
```

The MCP server provides tools for AI assistants (Claude Code, Cursor, VS Code) to debug, test, and manage your ADK project. See **[MCP Server](./mcp-server.md)** for details.

### adk mcp:init

Generate MCP configuration files for AI assistants.

```bash
adk mcp:init [options]
```

**Options:**

- `--all` - Generate for all supported tools
- `--tool <name>` - Generate for specific tool (claude-code, vscode, cursor)
- `--force` - Overwrite existing config
- `--project-dir <path>` - ADK project subdirectory (for monorepos)

**Example:**

```bash
adk mcp:init --all
```

See **[MCP Server](./mcp-server.md)** for monorepo setup and troubleshooting.

### adk profiles

Manage authentication profiles.

```bash
adk profiles [command]
```

**Commands:**

- `adk profiles list` - List all configured profiles
- `adk profiles set [profile]` - Switch to a different profile

**Example:**

```bash
# List all profiles
adk profiles list

# Switch to a different profile
adk profiles set staging
```

### adk config

Configure agent settings interactively.

```bash
adk config [options]
```

**Options:**

- `--prod` - Use production configuration

**Subcommands:**

- `adk config:get <key>` - Get a configuration value
- `adk config:set <key> <value>` - Set a configuration value

Both subcommands support `--prod` flag for production configuration.

**Example:**

```bash
# Interactive configuration
adk config

# Get a config value
adk config:get botId

# Set a config value
adk config:set botId bot_123

# Use production configuration
adk config --prod
adk config:get botId --prod
```

**Note:** This replaces the legacy `adk agent` command.

### adk telemetry

Manage telemetry preferences.

```bash
adk telemetry [options]
```

**Options:**

- `--status` - Show telemetry status
- `--enable` - Enable telemetry
- `--disable` - Disable telemetry

**Example:**

```bash
# Check telemetry status
adk telemetry --status

# Enable telemetry
adk telemetry --enable

# Disable telemetry
adk telemetry --disable
```

### adk run

Run a TypeScript script with full ADK runtime context.

```bash
adk run <script> [args...] [options]
```

**Options:**

- `--force` - Force regeneration of the bot project
- `--prod` - Use production bot ID instead of dev bot ID

**Description:**

Executes a TypeScript script with access to the full ADK runtime, including:
- Bot client with authentication
- All tables, workflows, and actions from your project
- Type-safe access to your bot's configuration

**Use Cases:**

- One-off data migrations
- Manual sync operations
- Testing specific functionality
- Admin scripts

**Example Scripts:**

```typescript
// scripts/migrate-users.ts
import { UsersTable } from "../src/tables/Users";

const { rows } = await UsersTable.findRows({ limit: 100 });

for (const user of rows) {
  await UsersTable.updateRows({
    rows: [{ id: user.id, migrated: true }]
  });
  console.log(`Migrated user: ${user.id}`);
}

console.log(`✅ Migrated ${rows.length} users`);
```

**Examples:**

```bash
# Run a migration script
adk run scripts/migrate-users.ts

# Run with production bot
adk run scripts/sync-data.ts --prod

# Force regenerate types before running
adk run scripts/fix-data.ts --force

# Pass arguments to your script
adk run scripts/process.ts arg1 arg2
```

**Requirements:**

- Must be logged in (`adk login`)
- Must have linked bot (`adk link`)
- Script must be a TypeScript file

### Global Options

```bash
adk --no-cache <command>    # Disable cache
adk --version               # Show version
adk --help                  # Show help
adk                         # In agent directory: runs 'adk dev', otherwise: shows welcome
```

## Common Workflows

### New Project

```bash
adk init my-bot
cd my-bot
bun install
adk login
adk dev
```

### Daily Development

```bash
# Start dev
adk dev

# Make changes (auto-reload)

# Test
adk chat

# Deploy when ready
adk deploy
```

### Working with Existing Bot

```bash
git clone <repo>
cd my-bot
bun install
adk login
adk link --workspace ws_123 --bot bot_456
adk dev
```

### Managing Integrations

```bash
# Search for integrations
adk search slack

# List all available integrations
adk list --available

# Get detailed info about an integration
adk info slack

# Add
adk add slack@3.0.0

# Configure (start dev server to access UI)
adk dev  # Configure in UI at localhost:3001

# List installed
adk list

# Remove
adk remove slack
```

## Best Practices

**DO:**

- Use `adk dev` for development (hot reload)
- Keep `agent.config.ts` in git
- Use `.env` for secrets
- Run `adk chat` for quick testing

**DON'T:**

- Don't edit `.adk/` directory (auto-generated)
- Don't commit `agent.json` (add to .gitignore)
- Don't commit `.env` files
- Don't skip integration configuration in UI

## Quick Reference

```bash
# Lifecycle
adk init <name>          # Create project
adk login                # Authenticate
adk link                 # Link to remote bot
adk dev                  # Start development
adk chat                 # Test interactively
adk deploy               # Deploy to production
adk run <script>         # Run script with ADK runtime

# Integrations
adk search <query>       # Search for integrations
adk list                 # List installed integrations
adk list --available     # List all available integrations
adk info <integration>   # Show integration details
adk add <integration>    # Add integration
adk remove <name>        # Remove integration
adk upgrade [name]       # Upgrade integration(s)

# MCP (AI Assistant Integration)
adk mcp                  # Start MCP server
adk mcp:init --all       # Generate MCP config files

# CLI Management
adk self-upgrade         # Upgrade ADK CLI itself
adk telemetry            # Manage telemetry preferences

# Authentication
adk profiles list        # List profiles
adk profiles set         # Switch profile

# Configuration
adk config               # Configure agent settings
adk config:get <key>     # Get config value
adk config:set <key> <value>  # Set config value

# Knowledge Bases
adk kb sync --dev        # Sync KB to development bot
adk kb sync --prod       # Sync KB to production bot

# Assets
adk assets sync          # Sync assets
adk assets list          # List all assets
adk assets status        # Check sync status
adk assets pull          # Download remote assets
```

## See Also

- **[Agent Configuration](./agent-config.md)** - agent.config.ts, agent.json, environment variables, and project files
- **[MCP Server](./mcp-server.md)** - AI assistant integration (Claude Code, Cursor, VS Code)
- **[Conversations](./conversations.md)** - Conversation handlers
- **[Workflows](./workflows.md)** - Long-running processes
- **[Patterns & Mistakes](./patterns-mistakes.md)** - Best practices
