# Interfaces

Interfaces are an abstraction layer over integrations. They define a standard contract (a set of actions) that multiple integrations can implement. The ADK uses interfaces to call the same logical action across different integrations without writing integration-specific code.

## Key Concepts

- **Interfaces are built-in.** The ADK automatically includes a fixed set of interfaces in every project. Users do not add or remove interfaces manually.
- **Interfaces map to integration actions.** At build time, the ADK discovers which installed integrations implement each interface and generates a mapping from interface actions to concrete integration actions.
- **The runtime resolves calls automatically.** When code calls an interface action (e.g., `startTypingIndicator`), the runtime looks up the correct integration action for the current conversation's integration.

## Built-in Interfaces

Every ADK project includes these interfaces (defined in `@botpress/adk` constants):

| Interface | Version | Purpose |
|-----------|---------|---------|
| `typing-indicator` | `0.0.3` | Start/stop typing indicators across messaging integrations |
| `llm` | `9.0.0` | Standard LLM operations |
| `listable` | `0.0.2` | List operations on integration resources |

These are hard-coded in the ADK and synced automatically during `adk dev` and `adk build`. Users cannot modify this list.

## How Interface Mapping Works

### Build Time

1. The ADK fetches interface definitions from the Botpress API.
2. For each interface, it checks which installed integrations implement it (by matching interface name and major version).
3. It generates typed action mappings in `.adk/interfaces/` that map `"integrationAlias:interfaceAction"` to `"integrationAlias:integrationAction"`.

Example generated mapping (from the typing-indicator interface with webchat installed):

```typescript
// Auto-generated in .adk/interfaces/typing_indicator/actions.ts
export const Interface_Actions_TypingIndicator = {
  "webchat:startTypingIndicator": "webchat:startTypingIndicator",
  "webchat:stopTypingIndicator": "webchat:stopTypingIndicator",
};
```

When the interface action name and the integration action name are the same, the mapping is a direct pass-through. When they differ, the mapping translates one to the other.

### Runtime

At startup, the generated `Interfaces` object is passed to the agent registry as `interfacesMapping`. The runtime's `InterfaceMappings` singleton provides a lookup:

```typescript
interfaceMappings.getIntegrationAction(interfaceName, actionName, integrationName)
```

This returns the concrete integration action string (e.g., `"webchat:startTypingIndicator"`) or `undefined` if the integration does not implement the interface.

### Concrete Example: Typing Indicators

The `conversation.startTyping()` and `conversation.stopTyping()` methods use the `typingIndicator` interface internally:

```typescript
// Inside the runtime's ConversationInstance:
async startTyping() {
  const mapping = interfaceMappings.getIntegrationAction(
    'typingIndicator',         // interface name
    'startTypingIndicator',    // interface action
    this.integration           // current integration alias (e.g., "webchat")
  );

  if (mapping) {
    await this.client.callAction({
      type: mapping,           // resolves to "webchat:startTypingIndicator"
      input: { conversationId: this.id, messageId: message?.id || '' },
    });
  }
}
```

This means `conversation.startTyping()` works for any integration that implements the `typing-indicator` interface (webchat, Slack, etc.) without any integration-specific code in the conversation handler.

## What Users See

### In Conversation Handlers

Users call `conversation.startTyping()` and `conversation.stopTyping()` without thinking about interfaces. The interface resolution is invisible:

```typescript
import { Conversation } from "@botpress/runtime";

export const Chat = new Conversation({
  channel: "webchat.channel",

  async handler({ conversation, execute }) {
    await conversation.startTyping();

    // Do work...

    await execute({
      instructions: "Help the user",
    });
    // Typing stops automatically when a message is sent
  }
});
```

If the conversation's integration does not implement `typing-indicator`, the calls silently no-op (errors are caught and swallowed).

### CLI Commands

```bash
# List built-in interfaces
adk interfaces list

# Show details about a specific interface
adk interfaces info llm

# Both commands support --format json
adk interfaces list --format json
```

### Generated Type Files

The ADK generates interface types in `.adk/interfaces/`. Each interface gets:

- `<interface_name>/index.ts` - Type and const exports
- `<interface_name>/actions.ts` - Per-integration action types and mapping constants

These are aggregated in:
- `.adk/interfaces.d.ts` - Global `Interfaces` type declaration
- `.adk/interfaces.ts` - Runtime `Interfaces` const (the mapping object)

## Relationship to Integrations

Interfaces and integrations are complementary. See **[integrations.md](./integrations.md)** for integration management.

- **Integrations** are concrete connections to external services (Slack, webchat, Linear). You add them with `adk add`.
- **Interfaces** are abstract contracts. An integration *implements* an interface by declaring compatible actions with matching schemas.
- When you add an integration that implements an interface, the ADK automatically detects this and generates the mapping. No user action is required.

## Scope and Limitations

- Interfaces are **not user-configurable** in the current ADK. The set of built-in interfaces is fixed.
- Users cannot define custom interfaces or map integrations to interfaces manually.
- Interface resolution is **per-integration** at the conversation level. The runtime determines which integration a conversation belongs to and resolves interface actions accordingly.
- If no installed integration implements an interface, the generated mapping for that interface will be empty (no actions).
- The `llm` and `listable` interfaces may have empty mappings if no installed integration declares support for them.
