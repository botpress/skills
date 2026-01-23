# Conversations

Conversations handle incoming messages and route them based on channel. They're the primary interface between users and your bot, providing AI-powered responses and integration with workflows.

## Basic Concepts

### What are Conversations?
- **Channel-specific**: Each conversation handles a specific channel (chat, Slack, etc.)
- **Stateful**: Maintain state per conversation
- **AI-powered**: Built-in support for AI execution with tools and knowledge
- **Interactive**: Can trigger workflows and handle workflow requests

### File Location
- **Location**: `src/conversations/*.ts`
- **Auto-registration**: Files automatically register for their specified channel

## Creating Conversations

### Basic Structure

```typescript
import { Conversation, z } from "@botpress/runtime";

export const Chat = new Conversation({
  channel: "chat.channel", // Required: channel ID

  // Optional: Per-conversation state
  state: z.object({
    count: z.number().default(0),
    activeWorkflowId: z.string().optional()
  }),

  async handler({ message, state, conversation, execute, type, event, request }) {
    // Access conversation state via the state parameter
    state.count += 1;

    // Send messages via conversation instance
    await conversation.send({
      type: "text",
      payload: { text: "Hello!" }
    });

    // AI-powered response
    await execute({
      instructions: "You are a helpful assistant",
      tools: [searchTool],
      knowledge: [MyKnowledgeBase]
    });
  }
});
```

### Handler Parameters

```typescript
async handler({ message, state, conversation, execute, type, event, request, client }) {
  // message - Incoming message object
  // state - Conversation state (mutable, automatically tracked)
  // conversation - Conversation instance with send() and other methods
  // execute - AI execution function
  // type - Event type (message, workflow_request, etc.)
  // event - Raw event
  // request - Workflow request object (if applicable)
  // client - BotClient for API calls
}
```

## Common Channel IDs

Different platforms have different channel IDs:

```typescript
// Botpress Chat
channel: "chat.channel"

// Slack
channel: "slack.dm"      // Direct messages
channel: "slack.channel" // Channel messages

// Discord
channel: "discord.dm"
channel: "discord.channel"

// WhatsApp
channel: "whatsapp.channel"

// Webchat
channel: "webchat.channel"

// Teams
channel: "teams.dm"
channel: "teams.channel"
```

## Message Handling

### Basic Message Processing

```typescript
export const Chat = new Conversation({
  channel: "chat.channel",

  async handler({ message, conversation, execute }) {
    // Check message type
    if (message?.type === "text") {
      const text = message.payload.text;

      // Command handling
      if (text.startsWith("/help")) {
        await conversation.send({
          type: "text",
          payload: { text: "Available commands:\n/help - Show help\n/status - Check status" }
        });
        return;
      }

      // Regular message - use AI
      await execute({
        instructions: "Help the user with their request"
      });
    }

    // Handle other message types
    if (message?.type === "image") {
      await conversation.send({
        type: "text",
        payload: { text: "I received your image!" }
      });
    }
  }
});
```

See **[Messages](./messages.md)** for complete guide on all message types, metadata, and sending patterns.

## Conversation Instance Methods

The `conversation` object provides methods for interacting with the current conversation.

### conversation.send()

Send messages to the conversation:

```typescript
// Send text message
await conversation.send({
  type: "text",
  payload: { text: "Hello!" }
});

// Send choice message
await conversation.send({
  type: "choice",
  payload: {
    text: "Choose an option:",
    options: [
      { label: "Option 1", value: "opt1" },
      { label: "Option 2", value: "opt2" }
    ]
  }
});
```

See **[Messages](./messages.md)** for all message types and payloads.

### conversation.startTyping()

Show typing indicator to the user:

```typescript
export const Chat = new Conversation({
  channel: "chat.channel",

  async handler({ conversation }) {
    // Start typing indicator
    await conversation.startTyping();

    // Do some work (API call, processing, etc.)
    await fetchData();

    // Send message (stops typing automatically)
    await conversation.send({
      type: "text",
      payload: { text: "Here's the data!" }
    });
  }
});
```

### conversation.stopTyping()

Manually stop typing indicator:

```typescript
export const Chat = new Conversation({
  channel: "chat.channel",

  async handler({ conversation }) {
    await conversation.startTyping();

    try {
      const result = await riskyOperation();
      await conversation.send({
        type: "text",
        payload: { text: result }
      });
    } catch (error) {
      // Stop typing if sending fails
      await conversation.stopTyping();
      throw error;
    }
  }
});
```

### conversation.tags

Access and modify conversation tags:

```typescript
// Read tags
const priority = conversation.tags.priority;
const category = conversation.tags.category;

// Set tags
conversation.tags.priority = "high";
conversation.tags.category = "support";
```

See **[Tags](./tags.md)** for complete tag documentation.

### Conversation Properties

```typescript
// Conversation ID
const id = conversation.id;

// Channel information
const channel = conversation.channel;        // e.g., "webchat.channel"
const integration = conversation.integration; // e.g., "webchat"
const alias = conversation.alias;            // Integration alias
```

## AI Execution

### Basic AI Integration

```typescript
export const Chat = new Conversation({
  channel: "chat.channel",

  async handler({ message, execute }) {
    await execute({
      instructions: "You are a helpful customer support assistant",

      // Optional: Add tools
      tools: [searchTool, createTicketTool],

      // Optional: Add knowledge bases
      knowledge: [DocsKnowledgeBase, FAQKnowledgeBase],

      // Optional: Model configuration
      model: "openai:gpt-4o",
      temperature: 0.7,

      // Optional: Execution hooks
      hooks: {
        onTrace: ({ trace }) => console.log(trace),
        onIterationEnd: async (iteration) => {
          if (iteration.isFailed()) {
            console.log("Iteration failed:", iteration.error);
          }
        }
      }
    });
  }
});
```

See **[Actions](./actions.md#converting-actions-to-tools)** for converting actions to tools with `.asTool()`.

## State Management

### Conversation State

Each conversation maintains its own state:

```typescript
export const Chat = new Conversation({
  channel: "chat.channel",

  state: z.object({
    messageCount: z.number().default(0),
    userName: z.string().optional(),
    preferences: z.object({
      language: z.string().default("en"),
      theme: z.string().default("light")
    }).default({})
  }),

  async handler({ message, state, conversation }) {
    // Access and modify state via the state parameter
    state.messageCount += 1;

    if (!state.userName && message?.type === "text") {
      state.userName = message.payload.text;
      await conversation.send({
        type: "text",
        payload: { text: `Nice to meet you, ${state.userName}!` }
      });
    }

    // State persists across messages
    if (state.messageCount > 10) {
      await conversation.send({
        type: "text",
        payload: { text: "Thanks for being an active user!" }
      });
    }
  }
});
```

## Workflow Integration

### Starting Workflows from Conversations

```typescript
export const Chat = new Conversation({
  channel: "chat.channel",
  state: z.object({
    activeWorkflowId: z.string().optional()
  }),

  async handler({ message, state, conversation }) {
    const text = message?.payload.text || "";

    if (text.startsWith("/process")) {
      // Start workflow with conversation context
      const instance = await ProcessWorkflow.start({
        conversationId: conversation.id, // Critical for communication!
        userId: user.id,
        data: text.substring(8)
      });

      // Store workflow ID
      state.activeWorkflowId = instance.id;

      await conversation.send({
        type: "text",
        payload: { text: `Started processing: ${instance.id}` }
      });
      return;
    }

    if (text === "/status" && state.activeWorkflowId) {
      // Check workflow status
      const instance = await ProcessWorkflow.get({
        id: state.activeWorkflowId
      });

      await conversation.send({
        type: "text",
        payload: {
          text: `Status: ${instance?.status || "Not found"}`
        }
      });
      return;
    }
  }
});
```

### Handling Workflow Requests

Workflows can request data from conversations using `step.request()`. The conversation receives a `workflow_request` type with the request object.

**Request Object Structure:**
```typescript
type WorkflowRequest = {
  type: `${WorkflowName}:${RequestName}`;  // e.g., "processOrder:email"
  workflow: BaseWorkflowInstance;           // Workflow instance
  step: string;                             // Step name
}
```

**Pattern 1: Using Request Object (Type-Safe)**

```typescript
export const Chat = new Conversation({
  channel: "chat.channel",

  async handler({ type, request, conversation, message }) {
    // Check request type (type-safe)
    if (type === "workflow_request" && request.type === "processOrder:email") {
      // Extract user input
      const email = message?.payload.text || "user@example.com";

      // Provide data back to workflow
      await request.workflow.provide("email", { email });
      return;
    }
  }
});
```

**Pattern 2: Using Event with Type Guard (Access to Prompt)**

```typescript
import { isWorkflowDataRequest } from "@botpress/runtime";

export const Chat = new Conversation({
  channel: "chat.channel",

  async handler({ event, conversation }) {
    // Type guard gives access to event.payload
    if (isWorkflowDataRequest(event)) {
      // event.payload.message contains the prompt from step.request()
      await conversation.send({
        type: "text",
        payload: { text: event.payload.message }
      });

      // Get user input (from state or next message)
      const userInput = getUserInput();

      // Provide data using static method
      await MyWorkflow.provide(event, { data: userInput });
      return;
    }
  }
});
```

See **[Workflows](./workflows.md#conversation-communication)** for complete workflow request patterns including state management and multiple request types.

## Command Handling

### Implementing Commands

```typescript
export const Chat = new Conversation({
  channel: "chat.channel",

  async handler({ message, conversation, execute }) {
    if (message?.type !== "text") return;

    const text = message.payload.text;
    const command = text.split(" ")[0].toLowerCase();
    const args = text.substring(command.length).trim();

    switch (command) {
      case "/help":
        await conversation.send({
          type: "text",
          payload: {
            text: `Available commands:
/help - Show this help
/search <query> - Search knowledge base
/refresh - Refresh knowledge base
/workflow <data> - Start workflow`
          }
        });
        break;

      case "/search":
        const results = await MyKnowledgeBase.search({ query: args, limit: 5 });
        await conversation.send({
          type: "text",
          payload: {
            text: results.length > 0
              ? `Found ${results.length} results:\n${results.join("\n")}`
              : "No results found"
          }
        });
        break;

      case "/refresh":
        await MyKnowledgeBase.refresh();
        await conversation.send({
          type: "text",
          payload: { text: "Knowledge base refreshed!" }
        });
        break;

      case "/workflow":
        const instance = await MyWorkflow.getOrCreate({
          key: user.id,
          input: { userId: user.id, data: args }
        });
        await conversation.send({
          type: "text",
          payload: { text: `Workflow ${instance.id} started` }
        });
        break;

      default:
        // Not a command, use AI
        await execute({
          instructions: "You are a helpful assistant",
          knowledge: [MyKnowledgeBase]
        });
    }
  }
});
```

## Advanced Patterns

### Multi-Channel Support

Create separate conversations for different channels:

```typescript
// src/conversations/slack-dm.ts
export const SlackDM = new Conversation({
  channel: "slack.dm",

  async handler({ message, execute }) {
    // Slack-specific handling
    if (message?.payload.thread_ts) {
      // Handle threaded messages
    }

    await execute({
      instructions: "You are a Slack assistant. Use Slack markdown formatting."
    });
  }
});

// src/conversations/slack-channel.ts
export const SlackChannel = new Conversation({
  channel: "slack.channel",

  async handler({ message, execute }) {
    // Only respond when mentioned
    if (!message?.payload.text?.includes("@bot")) {
      return; // Don't respond
    }

    await execute({
      instructions: "You are in a public Slack channel. Be concise."
    });
  }
});
```

### Conversation Context

Maintain context across messages:

```typescript
export const Chat = new Conversation({
  channel: "chat.channel",
  state: z.object({
    context: z.array(z.object({
      role: z.string(),
      content: z.string()
    })).default([])
  }),

  async handler({ message, state, execute }) {
    // Add user message to context
    if (message?.type === "text") {
      state.context.push({
        role: "user",
        content: message.payload.text
      });
    }

    // Keep last 10 messages
    if (state.context.length > 10) {
      state.context = state.context.slice(-10);
    }

    // Use context in AI execution
    await execute({
      instructions: `You are a helpful assistant.
Previous context:
${state.context.map(m => `${m.role}: ${m.content}`).join("\n")}`
    });
  }
});
```

### Context API & Chat Instance

Access the chat instance to read conversation history, register custom components, and build adaptive experiences.

#### Accessing the Chat Instance

```typescript
import { context, Conversation } from "@botpress/runtime";

export const Chat = new Conversation({
  channel: "webchat.channel",

  async handler({ message, execute, conversation }) {
    // Get the chat instance
    const chat = context.get("chat");

    // Fetch conversation transcript
    const transcript = await chat.fetchTranscript();

    // Analyze conversation history
    const messageCount = transcript.length;
    const hasImages = transcript.some(
      (msg) => msg.role === "user" && msg.attachments && msg.attachments.length > 0
    );

    console.log(`Conversation has ${messageCount} messages, includes images: ${hasImages}`);
  }
});
```

#### Adaptive Model Selection

Choose models dynamically based on conversation content (e.g., handle images with vision models):

```typescript
import { context, Conversation } from "@botpress/runtime";

export const Chat = new Conversation({
  channel: "webchat.channel",

  async handler({ message, execute, conversation }) {
    const chat = context.get("chat");
    const transcript = await chat.fetchTranscript();

    // Check if any user messages contain images
    const hasImages = transcript.some(
      (msg) => msg.role === "user" && msg.attachments?.length > 0
    );

    // Select appropriate model
    const model = hasImages
      ? "openai:gpt-4.1"        // Vision-capable model for images
      : "cerebras:gpt-oss-120b"; // Fast, cost-effective for text-only

    await execute({
      instructions: "You are a helpful assistant...",
      model,
      tools: [myTool]
    });
  }
});
```

**Use Cases:**
- **Cost Optimization**: Use cheaper/faster models for text-only conversations
- **Capability Matching**: Switch to vision models only when images are present
- **Context-Aware Responses**: Adapt behavior based on conversation history
- **Quality Control**: Use more powerful models for complex or lengthy conversations

#### Custom UI Components

Register custom components for rich UI interactions:

```typescript
import { Autonomous, context, Conversation, z } from "@botpress/runtime";

export const Copilot = new Conversation({
  channel: "webchat.channel",

  async handler({ message, execute, conversation }) {
    const chat = context.get("chat");

    // Register custom component
    chat.registerComponent({
      component: new Autonomous.Component({
        type: "leaf",
        name: "Answer",
        aliases: ["answer"],
        description: "Provide an answer with citations and markdown formatting",
        examples: [{
          name: "Answer",
          description: "Provide a concise answer to the user's question",
          code: `
            yield <Answer question="What is the capital of France?">
              The capital of France is **Paris**.
            </Answer>
          `
        }],
        leaf: {
          props: z.object({
            question: z.string().describe("The question to answer"),
            children: z.any().describe("The answer content (markdown supported)")
          }) as any
        }
      }),
      handler: async (props) => {
        // Extract text from children
        const text = props.children
          .filter((x) => typeof x === "string" || typeof x === "number" || typeof x === "boolean")
          .join("");

        // Send custom message
        await conversation.send({
          type: "custom",
          payload: {
            name: "copilot.answer",
            url: "builtin://components/copilot/answer",
            data: { text, question: props.props.question }
          }
        });
      }
    });

    // Now the AI can use the <Answer> component
    await execute({
      instructions: `You are a helpful assistant.
      When answering questions, use the <Answer> component with markdown formatting.`,
      tools: [searchTool]
    });
  }
});
```

**Component Use Cases:**
- **Rich Answers**: Formatted responses with citations and styling
- **Interactive Elements**: Buttons, forms, and action cards
- **Data Visualization**: Charts, tables, and structured data display
- **Custom Workflows**: Multi-step interactions with state

#### Chat Instance Methods

The chat instance provides methods for managing conversation transcripts and components.

**Transcript Management:**

```typescript
import { context } from "@botpress/runtime";

const chat = context.get("chat");

// Fetch transcript (loads from API)
const transcript = await chat.fetchTranscript();

// Get transcript (returns cached copy)
const cached = await chat.getTranscript();

// Set/replace entire transcript
await chat.setTranscript([
  { id: "1", role: "user", content: "Hello" },
  { id: "2", role: "assistant", content: "Hi there!" }
]);

// Clear all messages
await chat.clearTranscript();

// Prepend messages to beginning
await chat.prependToTranscript([
  { id: "0", role: "summary", content: "Previous conversation summary..." }
]);

// Remove specific message by ID
const removed = await chat.removeMessage("msg-123");

// Remove messages by predicate
const count = await chat.removeMessages(
  (item) => item.role === "assistant" && item.content.includes("error")
);

// Compact transcript (summarize/compress)
await chat.compactTranscript();

// Save transcript changes
await chat.saveTranscript();
```

**Component Management:**

```typescript
const chat = context.get("chat");

// Register component with handler
chat.registerComponent({
  component: myComponent,
  handler: async (props) => {
    // Handle component rendering
  }
});

// Remove component by name
chat.removeComponent("Answer");

// Get all registered components
const components = await chat.getComponents();
```

**Transcript Item Types:**

```typescript
type TranscriptUserMessage = {
  id: string;
  role: "user";
  content: string;
  name?: string;
  createdAt?: string;
  attachments?: Array<{ type: "image"; url: string }>;
};

type TranscriptAssistantMessage = {
  id: string;
  role: "assistant";
  content: string;
  name?: string;
  createdAt?: string;
};

type TranscriptEventMessage = {
  id: string;
  role: "event";
  name: string;
  payload: unknown;
  createdAt?: string;
};

type TranscriptSummaryMessage = {
  id: string;
  role: "summary";
  content: string;
};
```

#### Transcript Analysis Patterns

```typescript
import { context, Conversation } from "@botpress/runtime";

export const Chat = new Conversation({
  channel: "chat.channel",

  async handler({ message, execute }) {
    const chat = context.get("chat");
    const transcript = await chat.fetchTranscript();

    // Detect conversation patterns
    const userMessages = transcript.filter(msg => msg.role === "user");
    const hasRepeatedQuestion = userMessages.some((msg, idx) =>
      idx > 0 && msg.content === userMessages[idx - 1].content
    );

    if (hasRepeatedQuestion) {
      // User asked the same question twice - may need clarification
      await execute({
        instructions: `The user seems frustrated or confused.
        Provide extra clarification and ask if they need more help.`,
        tools: [searchTool]
      });
    } else {
      // Normal conversation flow
      await execute({
        instructions: "You are a helpful assistant",
        tools: [searchTool]
      });
    }
  }
});
```

**Analysis Patterns:**
- **Detect frustration**: Repeated questions, negative sentiment
- **Identify complexity**: Long conversations may need escalation
- **Track engagement**: Message frequency and length analysis
- **Content-based routing**: Images, files, code snippets

### Error Handling

```typescript
export const Chat = new Conversation({
  channel: "chat.channel",

  async handler({ message, conversation, execute }) {
    try {
      await execute({
        instructions: "You are a helpful assistant",
        tools: [riskyTool]
      });
    } catch (error) {
      console.error("Execution failed:", error);

      // Send error message to user
      await conversation.send({
        type: "text",
        payload: {
          text: "I apologize, but I encountered an error. Please try again later."
        }
      });

      // Optionally notify admins
      await notifyAdmins({
        error: error.message,
        conversationId: conversation.id
      });
    }
  }
});
```

## Best Practices

### 1. Handle All Message Types
```typescript
async handler({ message, conversation }) {
  switch (message?.type) {
    case "text":
      // Handle text
      break;
    case "image":
      // Handle image
      break;
    case "choice":
      // Handle choice selection
      break;
    default:
      // Handle unknown types
  }
}
```

### 2. Validate Input
```typescript
if (message?.type === "text") {
  const text = message.payload.text?.trim();
  if (!text || text.length > 1000) {
    await conversation.send({
      type: "text",
      payload: { text: "Please provide a valid message (1-1000 characters)" }
    });
    return;
  }
}
```

### 3. Use Early Returns
```typescript
async handler({ message, state, conversation, execute }) {
  // Handle commands first
  if (message?.payload.text?.startsWith("/")) {
    // Handle command inline
    return; // Early return
  }

  // Handle special cases
  if (state.waitingForInput) {
    // Handle input
    return; // Early return
  }

  // Default AI handling
  await execute({ instructions: "..." });
}
```

### 4. Provide Clear Instructions
```typescript
await execute({
  instructions: `You are a customer support assistant for ACME Corp.

Guidelines:
- Be helpful and professional
- Keep responses concise (under 100 words)
- Always verify customer identity before sharing sensitive info
- Escalate to human agent if customer seems frustrated

Current user: ${user.name}
Account type: ${user.accountType}`
});
```

### 5. Clean Up State
```typescript
// Reset state when conversation ends
async handler({ message, state, conversation }) {
  if (message?.payload.text === "/end") {
    // Reset state properties
    state.count = 0;
    state.userName = undefined;
    state.activeWorkflowId = undefined;

    await conversation.send({
      type: "text",
      payload: { text: "Conversation ended. State cleared." }
    });
  }
}
```