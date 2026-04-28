---
name: adk-explain
description: Explain an ADK bot's architecture, flow, and components
argument-hint: "[component or question about the bot]"
---

Load the `adk` skill, then answer the user's question about **$ARGUMENTS** immediately.

Resolve shorthand first: "kbs" = knowledge bases, "convos" = conversations, "wf" = workflows, "int" = integrations, "config" = agent.config.ts.

If the user named a specific ADK concept or primitive, look it up in the `adk` skill's references and explain it. Match depth to the question — a one-word topic like "kbs" is a conceptual question: give a one-sentence explanation and a short code example from the references, then stop.

If the user is in an ADK project (check for `agent.config.ts`), also check whether their project uses the component they asked about. If it does, read the relevant source files in `src/` and explain *their specific setup* — not just the generic concept.

If the user asks a broad question ("explain my bot", "what does this do?", or no arguments):

1. Run `adk status --format json`.
2. Read `agent.config.ts` and relevant source files in `src/`.
3. Identify the bot archetype (RAG assistant, support agent, ticket router, automation, etc.).
4. Map the flow: channels → conversations → tools/actions → tables/KBs.
5. Flag any issues (unconfigured integrations, missing models, hardcoded secrets).
6. Follow the explanation patterns in **references/explain-config.md** from the `adk` skill.
