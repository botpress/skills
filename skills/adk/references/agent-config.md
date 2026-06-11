# Configuration

Configure your bot's behavior, integrations, dependencies, and global state through the unified `agent.config.ts` file.

## agent.config.ts

The main configuration file defines your bot's core settings, AI models, dependencies, and state schemas.

### Configuration Example

```typescript
import { defineConfig, z } from "@botpress/runtime";

export default defineConfig({
  name: "customer-support-bot",
  description: "Customer support assistant with knowledge base",

  // AI Model Configuration
  defaultModels: {
    autonomous: "openai:gpt-4o",       // For execute() function
    zai: "openai:gpt-4o-mini",         // For zai operations
  },

  // User State Schema
  user: {
    state: z.object({
      preferredLanguage: z.enum(["en", "es", "fr", "de"]).default("en"),
      timezone: z.string().default("UTC"),
      name: z.string().optional(),
      email: z.string().email().optional(),
      notificationsEnabled: z.boolean().default(true),
      accountTier: z.enum(["free", "pro", "enterprise"]).default("free"),
      metadata: z.object({}).passthrough().default({}),
    }),
  },

  // Bot Global State Schema
  bot: {
    state: z.object({
      version: z.number().default(1),
      maintenanceMode: z.boolean().default(false),

      // Feature flags
      features: z.object({
        advancedSearch: z.boolean().default(false),
        multiLanguage: z.boolean().default(true),
      }).default({}),

      // Analytics
      totalConversations: z.number().default(0),
      totalUsers: z.number().default(0),
    }),
  },

  // Integrations are NOT configured here — their state lives in Botpress Cloud.
  // Use `adk integrations add/remove/configure` to manage them — see integrations.md
});
```

### Additional Configuration Fields

#### Tags

Tags are key-value pairs for categorizing entities. All entities (`user`, `bot`, `conversation`, `message`, `workflow`) support tags. See **[Tags](./tags.md)** for complete documentation.

#### Bot Configuration Schema

Define a custom configuration schema for bot-level settings accessible via the Context API:

```typescript
export default defineConfig({
  name: "my-bot",

  configuration: {
    schema: z.object({
      maxRetries: z.number().default(3),
      apiEndpoint: z.string(),
      featureFlags: z.object({
        enableBetaFeatures: z.boolean().default(false),
      }),
    }),
  },
});
```

Access via direct import from `@botpress/runtime`:

```typescript
import { configuration } from "@botpress/runtime";

if (configuration.featureFlags.enableBetaFeatures) {
  // Use beta features
}
```

See **[Context API](./context-api.md)** for details on accessing other runtime values.

### Model Configuration

**Default Models:**

If you don't specify `defaultModels`, both default to `"auto"`:
- `autonomous`: `"auto"`
- `zai`: `"auto"`

**Available Models:**

Any `provider:model` string is accepted — run `adk models` to list the models available to your bot. Examples:

```typescript
"openai:gpt-4o"
"openai:gpt-4o-mini"
"anthropic:claude-3-5-sonnet"
"google:gemini-1.5-pro"
```

**Model Fallback Arrays:**

You can specify multiple models as fallbacks:

```typescript
defaultModels: {
  autonomous: [
    "openai:gpt-4o",
    "anthropic:claude-3-5-sonnet",
    "openai:gpt-4o-mini"
  ],
  zai: "openai:gpt-4o-mini"
}
```

### Accessing Configuration

```typescript
import { bot, user } from "@botpress/runtime";

// In any handler (action, workflow, conversation)

// Access bot state
const version = bot.state.version;
const maintenanceMode = bot.state.maintenanceMode;

// Modify bot state
bot.state.totalConversations += 1;
bot.state.features.advancedSearch = true;

// Access user state
const language = user.state.preferredLanguage;
const tier = user.state.accountTier;

// Modify user state
user.state.lastActiveDate = new Date();
user.state.metadata.lastQuery = "product pricing";
```

## Dependencies (Integrations, Plugins, Interfaces)

Dependency state does **not** live in `agent.config.ts`. **Botpress Cloud is the source of truth.** The CLI keeps generated per-environment snapshots under `.adk/dependencies/` (`dev.json`, `prod.json`) — a cache refreshed after every mutation, never hand-edited or committed as desired state.

> **Migration:** Older projects kept a `dependencies` block in `agent.config.ts` and/or root lock files (`dependencies.dev.lock.json` / `dependencies.prod.lock.json`). Both are legacy: on first contact the CLI migrates that state **to Cloud** (the config block is removed from the file; the root lock files are read once and deleted). Neither is used at runtime.

### Managing Dependencies

Use the `adk integrations` CLI subcommands. See **[CLI Reference](./cli.md)** and **[Integrations](./integrations.md)** for full details:

```bash
adk integrations search <query>           # Search for integrations
adk integrations add <name>@<version>     # Add integration
adk integrations configure <alias> --set key=value  # Configure
adk integrations enable <alias>           # Enable
adk integrations remove <alias>           # Remove
adk integrations upgrade <alias>          # Upgrade
adk integrations list                     # List installed
adk integrations status                   # Explain unready dependencies
adk integrations copy --from dev --to prod  # Move state between environments
```

### Using Integration Actions

See **[Integration Actions](./integration-actions.md)** for calling integration functionality from your code.

## Environment Variables

### .env File

```bash
# Bot Configuration
BOT_NAME=customer-support-bot
NODE_ENV=development

# API Keys
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# Integration Tokens
SLACK_BOT_TOKEN=xoxb-...
LINEAR_API_KEY=lin_api_...

# ADK CLI overrides (optional — normally set by `adk login` / `adk link`)
# ADK_TOKEN=pat_...           # Auth token override
# ADK_BOT_ID=bot_...          # Bot ID override
# ADK_WORKSPACE_ID=ws_...     # Workspace ID override
# ADK_API_URL=https://api.botpress.cloud
# Note: dev server ports are NOT env vars — use `adk dev --port 3000 --port-console 3001`

# Feature Flags (optional)
ENABLE_ADVANCED_SEARCH=true

# External Services (optional)
WEBHOOK_URL=https://api.example.com/webhooks
```

### Accessing Environment Variables

```typescript
// In configuration
export default defineConfig({
  name: process.env.BOT_NAME || "my-bot",

  defaultModels: {
    autonomous: process.env.AI_MODEL || "openai:gpt-4o",
  },
});

// In handlers
export const myAction = new Action({
  async handler({ input }) {
    const apiKey = process.env.EXTERNAL_API_KEY;

    if (!apiKey) {
      throw new Error("EXTERNAL_API_KEY not configured");
    }

    // Use the API key
    const response = await fetch("https://api.example.com", {
      headers: { Authorization: `Bearer ${apiKey}` },
    });
  },
});
```

## State Management Patterns

### User State Patterns

```typescript
// Progressive profile building
export const Chat = new Conversation({
  async handler({ message, conversation, execute }) {
    // Collect user info progressively
    if (!user.state.name && message?.type === "text") {
      user.state.name = extractName(message.payload.text);
    }

    if (!user.state.email) {
      // Ask for email if needed
      await conversation.send({
        type: "text",
        payload: { text: "What's your email address?" },
      });
    }

    // Use preferences
    const language = user.state.preferredLanguage;
    await execute({
      instructions: `Respond in ${language}`,
    });
  },
});
```

### Bot State Patterns

```typescript
export const Chat = new Conversation({
  async handler({ conversation }) {
    // Feature flag checking
    if (bot.state.features.advancedSearch) {
      // Use advanced search
      const results = await advancedSearch(query);
    } else {
      // Use basic search
      const results = await basicSearch(query);
    }

    // Maintenance mode
    if (bot.state.maintenanceMode) {
      await conversation.send({
        type: "text",
        payload: {
          text: "The bot is currently under maintenance. Please try again later.",
        },
      });
      return;
    }

    // Business hours check (example)
    const supportHours = "9:00 AM to 5:00 PM EST";
    await conversation.send({
      type: "text",
      payload: { text: `Our support hours are ${supportHours}` },
    });
  },
});
```

## Best Practices

### 1. Use Environment Variables for Secrets

```typescript
// ❌ Bad - hardcoded secrets
config: {
  apiKey: "sk-abc123def456";
}

// ✅ Good - environment variable
config: {
  apiKey: process.env.OPENAI_API_KEY;
}
```

### 2. Validate Configuration

```typescript
export default defineConfig({
  name: validateBotName(process.env.BOT_NAME),

  user: {
    state: z.object({
      // Use strict validation
      email: z.string().email(),
      age: z.number().int().min(0).max(150),
    }),
  },
});
```

### 3. Provide Defaults

```typescript
user: {
  state: z.object({
    // Always provide sensible defaults
    language: z.string().default("en"),
    notifications: z.boolean().default(true),
    theme: z.enum(["light", "dark"]).default("light"),
  });
}
```

### 4. Document State Schema

```typescript
bot: {
  state: z.object({
    /**
     * Current version of the bot configuration
     * Increment when making breaking changes
     */
    version: z.number().default(1),

    /**
     * Feature flags for gradual rollout
     * @example { "newUI": true, "betaFeatures": false }
     */
    features: z.record(z.boolean()).default({}),
  });
}
```

### 5. Separate Concerns

```typescript
// Separate configuration by domain
const userConfig = {
  state: userStateSchema,
};

const botConfig = {
  state: botStateSchema,
};

const integrationConfig = {
  slack: slackConfig,
  discord: discordConfig,
};

export default defineConfig({
  ...baseConfig,
  user: userConfig,
  bot: botConfig,
});
```

## Project Files

### agent.json

The `agent.json` file stores bot and workspace IDs for deployment. This file is automatically created by `adk link` or `adk dev`.

```json
{
  "botId": "bot_abc123",
  "workspaceId": "ws_xyz789",
  "devId": "bot_dev_123"
}
```

**Fields:**

- `botId` - Production bot ID (used by `adk deploy`)
- `workspaceId` - Workspace ID
- `devId` - Development bot ID (used by `adk dev`)
- `apiUrl` - Optional Botpress API URL override (set by `adk link --api-url`)

**Important:**

- Add `agent.json` to `.gitignore` if you do not want environment-specific IDs committed
- Each developer/environment can have different IDs
- Created automatically by `adk link` or `adk dev`
- Current scaffolds do not add `agent.json` to `.gitignore` automatically

### package.json

Standard Node.js package file with ADK-specific scripts.

```json
{
  "scripts": {
    "dev": "adk dev",
    "build": "adk build",
    "deploy": "adk deploy"
  },
  "dependencies": {
    "@botpress/runtime": "workspace:*"
  }
}
```

See **[CLI Reference](./cli.md)** for complete command documentation.
