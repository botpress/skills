---
name: adk-frontend
description: Build frontend apps that integrate with ADK bots
argument-hint: [what to build or question]
---

Help the user build frontend integrations for Botpress ADK bots.

First, load the `adk-frontend` skill for production patterns. Also load the `adk` skill for general context.

1. Understand the user's frontend goal from `$ARGUMENTS`.
2. Follow production-tested patterns for authentication, client setup, type generation, and action calls.
3. Provide complete, working code examples with proper TypeScript types.
4. Use the service layer pattern and Zustand client store from the skill documentation.
