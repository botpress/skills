# Integration Configuration

How integrations are configured after being added to an ADK project. After adding an integration with `adk add`, if the dev server is not running, start it so everything syncs, then tell the user to open the Botpress Control Panel and update the integration configuration there.

## Configuration Types

Integrations vary in how much configuration they need. Use `adk info <name> --format json` to inspect an integration's configuration schema and determine what's required.

### No Config

The integration has zero configuration properties. Just enable it.

**Example:** `browser` has no config props at all. Add it, enable it, done.

### Optional Config Only

The integration has configuration properties, but none are required. It can be enabled as-is, and you only set config values if you want to customize behavior.

**Examples:**
- `chat` has optional `encryptionKey`, `webhookUrl`, `webhookSecret`
- `webchat` has ~38 optional theming/behavior props (`primaryColor`, `fontFamily`, `allowFileUpload`, etc.)
- `webhook` has optional `secret` and `allowedOrigins`

### OAuth (Link-Based)

The default configuration includes an `identifier` with a `linkTemplateScript`. The user clicks a generated URL in the Control Panel to authorize the integration via OAuth.

**Examples:** `whatsapp` (default config), `linear` (default config)

### OAuth + Required Fields

Some OAuth integrations also have required configuration fields that must be set alongside the OAuth flow.

**Example:** `slack` requires `replyBehaviour` to be set in addition to completing the OAuth link. Alternative configs: `manifestAppCredentials`, `refreshToken`.

### API Key / Manual

The configuration schema contains required string fields, often marked with `x-zui.secret: true` for sensitive values. The user enters these values directly in the Control Panel.

**Examples:** `linear` (apiKey config), `whatsapp` (manual config)

### Sandbox

A testing mode that uses a shared Botpress account. The integration provides a sandbox configuration with a VRL script for setup.

**Example:** `whatsapp` sandbox config (shared test phone number: +1-581-701-9840)

## Multiple Configuration Types

Some integrations offer several configuration modes. The `configurationType` field selects which mode to use.

**Example:** `whatsapp` has three modes:
- OAuth (default)
- Sandbox (testing)
- Manual (API key)

## Detecting Config Type from CLI

Use `adk info <name> --format json` and inspect these keys:

| JSON Key | What It Tells You |
|----------|-------------------|
| `configuration.schema` | The default config schema (properties, required fields) |
| `configuration.identifier` | Whether OAuth/link-based auth is used |
| `configurations` | Alternative configuration types (if any) |

If `configuration.schema.properties` is empty or all properties are optional, the integration needs no manual config.

If `configuration.identifier.linkTemplateScript` exists, it uses OAuth.

If `configurations` has multiple entries, the integration supports multiple modes.

## agent.config.ts Structure

Integrations are declared in the `dependencies.integrations` block of `agent.config.ts`.

### String Format

```typescript
integrations: {
  chat: 'chat@0.7.7',
  webchat: 'webchat@0.3.0',
},
```

Each key is the **alias** used to access the integration in code (e.g., `actions.chat.sendEvent()`). The value is the integration identifier in `name@version` format.

### Important Notes

- After adding an integration, if the dev server is not running, start it so the project syncs with Botpress
- After adding an integration, tell the user to open the Botpress Control Panel and update the integration configuration there
- Add integrations with `adk add` instead of manually editing `agent.config.ts`
- The alias determines the code accessor: `actions.<alias>.<actionName>()`
