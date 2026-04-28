---
name: adk-dev-console
description: Explains the ADK Dev Console — what each tab shows, how to read Agent Steps, traces, and other UI features visible at localhost:3001 during adk dev
license: MIT
---

# ADK Dev Console

The Dev Console is a local app served at port `3001` (by default, but can be customized) during `adk dev`. It gives developers real-time visibility into their agent's behavior — conversations, execution traces, data, integrations, and configuration.

## When to Use This Skill

Activate when users ask about:

- **UI concepts** — "What are Agent Steps?", "What does the Observe tab show?", "What is a turn?"
- **Dev Console navigation** — "What tabs are available?", "Where do I find traces?", "How do I test RAG?"
- **Reading execution data** — "What do the steps mean?", "Why is my step red?", "What's the cost shown?"
- **Specific pages** — "How do I use the evals page?", "Where do I configure integrations?", "How do I search knowledge?"
- **Comparing UI vs CLI** — "Should I use the Dev Console or CLI for debugging?"
- Mentions of `localhost:3001`, "dev console", "Dev Console", or specific tab names (Chat, Build, Components, Data, Test, Observe, Config)

## Available Documentation

| File | Contents |
|------|----------|
| `references/agent-steps.md` | Agent Steps visualization — turns, iterations, tools, messages, state mutations, cost tracking, status indicators |
| `references/pages.md` | Every page/tab in the Dev Console — what it shows, key features, layout |

## How to Answer

Match depth to the question:

- **"What is X?"** (e.g., "What are Agent Steps?") → One sentence definition + what the user sees. Don't dump the full data model.
- **"Where do I find X?"** → Name the tab group and page, give the URL path.
- **"How do I read X?"** → Explain the visual hierarchy and what each element means.
- **"What does this mean?"** (pointing at something in the UI) → Identify the component, explain its meaning.

## Quick Reference

### Tab Groups

| Group | Pages | Purpose |
|-------|-------|---------|
| **Chat** | Chat | Test the agent via webchat + see Agent Steps |
| **Build** | Story | Visual agent flow graph (feature-flagged) |
| **Components** | Actions, Workflows, Triggers | Browse and test bot primitives |
| **Test** | RAG Search, Evals | Test knowledge search and run automated evals |
| **Data** | Knowledge, Tables, Files | Manage knowledge bases, tables, and files |
| **Observe** | Conversations, Traces, Logs | View conversation history, execution traces, runtime logs |
| **Config** | Settings, Integrations | Agent config, secrets, LLM settings, integration management |

### Agent Steps (Chat Page)

The right panel of the Chat page shows **Agent Steps** — a real-time visualization of what the agent did to process each message.

**Hierarchy:** Turn → Iterations → Tools / Messages / State Mutations

- **Turn** = one conversation exchange (user message → agent processing → response)
- **Iteration** = one loop of the autonomous agent (think → decide → act)
- **Tool** = a tool call within an iteration (violet card)
- **Message** = a bot message sent (blue card)
- **State Mutation** = a state change (teal card, shows before/after)

**Status indicators:** ✓ green = ok, ✗ red = error, ⟳ blue spinning = running

**AI metrics per iteration:** model name, input/output tokens, cost (USD)

### Key URLs

| Path | Page |
|------|------|
| `/chat` | Chat + Agent Steps |
| `/actions` | Actions browser |
| `/workflows` | Workflows + run history |
| `/search` | RAG search testing |
| `/evals` | Eval definitions + runs |
| `/knowledge` | Knowledge base management |
| `/tables` | Table data management |
| `/traces` | Full trace viewer |
| `/conversations` | Conversation history |
| `/logs` | Runtime logs |
| `/settings` | Agent configuration |
| `/integrations` | Integration management |
