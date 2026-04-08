---
name: adk-eval
description: Write, run, or debug evals for an ADK bot
argument-hint: "[what to test]"
---

Help the user with ADK evals (automated conversation tests).

First, load the `adk-evals` skill for eval patterns and format. Also load the `adk` skill for general context.

1. Understand what the user wants to test from `$ARGUMENTS`.
2. If writing a new eval: create a complete eval file with realistic assertions.
3. If running evals: use `adk evals run` with appropriate flags.
4. If debugging a failing eval: inspect traces and identify the issue.

Follow the eval format, assertion types, and per-primitive testing patterns from the skill documentation.
