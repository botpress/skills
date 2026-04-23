---
name: adk-explain
description: Explain an ADK bot's architecture, flow, and components
argument-hint: "[component or question about the bot]"
---

Help the user understand their Botpress ADK agent's architecture, flow, and specific components.

First, load the `adk` skill for general ADK context.

1. Run `adk status --format json` to get a structured overview of the project.
2. Read `agent.config.ts` for full configuration details.
3. Read `agent.json` for bot and workspace IDs (if present).
4. Read `agent.local.json` for the dev bot ID (if present).
5. Follow the explanation patterns in **references/explain-config.md** from the `adk` skill.
6. If `$ARGUMENTS` targets a specific component (e.g. a workflow, action, or integration), focus the explanation there. Otherwise, produce a full architecture overview covering metadata, models, integrations, state, and primitives.
7. Flag any issues found (unconfigured integrations, missing models, hardcoded secrets).
