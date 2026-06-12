# Plugins

Plugins are pre-built, reusable capabilities published on the Botpress Hub that you install into your agent. Unlike integrations (which connect to external platforms), plugins add self-contained behavior -- tools, actions, data sources, or components -- that run inside your bot.

Users consume plugins. They do not author them.

## Plugin vs Integration

|                        | Plugin                                    | Integration                                       |
| ---------------------- | ----------------------------------------- | ------------------------------------------------- |
| **Purpose**            | Adds behavior/logic to your bot           | Connects to an external platform                  |
| **Installed via**      | `adk plugins add <name>`                  | `adk add <name>` or `adk integrations add <name>` |
| **May depend on**      | Integrations (via interface wiring)       | Nothing                                           |
| **Lock file key**      | `plugins`                                 | `integrations`                                    |
| **Action call format** | `plugins.<alias>.actions.<action>(input)` | `actions.<alias>.<action>(input)`                 |

## CLI Commands

All plugin management goes through the `adk plugins` subcommand group. Every command supports `--format json` for scripted output.

### Discovery

```bash
# Search the Hub for plugins
adk plugins search <query>

# Inspect a plugin before installing (shows config, actions, dependencies)
adk plugins info <name>
adk plugins info <name>@<version>
```

### Adding and Removing

```bash
# Add a plugin (latest version, alias defaults to plugin name)
adk plugins add <name>

# Add a specific version
adk plugins add <name>@<version>

# Add with a custom alias
adk plugins add <name> --alias <alias>

# Add with configuration values
adk plugins add <name> --config key1=value1 --config key2=value2

# Wire interface dependencies explicitly
adk plugins add <name> --dep <interface-alias>=<integration-alias>

# Target a specific environment (default: dev)
adk plugins add <name> --target prod

# Remove a plugin by alias
adk plugins remove <alias>
adk plugins remove <alias> --target prod
```

### Listing and Inspection

```bash
# List installed plugins
adk plugins list

# Show config and dependency details
adk plugins list --verbose

# Target a specific environment
adk plugins list --target prod
```

### Configuration

```bash
# Set config values on an installed plugin
adk plugins configure <alias> --set key=value

# Remove config keys
adk plugins configure <alias> --unset key1 key2

# Rewire interface dependencies
adk plugins configure <alias> --map <interface-alias>=<integration-alias>

# Target a specific environment (default: dev)
adk plugins configure <alias> --set key=value --target prod
```

### Lifecycle

```bash
# Enable / disable a plugin without removing it
adk plugins enable <alias>
adk plugins disable <alias>

# Target a specific environment (default: dev)
adk plugins enable <alias> --target prod
adk plugins disable <alias> --target prod

# Upgrade to latest or a specific version
adk plugins upgrade <alias>
adk plugins upgrade <alias> --to <version>
adk plugins upgrade <alias> --target prod
```

### Lock File Management

Plugin state is tracked in `dependencies.<env>.lock.json` alongside integrations. These commands manage the lock file:

```bash
# Pull cloud state into the local lock file
adk plugins sync
adk plugins sync --target prod
adk plugins sync --dry-run          # preview without writing

# Push lock file state to cloud
adk plugins apply
adk plugins apply --target prod
adk plugins apply --dry-run         # preview without writing
adk plugins apply --yes             # allow destructive changes without confirmation

# Show differences between lock and cloud
adk plugins diff
adk plugins diff --target prod

# Copy plugin state between environments
adk plugins copy --from dev --to prod
adk plugins copy --from dev --to prod --dry-run
adk plugins copy --from dev --to prod --yes   # allow destructive changes without confirmation
```

## Interface Dependencies

Plugins often depend on [interfaces](./interfaces.md) -- abstract contracts that integrations implement. When you add a plugin, the CLI resolves these dependencies:

1. **Auto-resolved** -- If exactly one installed integration implements the required interface, it is wired automatically.
2. **Ambiguous** -- If multiple installed integrations implement the same interface, the CLI errors and asks you to disambiguate with `--dep`.
3. **Missing** -- If no installed integration implements the interface, the CLI errors and suggests Hub integrations you can install first.

**Example: adding a plugin that requires the `hitl` interface**

```bash
# If you already have exactly one integration implementing hitl:
adk plugins add desk-hitl
# CLI auto-resolves the interface dependency

# If multiple integrations implement hitl, disambiguate:
adk plugins add desk-hitl --dep hitlService=zendesk

# If no integration implements hitl, install one first:
adk integrations add zendesk
adk plugins add desk-hitl
```

After installation, you can re-wire dependencies any time:

```bash
adk plugins configure desk-hitl --map hitlService=freshdesk
```

## Using Plugin Actions in Code

Installed plugins expose typed actions via the `plugins` proxy from `@botpress/runtime`. The ADK generates types automatically so you get full autocompletion.

```typescript
import { plugins } from '@botpress/runtime'

// Call a plugin action: plugins.<alias>.actions.<actionName>(input)
const result = await plugins.myPlugin.actions.doSomething({ key: 'value' })
```

The call format is `plugins.<alias>.actions.<action>()`. This differs from integration actions, which use `actions.<alias>.<action>()`. See [Integration Actions](./integration-actions.md) for comparison.

Plugin actions are routed through the Botpress client internally -- the runtime proxy calls `client.callAction()` with the format `<alias>#<actionName>`, so you never need to construct this yourself.

## Lock File Structure

Plugins live in `dependencies.dev.lock.json` (or `dependencies.prod.lock.json`) under the `plugins` key:

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
      "config": {
        "apiKey": "${env:HITL_API_KEY}"
      },
      "dependencies": {
        "hitlService": {
          "integrationAlias": "zendesk"
        }
      }
    }
  }
}
```

Each plugin entry has:

| Field          | Description                                 |
| -------------- | ------------------------------------------- |
| `name`         | Plugin name on the Hub                      |
| `version`      | Installed version                           |
| `enabled`      | Whether the plugin is active                |
| `config`       | Configuration key-value pairs               |
| `dependencies` | Map of interface alias to integration alias |

## Environment Variable References

Plugin config values support `${env:VAR_NAME}` syntax. The CLI substitutes these from the process environment at apply time while preserving the reference in the lock file. This keeps secrets out of version control.

```bash
# Set a config value that references an env var
adk plugins configure my-plugin --set apiKey='${env:MY_API_KEY}'
```

## Common Patterns

### Add a Plugin with All Dependencies

```bash
# 1. Install the required integration first
adk integrations add zendesk@2.0.0

# 2. Add the plugin (interface dependency auto-resolves)
adk plugins add desk-hitl@1.0.0

# 3. Verify
adk plugins list --verbose
```

### Promote Plugins from Dev to Prod

```bash
# Copy all plugin (and integration) state from dev to prod
adk plugins copy --from dev --to prod --dry-run   # preview first
adk plugins copy --from dev --to prod --yes        # apply
```

### Temporarily Disable a Plugin

```bash
adk plugins disable my-plugin
# Later:
adk plugins enable my-plugin
```

### Sync After Manual Cloud Changes

If someone changed plugin state through the Botpress dashboard:

```bash
adk plugins sync           # pull cloud state into lock file
adk plugins diff           # verify lock matches cloud
```

## Pitfalls

1. **Interface dependency errors on add** -- The most common failure. Always ensure the required integration is installed _before_ adding the plugin. Run `adk plugins info <name>` to see what interfaces a plugin needs.

2. **Ambiguous dependencies** -- If you have multiple integrations implementing the same interface (e.g., two different HITL providers), you must pass `--dep` to disambiguate. The CLI will not guess.

3. **Plugin actions vs integration actions** -- Plugin actions use `plugins.<alias>.actions.<name>()`, not `actions.<alias>.<name>()`. Mixing these up gives runtime errors.

4. **Lock file drift** -- If someone adds or removes plugins via the Botpress dashboard, your local lock file becomes stale. Run `adk plugins sync` to reconcile.

5. **Prod requires confirmation** -- `adk plugins apply --target prod` and destructive operations (uninstalls) require `--yes` to proceed. This is intentional.

6. **Old `adk add plugin:` syntax** -- The legacy `adk add plugin:<name>` command still works but routes through the older dependency path. Prefer `adk plugins add <name>` for the full feature set (config, deps, enable/disable).

## See Also

- [Interfaces](./interfaces.md) -- Built-in interface abstraction layer over integrations
- [Integrations](./integrations.md) -- Integration management overview
- [Integration Actions](./integration-actions.md) -- Calling integration actions from code
- [CLI](./cli.md) -- Complete CLI command reference
- [Agent Config](./agent-config.md) -- Bot configuration and state management
