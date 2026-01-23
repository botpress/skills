# Configuration

Configure your bot's behavior, integrations, dependencies, and global state through the unified `agent.config.ts` file.

> **Note:** As of ADK 1.9+, `dependencies.json` has been removed. All configuration including integrations now lives in `agent.config.ts`.

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

  // Dependencies (integrations) - replaces dependencies.json as of ADK 1.9+
  dependencies: {
    integrations: {
      chat: { version: "chat@0.7.3", enabled: true },
      webchat: { version: "webchat@0.3.0", enabled: true },
      slack: {
        version: "slack@2.5.5",
        enabled: true,
        config: {
          botToken: process.env.SLACK_BOT_TOKEN,
        },
      },
    },
  },
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

Access via Context API:

```typescript
const config = context.get("configuration");
if (config.featureFlags.enableBetaFeatures) {
  // Use beta features
}
```

See **[Context API](./context-api.md)** for details on accessing configuration at runtime.

### Model Configuration

**Default Models:**

If you don't specify `defaultModels`, the ADK uses these defaults:
- `zai`: `"openai:gpt-4.1-2025-04-14"`
- `autonomous`: `"openai:gpt-4.1-mini-2025-04-14"`

**Available Models:**

```typescript
// OpenAI
"openai:gpt-4o"
"openai:gpt-4o-mini"
"openai:gpt-4-turbo"
"openai:gpt-4.1-2025-04-14"
"openai:gpt-4.1-mini-2025-04-14"

// Anthropic
"anthropic:claude-3-5-sonnet"
"anthropic:claude-3-opus"
"anthropic:claude-3-haiku"

// Google
"google:gemini-1.5-pro"
"google:gemini-1.5-flash"
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

## Dependencies Configuration

> **Note:** As of ADK 1.9+, dependencies are configured directly in `agent.config.ts`. The separate `dependencies.json` file has been removed.

### Dependencies Example

```typescript
import { defineConfig, z } from "@botpress/runtime";

export default defineConfig({
  name: "customer-support-bot",

  defaultModels: {
    autonomous: "openai:gpt-4.1-mini-2025-04-14",
    zai: "openai:gpt-4.1-mini-2025-04-14",
  },

  dependencies: {
    integrations: {
      // Chat channels
      chat: { version: "chat@0.7.3", enabled: true },
      webchat: { version: "webchat@0.3.0", enabled: true },

      // Slack Integration
      slack: {
        version: "slack@2.5.5",
        enabled: true,
        config: {
          botToken: process.env.SLACK_BOT_TOKEN,
          signingSecret: process.env.SLACK_SIGNING_SECRET,
        },
      },

      // Linear Integration
      linear: {
        version: "agi/linear@2.0.0",
        enabled: true,
        configurationType: "apiKey",
        config: {
          apiKey: process.env.LINEAR_API_KEY,
        },
      },

      // Browser Integration (for web scraping)
      browser: {
        version: "browser@0.8.1",
        enabled: true,
      },

      // Organization-scoped integration
      intercom: {
        version: "vertical-one/intercom@1.0.1",
        enabled: true,
      },
    },
  },
});
```

### Integration Naming Conventions

**Version Patterns:**
- **Public integrations**: `name@version` (e.g., `slack@2.5.5`)
- **Organization integrations**: `org/name@version` (e.g., `vertical-one/intercom@1.0.1`)

**Example:**

```typescript
dependencies: {
  integrations: {
    // Public integration
    slack: { version: "slack@2.5.5", enabled: true },

    // Organization-scoped integration
    intercom: { version: "vertical-one/intercom@1.0.1", enabled: true },

    // With configuration
    browser: {
      version: "browser@0.8.1",
      enabled: true,
      config: { /* integration-specific config */ },
    },
  },
}
```

### Managing Dependencies

Use the ADK CLI to manage integrations. See **[CLI Reference](./cli.md)** for commands:
- `adk add` - Add an integration
- `adk upgrade` - Upgrade integration(s)
- `adk remove` - Remove an integration
- `adk search` - Search for integrations
- `adk list` - List installed/available integrations

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

# ADK Development (CLI-specific)
ADK_DEV_PORT=3000           # Bot port (default: 3000)
ADK_CONSOLE_PORT=3001       # UI console port (default: 3001)
DEBUG=adk:*                 # Enable ADK debug logs

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
  async handler(input) {
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

The `agent.json` file stores bot and workspace IDs for deployment. This file is automatically created by `adk link` or `adk dev` and should be gitignored.

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

**Important:**

- Add `agent.json` to `.gitignore`
- Each developer/environment can have different IDs
- Created automatically by `adk link` or `adk dev`

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
