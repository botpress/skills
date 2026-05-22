# Plugin Management

Plugins are reusable agent extensions that bundle custom business logic as actions. Unlike integrations (which connect to external services), plugins provide composable agent capabilities that depend on integrations through interface contracts.

## Plugins vs Integrations

| | Integrations | Plugins |
|--|-------------|---------|
| **Purpose** | Connect to external services (Slack, Zendesk, etc.) | Add reusable agent logic (HITL, summarization, etc.) |
| **Expose** | Channels, events, actions | Actions only |
| **Interfaces** | Implement interfaces | Require interfaces |
| **Dependencies** | None | Map required interfaces to installed integrations |

**Example:** The `desk-hitl` plugin requires the `hitl` interface. If `slack` implements `hitl`, the CLI auto-wires the dependency. If both `slack` and `intercom` implement it, you disambiguate with `--dep hitl=slack`.

## CLI Commands

All plugin management uses the `adk plugins` subcommand family. Every command supports `--target <env>` (dev or prod, default: dev) and `--format <format>` (text or json).

### Discovery

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `adk plugins search <query>` | Search by keyword | `--format json` |
| `adk plugins list` | Show installed plugins | `--format json` |
| `adk plugins info <name>` | Full plugin details | `--format json` |

### Mutations

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `adk plugins add <name>@<version>` | Install a plugin | `--alias <name>`, `--dep iface=alias`, `--config key=value` |
| `adk plugins remove <alias>` | Uninstall a plugin | |
| `adk plugins upgrade <alias>` | Upgrade version | `--to <version>` |
| `adk plugins enable <alias>` | Enable a disabled plugin | |
| `adk plugins disable <alias>` | Disable without removing | |
| `adk plugins configure <alias>` | Set config and interface mappings | `--set key=value`, `--unset key`, `--map iface=alias` |

### State Management

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `adk plugins pull-lock` | Pull cloud state into lock file | `--dry-run` |
| `adk plugins push-lock` | Push lock file to cloud | `--dry-run`, `--yes` |
| `adk plugins copy` | Copy plugin state between environments | `--from <env>`, `--to <env>` |
| `adk plugins diff` | Show differences between lock file and cloud | |

## Interface Dependencies

Plugins declare which interfaces they require. When adding a plugin, the CLI resolves these against installed integrations:

- **Auto-resolve:** Exactly one integration implements the interface — wired automatically.
- **Ambiguous:** Multiple integrations match — CLI asks you to specify with `--dep iface=alias`.
- **Missing:** No integration implements the interface — CLI suggests which Hub integrations to install.

```bash
# Auto-resolves if only one integration implements 'hitl'
adk plugins add desk-hitl@1.0.0

# Explicit wiring when multiple integrations match
adk plugins add desk-hitl@1.0.0 --dep hitl=slack

# Remap interface dependencies after install
adk plugins configure desk-hitl --map hitl=intercom
```

## Lock File Structure

Plugins share the `dependencies.{dev,prod}.lock.json` lock files with integrations:

```json
{
  "version": 1,
  "env": "dev",
  "integrations": { ... },
  "plugins": {
    "desk-hitl": {
      "name": "desk-hitl",
      "version": "1.0.0",
      "enabled": true,
      "config": { "queue": "support" },
      "dependencies": {
        "hitl": { "integrationAlias": "slack" }
      }
    }
  }
}
```

The `dependencies` field maps each required interface to the integration alias that provides it.

## Lifecycle

### 1. Discover

```bash
adk plugins search hitl
adk plugins info desk-hitl --format json
```

### 2. Add

```bash
adk plugins add desk-hitl@1.0.0
adk plugins add desk-hitl@1.0.0 --dep hitl=slack --config queue=support
```

Always pin to a specific version.

### 3. Configure

```bash
adk plugins configure desk-hitl --set queue=priority
adk plugins configure desk-hitl --map hitl=intercom
```

### 4. Enable

```bash
adk plugins enable desk-hitl
```

### 5. Use in Code

Plugins expose actions callable from agent code. Check `adk plugins info <name> --format json` for available actions and their input/output schemas.

### 6. Remove / Upgrade

```bash
adk plugins remove desk-hitl
adk plugins upgrade desk-hitl
adk plugins upgrade desk-hitl --to 2.0.0
```
