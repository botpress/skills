# Botpress Skills

<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset="./assets-dark.png">
        <img src="./assets-light.png">
    </picture>
</p>

A collection of skills for AI coding agents building with Botpress. Skills are packaged instructions and documentation that extend agent capabilities for Botpress development.

Skills follow the [Agent Skills](https://agentskills.io/) format.

## Available Skills

### botpress-adk

Comprehensive documentation and guidelines for building AI agents with the Botpress Agent Development Kit (ADK). A convention-based TypeScript framework where file structure maps directly to bot behavior.

**Use when:**

- Building new features with the Botpress ADK
- Working with Actions, Tools, or Workflows
- Implementing data storage (Tables, Files, Knowledge Bases)
- Using Zai for AI operations (extract, check, label, summarize)
- Configuring integrations or bot settings
- Setting up event-driven triggers
- Need CLI commands or MCP server setup

**Categories covered:**

- **Core Concepts** - Actions (strongly-typed functions), Tools (AI-callable), Workflows (long-running processes), Conversations (message handlers), Triggers (event-driven automation)
- **Data & Content** - Tables (structured storage with semantic search), Files (file storage and management), Knowledge Bases (RAG implementation)
- **AI Features** - Zai (production-ready LLM utility library for common AI operations)
- **Configuration** - Agent config, integration actions, context API, environment variables
- **Development Tools** - CLI reference, MCP server integration, project structure best practices

### botpress-adk-frontend

Production-tested patterns for building frontend applications that integrate with Botpress ADK bots. Covers authentication, type-safe API calls, client management, and type generation workflows.

**Use when:**

- Building a frontend that connects to a Botpress bot
- Implementing authentication with Personal Access Tokens (PATs)
- Setting up the @botpress/client
- Calling bot actions from React/Next.js
- Generating and using TypeScript types from your bot
- Managing client state and caching
- Handling errors and optimistic updates

**Categories covered:**

- **Authentication** - Cookie-based PAT storage, OAuth flow, route protection, token management
- **Client Management** - Zustand store patterns, client caching and reuse, workspace vs bot-scoped clients
- **Type Generation** - Triple-slash references, importing generated types, type-safe action calls
- **Action Calls** - React Query patterns, error handling, optimistic updates, proper typing

**Key technologies:**

- @botpress/client (official TypeScript client)
- TypeScript triple-slash references
- React Query (optional, recommended for mutations)
- Zustand (for client state management)

## Installation

```bash
npx skills add botpress/skills --skill adk
```

## Usage

Skills are automatically available once installed. The agent will use them when relevant tasks are detected.

**Examples:**

```
Create an Action that fetches user data
```

```
How do I use Zai to extract structured data?
```

```
Show me how to call my bot's actions from a Next.js frontend
```

```
Set up authentication for my React app with Botpress
```

## Skill Structure

Each skill contains:

- `SKILL.md` - Instructions for the agent
- `references/` - Supporting documentation files

```
skills/
├── adk/
│   ├── SKILL.md
│   └── references/
│       ├── actions.md
│       ├── tools.md
│       ├── workflows.md
│       └── ...
└── adk-frontend/
    ├── SKILL.md
    └── references/
        ├── authentication.md
        ├── botpress-client.md
        ├── calling-actions.md
        └── type-generation.md
```

## License

MIT
