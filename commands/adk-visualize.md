---
name: adk-visualize
description: Generate a visual architecture diagram for an ADK bot
argument-hint: "[path to ADK project]"
---

Generate a dark-themed HTML flow diagram that visualizes the architecture of a Botpress ADK bot.

First, load the `agent-visualizer` skill for the visual design system and analysis steps. Also load the `adk` skill for general ADK context.

1. Determine the ADK project path from `$ARGUMENTS` or use the current working directory.
2. Verify it's an ADK project (has `agent.config.ts`).
3. Analyze the codebase following Step 1 in the skill.
4. Generate `flow-diagram.html` in the project root following Step 2.
5. Open the file with `open flow-diagram.html`.
