---
name: adk-debug
description: Debug ADK bot issues
argument-hint: "[error or problem description]"
---

Load the `adk-debugger` and `adk` skills, then start debugging immediately.

If `$ARGUMENTS` is vague ("broken", "not working", "slow", "weird", or empty), don't ask "what's wrong?" — investigate first. Run `adk check --format json` and `adk logs error --format json`, then present what you found.

If `$ARGUMENTS` mentions a specific component ("the search tool", "my workflow"), go directly to traces filtered by that component.

If `$ARGUMENTS` contains a pasted error or stack trace, read the file at the referenced line number immediately.

## Debug Workflow

1. Run `adk check --format json` to rule out offline issues first.
2. Reproduce with `adk chat --single "<relevant message>" --format json`.
3. Read traces and logs: `adk logs error --format json`, `adk traces --format json`.
4. Identify root cause using the debug workflow from the skill.
5. Suggest a targeted fix.
6. Verify the fix with another `adk chat` or `adk check`.
7. Write a regression eval for the bug — load the `adk-evals` skill, generate the eval file using the reproduction message as the user turn and the verified behavior as assertions, save it to `evals/`, and run `adk evals <name>` to confirm it passes.
