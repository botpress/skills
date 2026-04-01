# Integration Lifecycle

End-to-end walkthrough of discovering, adding, configuring, and using integrations in an ADK project.

## 1. Discover

Find and inspect integrations before adding them.

```bash
# Search by keyword
adk search slack

# Browse all available integrations
adk list --available

# Get full details (actions, channels, events, config schema)
adk info slack
adk info slack --format json   # Machine-readable for inspecting config
```

See [discovery.md](./discovery.md) for full command reference.

## 2. Add

Add an integration to your project with `adk add`:

```bash
adk add <name>@<version>
```

**Examples:**

```bash
adk add browser@0.8.6           # Specific version
adk add slack                   # Latest version
adk add agi/linear@1.2.0        # Private integration with version
adk add openai --alias ai       # Custom alias
```

### What Happens

1. The integration is resolved (name + version lookup)
2. An entry is added to `agent.config.ts` under `dependencies.integrations`
3. The integration starts **disabled**
4. Status is set to `registration_pending`

### Version Pinning

| Format | Behavior |
|--------|----------|
| `name@version` | Pins to exact version (recommended) |
| `name` | Resolves to latest available version |
| `intver_<ULID>` | Resolves by exact integration version ID |

Always specify a version when adding integrations to avoid unexpected upgrades.

### Aliasing

The `--alias` flag sets a custom code accessor name:

```bash
adk add openai@1.0.0 --alias ai
```

This means you'll use `actions.ai.<actionName>()` instead of `actions.openai.<actionName>()` in your code.

Without `--alias`, the integration name becomes the alias (e.g., `actions.slack.*`).

## 3. Configure

After adding, configure the integration via the Botpress Control Panel:

1. **Enable** the integration (toggle `enabled` to `true`)
2. **Set configuration** values if required (depends on integration type)
3. **Complete OAuth** if the integration uses link-based authorization

See [configuration.md](./configuration.md) for details on config types (no-config, optional, OAuth, API key, sandbox).

### Status Flow

After enabling, the integration goes through a registration process:

```
registration_pending → registered       (success)
                     → registration_failed  (error)
```

Use `adk list` to check the current status of installed integrations.

## 4. Use in Code

Once registered, access integration actions from your ADK code:

```typescript
import { actions } from '@botpress/runtime'

// Call integration actions using the alias
await actions.slack.sendMessage({ channel: '#general', text: 'Hello!' })
await actions.browser.webSearch({ query: 'Botpress ADK' })
await actions.chat.sendEvent({ type: 'custom', payload: {} })
```

The alias from `agent.config.ts` determines the accessor:

```typescript
// agent.config.ts: { chat: { version: 'chat@0.7.7', enabled: true } }
await actions.chat.sendEvent(...)  // 'chat' is the alias

// agent.config.ts: { ai: { version: 'openai@1.0.0', enabled: true } }
await actions.ai.complete(...)     // 'ai' is the alias (set via --alias)
```

Integration actions are fully typed — your editor will show available actions, input schemas, and output types.

## 5. Removing and Upgrading

### Removing

To remove an integration, delete its entry from `dependencies.integrations` in `agent.config.ts` and run `adk dev` or `adk deploy` to apply the change.

### Upgrading

To upgrade an integration version:

1. Run `adk add <name>@<new-version>` — this updates the existing entry
2. Check for breaking changes in the new version's actions/events
3. Re-deploy with `adk deploy`

## Complete Example

```bash
# 1. Search for what you need
adk search messaging

# 2. Inspect the integration
adk info slack --full

# 3. Add it to your project
adk add slack@3.0.0

# 4. Configure in Control Panel (enable, set replyBehaviour, complete OAuth) by the human

# 5. Use in code
```

```typescript
// src/tools/notifySlack.ts
import { Autonomous, actions } from '@botpress/runtime'

export const notifySlack = new Autonomous.Tool({
  name: 'notifySlack',
  description: 'Send a notification to a Slack channel',
  input: { channel: 'string', message: 'string' },
  handler: async ({ channel, message }) => {
    await actions.slack.sendMessage({ channel, text: message })
    return { sent: true }
  },
})
```
