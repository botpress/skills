# Integration Management

Integrations connect your agent to external platforms and services. Manage them entirely through the CLI — never hand-edit the generated snapshots under `.adk/dependencies/`.

## CLI Commands

All integration management uses the `adk integrations` subcommand family. Every mutation command supports `--target <env>` (dev or prod, default: dev) and `--format <format>` (text or json).

> **Removed flat commands:** The old flat commands (`adk add`, `adk remove`, `adk search`, `adk list`, `adk info`, `adk upgrade`) were removed entirely — they now error as unknown commands. Use the `adk integrations` subcommands instead.

### Discovery

| Command                           | Description                                                   | Key Flags                                      |
| --------------------------------- | ------------------------------------------------------------- | ---------------------------------------------- |
| `adk integrations search <query>` | Search the Hub by keyword                                     | `--interface <name>`, `--format json`          |
| `adk integrations list`           | Show installed dependencies                                   | `--target <env>`, `--verbose`, `--format json` |
| `adk integrations info <name>`    | Full integration details (includes Channels, Actions, Events) | `--format json`                                |
| `adk integrations status`         | Explain unready dependencies                                  | `--target <env>`, `--format json`              |

Use `--format json` for programmatic inspection of config schemas, action shapes, and event payloads. To browse the Hub, use `adk integrations search <query>`.

### Mutations

| Command                                 | Description                             | Key Flags                                                |
| --------------------------------------- | --------------------------------------- | -------------------------------------------------------- |
| `adk integrations add <name>@<version>` | Install an integration                  | `--alias <name>`, `--target <env>`, `--config key=value` |
| `adk integrations remove <alias>`       | Uninstall an integration                | `--target <env>`                                         |
| `adk integrations upgrade <alias>`      | Upgrade to latest (or specific) version | `--to <version>`, `--target <env>`                       |
| `adk integrations enable <alias>`       | Enable a disabled integration           | `--target <env>`                                         |
| `adk integrations disable <alias>`      | Disable without removing                | `--target <env>`                                         |
| `adk integrations configure <alias>`    | Set or unset config values              | `--set key=value`, `--unset key`, `--target <env>`       |

### State Management

| Command                   | Description                                       | Key Flags                                          |
| ------------------------- | ------------------------------------------------- | -------------------------------------------------- |
| `adk integrations copy`   | Copy integration state between environments       | `--from <env>`, `--to <env>`, `--dry-run`, `--yes` |
| `adk integrations diff`   | Show differences between local snapshot and cloud | `--target <env>`                                   |
| `adk integrations status` | Explain why dependencies aren't ready             | `--target <env>`                                   |

## Dependency State

**Botpress Cloud is the source of truth** for dependency state. The CLI keeps generated per-environment snapshots under `.adk/dependencies/`:

- `.adk/dependencies/dev.json` — development environment
- `.adk/dependencies/prod.json` — production environment
- `.adk/dependencies/migration.json` — marker recording that legacy state was migrated

**Key principles:**

- Snapshots are a generated cache, refreshed from Cloud after every mutation. Never hand-edit them and never commit them as desired state.
- The `--target` flag controls which environment (dev/prod) a command operates on.
- To move state between environments, use `adk integrations copy --from dev --to prod` (preview with `--dry-run`, compare with `adk integrations diff`).
- `adk integrations status` explains unready dependencies (`unconfigured`, `missingFields`, `authorizationPending`).
- Config values support env substitution: `${env:API_KEY}` resolves to `process.env.API_KEY` at apply time.

**Migration from legacy state:** Older projects kept dependency state in a `dependencies` block in `agent.config.ts` and/or root lock files (`dependencies.dev.lock.json`, `dependencies.prod.lock.json`). Both are legacy: on first contact the CLI migrates that state **to Cloud** (the config block is removed from the file, the root lock files are read once and deleted), then regenerates the `.adk/dependencies/` snapshots from Cloud. Neither legacy source is used at runtime.

## Integration Lifecycle

### 1. Discover

```bash
adk integrations search slack
adk integrations search --interface llm
adk integrations info slack --format json
```

### 2. Add

```bash
adk integrations add slack@3.0.0
adk integrations add openai@1.0.0 --alias ai
adk integrations add agi/linear@2.0.0
```

Always pin to a specific version. Without `--alias`, the integration name becomes the alias.

What happens: the integration is resolved, installed on the Cloud bot (the local `.adk/dependencies/` snapshot is regenerated from Cloud), and starts **disabled** with status `registration_pending`.

### 3. Configure

```bash
adk integrations configure slack --set replyBehaviour=start-conversation
adk integrations configure slack --set apiSecret='${env:SLACK_SECRET}'
adk integrations configure slack --unset optionalField
```

For OAuth integrations, complete the authorization flow in the Botpress Dev Console (`localhost:3001` during dev).

### 4. Enable

```bash
adk integrations enable slack
```

After enabling, the integration registers with Botpress Cloud:

```
registration_pending → registered       (success)
                     → registration_failed  (error)
```

Check status with `adk integrations list`. If a dependency isn't ready, `adk integrations status` explains why (`unconfigured`, `missingFields`, `authorizationPending`).

### 5. Use in Code

```typescript
import { actions } from '@botpress/runtime'

await actions.slack.sendMessage({ channel: '#general', text: 'Hello!' })
await actions.browser.webSearch({ query: 'Botpress ADK' })
```

The alias determines the accessor: `actions.<alias>.<actionName>()`. See **[Integration Actions](./integration-actions.md)** for the full API reference.

### 6. Remove / Upgrade

```bash
adk integrations remove slack
adk integrations upgrade slack
```

After upgrading, check for breaking changes in the new version, then re-deploy with `adk deploy`.

## Configuration Types

Use `adk integrations info <name> --format json` to inspect an integration's configuration schema.

### No Config

Zero configuration properties. Just enable it.

**Example:** `browser` — add, enable, done.

### Optional Config Only

Has configuration properties but none are required. Works out of the box.

**Examples:**

- `chat` — optional `encryptionKey`, `webhookUrl`, `webhookSecret`
- `webchat` — ~38 optional theming/behavior props (`primaryColor`, `fontFamily`, `allowFileUpload`, etc.)
- `webhook` — optional `secret` and `allowedOrigins`

### OAuth (Link-Based)

Default configuration includes an `identifier` with a `linkTemplateScript`. User clicks a generated URL in the Dev Console to authorize.

**Examples:** `whatsapp` (default config), `linear` (default config)

### OAuth + Required Fields

OAuth authorization plus required configuration fields.

**Example:** `slack` — requires `replyBehaviour` in addition to OAuth. Alternative configs: `manifestAppCredentials`, `refreshToken`.

### API Key / Manual

Configuration schema has required string fields, often marked `x-zui.secret: true`. User enters values in the Dev Console or via `adk integrations configure --set`.

**Examples:** `linear` (apiKey config), `whatsapp` (manual config)

### Sandbox

Testing mode using a shared Botpress account. The integration provides a sandbox configuration with a VRL script.

**Example:** `whatsapp` sandbox config (shared test phone number: +1-581-701-9840)

### Detecting Config Type from CLI

Inspect `adk integrations info <name> --format json`:

| JSON Key                   | What It Tells You                                   |
| -------------------------- | --------------------------------------------------- |
| `configuration.schema`     | Default config schema (properties, required fields) |
| `configuration.identifier` | Whether OAuth/link-based auth is used               |
| `configurations`           | Alternative configuration types (if any)            |

If `configuration.schema.properties` is empty or all optional → no manual config needed.
If `configuration.identifier.linkTemplateScript` exists → OAuth.
If `configurations` has multiple entries → multiple modes available.

## Common Integrations Quick Reference

### chat

**Config:** Optional only (none required)
**Actions:** 1 (sendEvent) | **Channels:** 1 | **Events:** 1 (custom)

Used internally by `adk chat` CLI command. Good default for basic messaging during development.

### webchat

**Config:** Optional only (~38 theming/behavior props, none required)
**Actions:** 9 (configWebchat, showWebchat, hideWebchat, etc.) | **Channels:** 1 | **Events:** 2

Embeddable web chat widget. Works out of the box.

### browser

**Config:** None (zero properties)
**Actions:** 5 (browsePages, webSearch, discoverUrls, captureScreenshot, getWebsiteLogo) | **Channels:** 0 | **Events:** 0

Most commonly used for RAG, web search, and page scraping. No configuration needed.

### slack

**Config:** OAuth + required `replyBehaviour`
**Actions:** Multiple | **Channels:** 3 (channel, dm, thread) | **Events:** 6

After adding: enable in Dev Console, set `replyBehaviour`, complete OAuth. Alternative configs: `manifestAppCredentials`, `refreshToken`.

### whatsapp

**Config:** 3 modes (OAuth, sandbox, manual)
**Actions:** Multiple | **Channels:** 1 | **Events:** Multiple

Sandbox mode is useful for quick testing without a WhatsApp Business account.

### linear

**Name:** `agi/linear` (private, workspace-scoped) | **Config:** OAuth or API key
**Actions:** Multiple | **Channels:** Multiple | **Events:** Multiple

Use full name when searching: `adk integrations info agi/linear`.

### webhook

**Config:** Optional only (none required)
**Actions:** 0 | **Channels:** 0 | **Events:** 1

Receives external HTTP webhooks. Only fires events when a payload arrives.

## Name Resolution

| Format           | Example                             | Meaning                                     |
| ---------------- | ----------------------------------- | ------------------------------------------- |
| Plain name       | `slack`                             | Official/public integration, latest version |
| `name@version`   | `slack@3.0.0`                       | Specific version                            |
| `workspace/name` | `agi/linear`                        | Private (workspace-scoped) integration      |
| `intver_<ULID>`  | `intver_01KM6EB027NRCST3M696XT0GTW` | Exact integration version ID                |

Official integrations use just the name. Private integrations are prefixed with the workspace slug and are only visible to workspace members.
