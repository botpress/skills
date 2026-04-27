---
name: adk-build
description: Interview the user about a new ADK primitive, then build it
argument-hint: "<primitive> [description]"
---

Load the `adk` skill, then build the requested primitive immediately.

Resolve shorthand for the primitive type: "kb" / "knowledge" = knowledge base, "wf" = workflow, "convo" = conversation, "tool" = tool, "action" = action, "table" = table, "trigger" = trigger. Each maps to a directory under `src/` (`src/actions/`, `src/tools/`, `src/workflows/`, `src/conversations/`, `src/tables/`, `src/triggers/`, `src/knowledge/`). If the first argument is not a primitive type, ask which primitive the user wants to build before continuing.

## Workflow

1. **Read context first.** Glob `src/<primitive-dir>/` and read 1–2 existing primitives of the same type to match the project's naming, file structure, and import style. Read `agent.config.ts` to know which integrations and models are available.
2. **Interview only the gaps.** The user's description usually covers intent, not the schema. Ask focused questions about what is *not* in the description — input/output shape, trigger condition, integrations to call, durability, channel, etc. Match the primitive's needs:
   - **Action / Tool:** input schema, return type, side effects, which integration actions it calls. For tools, also: when should the AI call this (the LLM-facing description).
   - **Workflow:** entry point, steps, resume points, what completion looks like.
   - **Conversation:** channel(s), intents handled, expected response style.
   - **Table:** columns and types, semantic-search fields, row-level access.
   - **Trigger:** event source, filter conditions, downstream action.
   - **Knowledge base:** source documents, chunking, retrieval mode.

   Ask 1–3 questions at most. Do not interrogate. If the description is detailed enough, skip the interview.
3. **Propose a plan.** State the file path, the exports, the schema, and any dependencies (integrations to add, models needed). Wait for approval if the primitive is non-trivial or touches `agent.config.ts`.
4. **Build it.** Write the file under `src/<primitive-dir>/<name>.ts`. Use `@botpress/runtime` imports. Match the conventions you read in step 1.
5. **Validate.** Run `adk check --format json`. If errors, fix them before reporting done.
6. **Suggest next steps.** Offer `/adk-test <name>` to run it once and `/adk-eval <name>` to pin its behavior with assertions.
