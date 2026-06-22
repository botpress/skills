---
name: adk-test
description: Invoke an ADK primitive end-to-end with realistic input to confirm it works
argument-hint: '[primitive name] [input]'
---

Load the `adk` skill, then run the named primitive immediately.

This is exploratory, one-shot testing — _does it work right now?_. It is distinct from `/adk-eval`, which writes persistent assertion-based eval files. If the user wants assertions or coverage, route them there.

If `$ARGUMENTS` is empty, list the user's primitives and ask which to test.

## Workflow

1. **Locate and identify type.** Glob `src/**/<name>.ts`. The directory tells you the type (action / tool / workflow / conversation / table / trigger / knowledge base).
2. **Build an invocation appropriate for the type.** If the user provided input after the primitive name, use it as-is; otherwise generate a realistic probe from the primitive's schema:
   - **Tool / conversation handler / agent step:** `adk chat --single '<probe message that exercises this primitive>' --format json`. The probe should plausibly cause the LLM to call the tool / route to the handler. Single-quote the message — in double quotes the shell expands `$`, so a probe like `"I spent $5"` reaches the bot mangled.
   - **Action:** invoke through `adk run .adk/scratch/test-<name>.ts` after writing a small disposable runner under `.adk/scratch/`, or via a chat probe that triggers a tool which calls the action. Prefer the runner when the action has a deterministic input shape.
   - **Workflow:** trigger via the documented entry point (chat probe, action call, or trigger event).
   - **Trigger:** a `Trigger` fires on an external source event that usually can't be produced locally — invoke its handler directly via `adk run` with a synthetic event. (A Conversation's pushed `chat:custom` event is different: test it with an eval `event` turn and `adk evals` — see `/adk-eval`. `adk chat --single` only sends user text and can't push one.)
   - **Table:** insert a sample row, run a representative query, then **delete the row** before reporting. Tag the test row with a recognizable marker (e.g., a `__test_<timestamp>` value in a string column) so the cleanup query is unambiguous. If the project is linked to a shared or production workspace, ask the user before inserting at all — offer to scope the test to a local dev table instead.
   - **Knowledge base:** run a search query against it.
3. **Run it and read traces.** Capture the response. Run `adk traces --format json` filtered to the most recent invocation if the response alone is not enough to judge correctness.
4. **Report.** Show the input used, the output, latency, and any errors or surprising behavior. Be explicit if the trace shows the primitive was _not_ exercised (e.g., the LLM ignored the tool).
5. **Suggest follow-ups.** If the test surfaced something worth pinning down, offer `/adk-eval <name>` to capture it as a regression eval. If it failed, offer `/adk-debug` with the relevant context.

Clean up any disposable runner scripts under `.adk/scratch/test-*.ts` after the test unless the user asks to keep them.
