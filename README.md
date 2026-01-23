# ADK Documentation Skill

A skill for AI coding agents that provides comprehensive documentation for the Botpress Agent Development Kit (ADK).

## Procedure

```bash
# Using the agent-skills CLI
npx skills add botpress/adk-skills
```

Or manually add to your agent's skills directory.

## What's Included

This skill provides documentation for building AI agents with the Botpress ADK:

### Core Concepts
- **Actions** - Strongly-typed functions with validation
- **Tools** - AI-callable tools for autonomous execution
- **Workflows** - Long-running, resumable processes
- **Conversations** - Message handlers and routing
- **Triggers** - Event-driven automation

### Data & Content
- **Tables** - Structured storage with semantic search
- **Files** - File storage and management
- **Knowledge Bases** - RAG implementation

### AI Features
- **Zai** - Production-ready LLM utility library (extract, check, label, summarize, etc.)

### Configuration & Integration
- **Agent Config** - Bot configuration and state management
- **Integration Actions** - Using third-party integrations
- **Context API** - Runtime context access
- **CLI Reference** - Complete command reference
- **MCP Server** - AI assistant integration

### Frontend Integration
- **Botpress Client** - Using @botpress/client
- **Calling Actions** - Frontend to bot communication
- **Type Generation** - Type-safe integration
- **Authentication** - PAT-based auth patterns

## Usage

Once installed, your AI agent will automatically use this skill when you ask ADK-related questions like:

- "How do I create an Action?"
- "What's the difference between Actions and Tools?"
- "Show me how to use Zai for extraction"
- "How do I call integration actions?"
- "What are ADK best practices?"

## Structure

```
adk-skills/
├── SKILL.md          # Agent instructions
└── docs/             # Documentation files
    ├── actions.md
    ├── tools.md
    ├── workflows.md
    ├── ...
    └── frontend/
        ├── authentication.md
        ├── botpress-client.md
        └── ...
```

## License

MIT
