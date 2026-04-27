---
name: adk-build
description: Interview the user about a new ADK primitive or feature, then build it
argument-hint: "[primitive] <description>"
---

Load the `adk` skill, then build the requested target immediately.

The target can be a **single primitive** (one file under `src/`, e.g. an action called `calculate-discount`) or a **feature** — a piece of bot functionality that needs several primitives wired together (e.g. a checkout flow = workflow + actions + table). The user does not need to know which it is. Decide based on `$ARGUMENTS`:

- If the first token is a primitive type — `action`, `tool`, `workflow`, `convo`/`conversation`, `table`, `trigger`, `kb`/`knowledge` — and the description fits one file, build a single primitive.
- Otherwise treat the whole argument as a feature description and decompose it into the primitives needed.

If `$ARGUMENTS` is empty or only a primitive type with no description, ask what the user wants to build (in outcome terms).

## Workflow

1. **Read context first.** Read `agent.config.ts` for available integrations and models. Glob `src/` and skim 1–2 existing primitives in each directory you expect to touch, to match the project's naming, file structure, and import style.

   **Conversation handlers — read every existing one.** Glob `src/conversations/*.ts` and read each file's `channel:` field, not just one or two of them. Build a map of `<file> → <channels>`. From that map:

   - **Default rule: extend, do not add.** If any existing handler routes through a channel set that overlaps with what the new behavior needs (and `*` overlaps with everything; identical arrays overlap; arrays sharing any one channel overlap), the new behavior must be added to that existing handler — new turn, new tool wiring, new state field, whatever — *not* a new file. Two conversation handlers with overlapping channels both fire on the same message and produce ambiguous routing; this is the failure mode the user has hit before.
   - **Only create a new file when channels are disjoint.** A new conversation file is justifiable when its channel set has zero overlap with every existing handler — e.g., a Slack-only handler when all existing handlers are `webchat.channel` only. State the disjointness explicitly in the plan (step 4).
   - **Or when the user asked for one.** If the user explicitly requested a separate handler ("a dedicated triage conversation distinct from the main chat"), honor that — but still call out the channel overlap in the plan so they can confirm.
2. **Interview only about *what*, never *how*.** Ask only outcome and behavior questions — what should this do, when should it happen from the user's perspective, what does success look like. Do not ask about schemas, return types, durability, retry policy, channel routing, storage shape, or *which primitives to use* — infer those from the description, existing primitives, and sensible defaults.

   Examples of acceptable questions:
   - "What should this do, in plain language?"
   - "When should it kick in — what's the user-visible trigger?"
   - "What does success look like when this is done?"
   - "Should this finish on its own, or pause and wait for someone?"
   - For a feature: "Is X part of this, or a separate thing?" — only when scope is genuinely ambiguous.

   Ask 1–3 questions max, only when the description leaves a genuine outcome-level gap. If the description already conveys intent, skip the interview entirely.
3. **Decompose (feature mode only).** From the outcome, identify the primitives needed and the directories they belong in (`src/workflows/`, `src/actions/`, `src/tables/`, etc.). State the decomposition explicitly in the plan — *"This needs a `checkout` workflow, a `process-payment` action, and an `orders` table because …"*.
4. **Propose a plan.** List every file to create or modify (full path), the exports, and any dependencies (integrations to add, models needed, `agent.config.ts` edits). For features, also describe how the primitives wire together. **If the plan involves a new conversation file**, include a one-line "channel-overlap check" justifying the new file (channels disjoint from every existing handler, or explicit user request) — if you can't justify it, fold the change into an existing handler instead. Wait for approval if the plan is non-trivial or touches `agent.config.ts`.
5. **Build it.** Write the files under the right `src/<dir>/` paths. Use `@botpress/runtime` imports. Match the conventions you read in step 1. For a feature, build the primitives in dependency order (table → action → workflow → conversation), so each file's imports resolve as it's written. For conversation behavior, edit the existing handler identified in step 1 — do not spawn a new one unless step 4's channel-overlap check explicitly justified it.
6. **Validate — always.** Run `adk check --format json` after every build, no exceptions. If it reports errors or warnings, fix them in this same turn and re-run. Do not report the task done until the check passes.
7. **Suggest next steps.** Offer `/adk-validate <name>` to confirm wiring (especially for a feature), `/adk-test <name>` to run it once, and `/adk-eval <name>` to pin its behavior with assertions.
