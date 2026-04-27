---
name: adk-build
description: Interview the user about a new ADK primitive, then build it
argument-hint: "<primitive> [description]"
---

Load the `adk` skill, then build the requested primitive immediately.

Resolve shorthand for the primitive type: "kb" / "knowledge" = knowledge base, "wf" = workflow, "convo" = conversation, "tool" = tool, "action" = action, "table" = table, "trigger" = trigger. Each maps to a directory under `src/` (`src/actions/`, `src/tools/`, `src/workflows/`, `src/conversations/`, `src/tables/`, `src/triggers/`, `src/knowledge/`). If the first argument is not a primitive type, ask which primitive the user wants to build before continuing.

## Workflow

1. **Read context first.** Glob `src/<primitive-dir>/` and read 1–2 existing primitives of the same type to match the project's naming, file structure, and import style. Read `agent.config.ts` to know which integrations and models are available.
2. **Interview only about *what*, never *how*.** Ask only outcome and behavior questions — what should this do, when should it happen from the user's perspective, what does success look like. Do not ask about schemas, return types, durability, retry policy, channel routing, storage shape, or any other implementation detail — infer those from the description, existing primitives, and sensible defaults.

   Examples of acceptable questions:
   - **Action / Tool:** "What should this do, in plain language?" "When should the agent reach for this?"
   - **Workflow:** "What outcome marks this as done?" "Can this pause and wait for a human, or is it fully automatic?"
   - **Conversation:** "What kind of user messages should this handle?"
   - **Table:** "What information does this need to remember about each row?"
   - **Trigger:** "What real-world event should kick this off?"
   - **Knowledge base:** "What questions should users be able to ask of this?"

   Ask 1–3 questions max, only when the description leaves a genuine outcome-level gap. If the description already conveys intent, skip the interview entirely.
3. **Propose a plan.** State the file path, the exports, the schema, and any dependencies (integrations to add, models needed). Wait for approval if the primitive is non-trivial or touches `agent.config.ts`.
4. **Build it.** Write the file under `src/<primitive-dir>/<name>.ts`. Use `@botpress/runtime` imports. Match the conventions you read in step 1.
5. **Validate.** Run `adk check --format json`. If errors, fix them before reporting done.
6. **Suggest next steps.** Offer `/adk-test <name>` to run it once and `/adk-eval <name>` to pin its behavior with assertions.
