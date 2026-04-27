---
name: adk-init
description: Scaffold a new Botpress ADK project
argument-hint: "[project-name]"
---

Help the user initialize a new Botpress ADK project.

First, load the `adk` skill for full ADK knowledge.

1. If `$ARGUMENTS` contains a project name, use it. Otherwise ask.
2. Ensure the user is logged in (`adk login --token "$BOTPRESS_TOKEN"` or `adk login`).
3. Run `adk init <name> --yes --skip-link --template hello-world` to scaffold the project.
4. Guide through linking with `adk link` and initial configuration.
5. Verify the project starts cleanly: `adk check --format json`.

## After Scaffolding

Don't just explain the project structure — ask what they want to build and guide next steps:

*"Your project is ready. What are you building?"*

- **Support agent** → suggest adding a conversation handler, ticket table, and relevant integrations (Slack, Linear, etc.)
- **Knowledge-base Q&A** → suggest creating a knowledge base in `src/knowledge/` and a search tool
- **Multi-channel bot** → suggest adding channel integrations (Slack, WhatsApp, Webchat) and a conversation handler
- **Automation** → suggest creating workflows and triggers

Then offer the relevant commands: `/adk-integration` to add services, `/adk-eval` to set up tests.

Follow all ADK CLI best practices from the skill documentation.
