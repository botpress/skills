---
name: adk-validate
description: Validate an ADK primitive or a feature (a set of related primitives)
argument-hint: "[primitive or feature name]"
---

Load the `adk` skill, then validate the named target immediately.

The target can be either a **single primitive** (one file under `src/`, e.g. a tool called `search` or a workflow called `checkout`) or a **feature** — a piece of bot functionality spread across multiple primitives (e.g. "checkout" implemented as `src/workflows/checkout.ts` + `src/actions/process-payment.ts` + `src/tables/orders.ts`). Resolve which one before validating.

This is the proactive counterpart to `/adk-debug`: nothing is necessarily broken — confirm the target is correctly defined and wired up. If `$ARGUMENTS` is empty, list the user's primitives (Glob `src/**/*.ts` excluding `utils/`) and ask which one to validate.

## Workflow

1. **Run baseline checks first, in parallel.** TypeScript type check (the project's `typecheck` / `type-check` script in `package.json` if defined, otherwise `tsc --noEmit`) and `adk check --format json`. Capture both outputs. If either fails project-wide for reasons unrelated to the named primitive, surface that up front — the primitive's own issues are noise until the project compiles.
2. **Resolve the target — primitive or feature.** Try in this order:
   - **Exact primitive match.** Glob `src/**/<name>.ts`. If exactly one file matches, that's the target.
   - **Multiple primitive matches.** List them with their types (action / tool / workflow / etc.) and ask which one — or whether the user wants to validate the whole set as a feature.
   - **No exact match — treat as a feature.** Search the codebase for the term: file names, exported symbols, string literals, and comments under `src/`. Present the candidate set ("Found these files that look like the *<name>* feature: …") and confirm with the user before proceeding. If nothing plausible turns up, suggest the closest exact filename hits and stop.
3. **Read each file in the target set.** Identify the type of each from its directory.
4. **Filter the baseline output.** From the type-check and `adk check` output captured in step 1, pull out diagnostics that mention any name or file path in the target set.
5. **Static checks** (read the sources and verify):
   - Imports come from `@botpress/runtime` (not the SDK).
   - Each primitive is exported in the shape the ADK expects for its type (see references in the `adk` skill).
   - Zod / schema definitions cover all inputs and outputs the code uses.
   - Any referenced integration is installed (`adk list --format json`) and configured in `agent.config.ts`.
   - Any referenced model is available in the project's model config.
   - Any referenced sibling primitive (table, action, tool) actually exists in `src/`.
   - **Feature-level only:** the primitives in the set actually wire together — e.g., the workflow's action calls resolve to existing actions, the table the workflow writes to matches the schema the action reads.
   - No hardcoded secrets, tokens, or API keys.
6. **Report.** Group findings as ❌ Errors → ⚠️ Warnings → ✅ Passed, with each finding tagged by file. For a feature target, also include a short "wiring" subsection that summarizes how the primitives connect. End with one line: *"Run `/adk-test <name>` to actually invoke it."* Do not apply fixes from this command — let the user decide which to take.
