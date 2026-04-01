# Integration Discovery

How to find and inspect Botpress integrations using the ADK CLI.

## Searching Integrations

Use `adk search` to find integrations by keyword:

```bash
adk search <query>
```

**Flags:**

| Flag | Default | Description |
|------|---------|-------------|
| `--format` | `json` | Output format |
| `--limit <number>` | `20` | Maximum results to return |

**Example:**

```bash
adk search slack
adk search email --format json --limit 5
```

Returns: name, version, title, and description for each match.

If no results are found, try `adk list --available` to browse all integrations.

## Listing All Available Integrations

Use `adk list --available` to browse every integration published on the Botpress Hub:

```bash
adk list --available
```

**Flags:**

| Flag | Default | Description |
|------|---------|-------------|
| `--format <json>` | `json` | Output format |
| `--limit <number>` | `50` | Maximum results to return |

Returns: name, version, and title for each integration.

## Listing Installed Integrations

Use `adk list` (no flags) to see integrations already added to the current project:

```bash
adk list
```

**Flags:**

| Flag | Default | Description |
|------|---------|-------------|
| `--format <json>` | `json` | Output format |
| `--limit <number>` | `50` | Maximum results to return |

Returns: alias, name, version, and status for each installed integration.

> **Note:** Must be run from inside an ADK project directory.

## Inspecting an Integration

Use `adk info` to get full details about a specific integration:

```bash
adk info <name>
```

**Flags:**

| Flag | Default | Description |
|------|---------|-------------|
| `--actions` | off | Show only the actions section |
| `--channels` | off | Show only the channels section |
| `--events` | off | Show only the events section |
| `--full` | off | Show all sections (overrides individual flags) |
| `--format <json>` | `json` | Output format |

When no section flag is provided, all sections are shown by default.

Use `--format json` to programmatically inspect configuration schemas, action input/output shapes, and event payloads.

**Examples:**

```bash
adk info slack                    # Full overview
adk info browser --actions        # Just actions
adk info whatsapp --format json   # Machine-readable output
```

## Name Resolution

Integrations can be referenced in several ways:

| Format | Example | Meaning |
|--------|---------|---------|
| Plain name | `slack` | Official/public integration, latest version |
| `name@version` | `slack@3.0.0` | Specific version |
| `workspace/name` | `agi/linear` | Private (workspace-scoped) integration |
| `intver_<ULID>` | `intver_01KM6EB027NRCST3M696XT0GTW` | Exact integration version ID |

- **Official integrations** use just the name (e.g., `slack`, `browser`, `webchat`).
- **Private integrations** are prefixed with the workspace slug (e.g., `agi/linear`). These are only visible to members of that workspace.
