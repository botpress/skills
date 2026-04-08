---
name: adk-debug
description: Debug ADK bot issues
argument-hint: [error or problem description]
---

Help the user debug issues with their Botpress ADK bot.

First, load the `adk-debugger` skill for systematic debugging patterns. Also load the `adk` skill for general ADK context.

1. Understand the problem from `$ARGUMENTS`.
2. Run `adk check --format json` to rule out offline issues first.
3. Reproduce with `adk chat --single "<relevant message>" --format json`.
4. Read traces and logs: `adk logs error --format json`, `adk traces --format json`.
5. Identify root cause using the debug workflow from the skill.
6. Suggest a targeted fix.
7. Verify the fix and suggest a regression eval.
