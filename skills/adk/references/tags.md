# Tags

Tags are key-value pairs that can be attached to bots, users, conversations, and workflows. They provide a flexible way to track metadata, categorize entities, and store cross-handler state.

## Basic Concepts

### What are Tags?

- **Key-value pairs**: String keys with string values
- **Entity-scoped**: Available on bot, user, conversation, and workflow
- **Schema-defined**: Must be declared in `agent.config.ts`
- **Automatically persisted**: Changes are tracked and saved automatically
- **System vs Custom**: System tags (with `:`) are read-only

### Tag Types

| Type | Example Key | Description |
|------|-------------|-------------|
| **Custom** | `tier`, `region` | User-defined, read-write |
| **System** | `webchat:owner` | Integration-managed, read-only |

## Defining Tags

Tags must be defined in your `agent.config.ts` to be persisted:

### User Tags

```typescript
import { defineConfig, z } from "@botpress/runtime";

export default defineConfig({
  name: "my-bot",

  user: {
    // User state (mutable object data)
    state: z.object({
      preferences: z.object({}).passthrough(),
    }),

    // User tags (key-value pairs for categorization)
    tags: {
      tier: z.enum(["free", "pro", "enterprise"]),
      region: z.string(),
      source: z.string(),
      referralCode: z.string().optional(),
    },
  },
});
```

### Conversation Tags

```typescript
export default defineConfig({
  name: "my-bot",

  conversation: {
    tags: {
      category: z.string(),
      priority: z.enum(["low", "medium", "high", "urgent"]),
      assignedTo: z.string().optional(),
      department: z.string(),
    },
  },
});
```

### Bot Tags

```typescript
export default defineConfig({
  name: "my-bot",

  bot: {
    state: z.object({
      version: z.number().default(1),
    }),

    tags: {
      environment: z.enum(["development", "staging", "production"]),
      region: z.string(),
      version: z.string(),
    },
  },
});
```

### Workflow Tags

```typescript
export default defineConfig({
  name: "my-bot",

  workflow: {
    tags: {
      type: z.string(),
      priority: z.enum(["low", "normal", "high"]),
      createdBy: z.string(),
    },
  },
});
```

## Using Tags

### In Conversations

```typescript
import { Conversation, user, conversation } from "@botpress/runtime";

export default new Conversation({
  channel: "webchat.channel",

  async handler({ message }) {
    // Read user tags
    console.log(`User tier: ${user.tags.tier}`);
    console.log(`User region: ${user.tags.region}`);

    // Set user tags
    user.tags.tier = "pro";
    user.tags.source = "website";

    // Read conversation tags
    console.log(`Category: ${conversation.tags.category}`);

    // Set conversation tags
    conversation.tags.priority = "high";
    conversation.tags.department = "support";

    // Conditional logic based on tags
    if (user.tags.tier === "enterprise") {
      // Priority handling for enterprise users
      conversation.tags.priority = "urgent";
    }
  },
});
```

### In Workflows

```typescript
import { Workflow, z, bot } from "@botpress/runtime";

export const ProcessingWorkflow = new Workflow({
  name: "processing",
  input: z.object({ userId: z.string() }),

  async handler({ input, workflow, step }) {
    // Set workflow tags
    workflow.tags.type = "data-processing";
    workflow.tags.priority = "high";

    // Access bot tags
    console.log(`Environment: ${bot.tags.environment}`);

    await step("process", async () => {
      // Processing logic
    });

    return { success: true };
  },
});
```

### In Actions

```typescript
import { Action, z, user, conversation } from "@botpress/runtime";

export default new Action({
  name: "upgradeUser",
  input: z.object({
    newTier: z.enum(["free", "pro", "enterprise"]),
  }),
  output: z.object({ success: z.boolean() }),

  async handler(input) {
    const oldTier = user.tags.tier;

    // Update user tag
    user.tags.tier = input.newTier;

    // Log the upgrade in conversation
    conversation.tags.category = "upgrade";

    console.log(`Upgraded user from ${oldTier} to ${input.newTier}`);

    return { success: true };
  },
});
```

## Tags vs State

Understanding when to use tags versus state:

| Aspect | Tags | State |
|--------|------|-------|
| **Structure** | Flat key-value pairs | Nested objects |
| **Types** | Strings only | Any type (objects, arrays, numbers) |
| **Use case** | Categorization, filtering | Complex data storage |
| **Queryable** | Yes (via API) | Limited |
| **Size** | Small values | Larger structures |

### When to Use Tags

```typescript
// ✅ Good for tags - simple categorization
user.tags.tier = "pro";
user.tags.region = "us-east";
conversation.tags.priority = "high";

// ❌ Bad for tags - complex data belongs in state
user.tags.preferences = JSON.stringify({ theme: "dark" }); // Don't do this!
```

### When to Use State

```typescript
// ✅ Good for state - complex structures
user.state.preferences = {
  theme: "dark",
  notifications: true,
  language: "en",
};

user.state.history = [
  { action: "login", timestamp: new Date() },
  { action: "purchase", timestamp: new Date() },
];
```

## System Tags

System tags are managed by integrations and are **read-only**. They contain a colon (`:`) in their key.

### Common System Tags

```typescript
// Webchat system tags (read-only)
console.log(user.tags["webchat:owner"]); // User who initiated webchat
console.log(conversation.tags["webchat:sessionId"]); // Session identifier

// Integration-specific system tags
console.log(user.tags["slack:userId"]); // Slack user ID
console.log(conversation.tags["discord:channelId"]); // Discord channel
```

### System Tag Behavior

```typescript
// System tags are silently ignored when you try to set them
user.tags["webchat:owner"] = "new-value"; // No error, but no effect

// Only custom tags (without ':') can be modified
user.tags.tier = "enterprise"; // ✅ Works
user.tags.customField = "value"; // ✅ Works
```

## Advanced Patterns

### Tag-Based Routing

```typescript
import { Conversation, conversation, user } from "@botpress/runtime";

export default new Conversation({
  channel: "webchat.channel",

  async handler({ message, execute }) {
    // Route based on conversation priority
    const priority = conversation.tags.priority;

    if (priority === "urgent") {
      // Fast-track urgent conversations
      await execute({
        instructions: "This is an urgent request. Prioritize resolution.",
        model: "openai:gpt-4o", // Use best model
      });
    } else {
      await execute({
        instructions: "Help the user with their request.",
        model: "openai:gpt-4o-mini", // Cost-efficient model
      });
    }
  },
});
```

### Tag-Based Analytics

```typescript
import { Trigger } from "@botpress/runtime";
import { AnalyticsTable } from "../tables/Analytics";

export default new Trigger({
  name: "trackConversation",
  events: ["conversation.ended"],

  async handler({ event }) {
    const { conversationId, tags } = event.payload;

    // Store conversation metrics by tags
    await AnalyticsTable.createRows({
      rows: [
        {
          conversationId,
          category: tags.category || "uncategorized",
          priority: tags.priority || "normal",
          department: tags.department || "general",
          timestamp: new Date(),
        },
      ],
    });
  },
});
```

### Progressive Tag Collection

```typescript
import { Conversation, user, adk } from "@botpress/runtime";

export default new Conversation({
  channel: "webchat.channel",

  async handler({ message }) {
    // Infer and set tags from conversation
    if (!user.tags.region && message?.type === "text") {
      const region = await adk.zai.extract(
        message.payload.text,
        z.string().optional(),
        { instructions: "Extract geographic region if mentioned" }
      );

      if (region) {
        user.tags.region = region;
      }
    }

    // Set source tag if not already set
    if (!user.tags.source) {
      user.tags.source = "webchat";
    }
  },
});
```

### Tag Inheritance in Workflows

```typescript
import { Workflow, z, user, conversation } from "@botpress/runtime";

export const SupportWorkflow = new Workflow({
  name: "support",
  input: z.object({
    conversationId: z.string(),
    issue: z.string(),
  }),

  async handler({ input, workflow, step }) {
    // Inherit priority from user tier
    const tier = user.tags.tier;

    if (tier === "enterprise") {
      workflow.tags.priority = "high";
    } else if (tier === "pro") {
      workflow.tags.priority = "normal";
    } else {
      workflow.tags.priority = "low";
    }

    // Set workflow type
    workflow.tags.type = "support-ticket";

    await step("process", async () => {
      // Processing based on priority
    });

    return { processed: true };
  },
});
```

## Best Practices

### 1. Use Descriptive Tag Names

```typescript
// ✅ Good - clear purpose
tags: {
  subscriptionTier: z.enum(["free", "pro", "enterprise"]),
  acquisitionChannel: z.string(),
  supportPriority: z.enum(["low", "medium", "high"]),
}

// ❌ Bad - unclear
tags: {
  t: z.string(),
  lvl: z.string(),
  p: z.string(),
}
```

### 2. Use Enums for Constrained Values

```typescript
// ✅ Good - constrained values
tags: {
  status: z.enum(["active", "inactive", "suspended"]),
  tier: z.enum(["free", "pro", "enterprise"]),
}

// ❌ Bad - free-form strings prone to typos
tags: {
  status: z.string(), // Could be "active", "Active", "ACTIVE", etc.
}
```

### 3. Document Tag Purposes

```typescript
export default defineConfig({
  user: {
    tags: {
      /** Customer subscription level for feature gating */
      tier: z.enum(["free", "pro", "enterprise"]),

      /** Geographic region for compliance and routing */
      region: z.string(),

      /** How the user discovered the bot */
      acquisitionSource: z.string(),
    },
  },
});
```

### 4. Set Tags Early

```typescript
// Set identification tags early in the conversation
async handler({ message, type }) {
  if (type === "conversation_started") {
    // Set source immediately
    conversation.tags.source = "webchat";
    conversation.tags.startedAt = new Date().toISOString();
  }
}
```

### 5. Use Tags for Filtering, Not Storage

```typescript
// ✅ Good - tags for filtering/categorization
user.tags.tier = "enterprise";
conversation.tags.category = "billing";

// ❌ Bad - storing complex data in tags
user.tags.preferences = JSON.stringify({ notifications: true }); // Use state instead
```

## Troubleshooting

### Tags Not Persisting

1. **Check schema definition**: Tags must be defined in `agent.config.ts`
2. **Verify tag key**: Custom tags cannot contain `:`
3. **Check value type**: Tags only accept string values

```typescript
// ✅ Correct
user.tags.tier = "pro"; // String value

// ❌ Wrong - will be ignored or cause errors
user.tags.count = 5; // Number (should be string)
user.tags.active = true; // Boolean (should be string)
```

### System Tags Appearing Read-Only

System tags (containing `:`) are managed by integrations:

```typescript
// These are read-only - modifications are silently ignored
user.tags["webchat:owner"] = "new"; // No effect
conversation.tags["slack:channel"] = "new"; // No effect

// Only custom tags can be modified
user.tags.myCustomTag = "value"; // ✅ Works
```

### Tag Not in Schema Error

If you see errors about undefined tags, add them to your config:

```typescript
// Before: Tag not in schema
user.tags.newTag = "value"; // Warning: Tag not defined

// Fix: Add to agent.config.ts
export default defineConfig({
  user: {
    tags: {
      newTag: z.string(), // Now it will persist
    },
  },
});
```

## See Also

- **[Agent Configuration](./agent-config.md)** - Full agent.config.ts reference
- **[Conversations](./conversations.md)** - Using tags in conversation handlers
- **[Workflows](./workflows.md)** - Workflow tags and state management
- **[Context API](./context-api.md)** - Accessing bot, user, conversation context
