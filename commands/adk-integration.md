---
name: adk-integration
description: Discover, add, and configure Botpress integrations
argument-hint: "[integration name or question]"
---

Help the user manage Botpress integrations in their ADK project.

First, load the `adk-integrations` skill for integration patterns. Also load the `adk` skill for general context.

1. Understand what the user needs from `$ARGUMENTS`.
2. Use CLI commands to get live data: `adk search`, `adk info`, `adk list`.
3. Confirm before running `adk add` or `adk rm` and always pin versions.
4. Explain configuration requirements (OAuth, API keys, Control Panel setup).

Follow the integration lifecycle patterns from the skill documentation.
