---
name: adk-validate
description: Validate an ADK primitive's schema, types, imports, and config dependencies
argument-hint: "[primitive name]"
---

Load the `adk` skill, then validate the named primitive immediately.

This is the proactive counterpart to `/adk-debug`: nothing is necessarily broken — confirm the primitive is correctly defined and wired up. If `$ARGUMENTS` is empty, list the user's primitives (Glob `src/**/*.ts` excluding `utils/`) and ask which one to validate.

## Workflow

1. **Run baseline checks first, in parallel.** TypeScript type check (the project's `typecheck` / `type-check` script in `package.json` if defined, otherwise `tsc --noEmit`) and `adk check --format json`. Capture both outputs. If either fails project-wide for reasons unrelated to the named primitive, surface that up front — the primitive's own issues are noise until the project compiles.
2. **Locate the primitive.** Glob `src/**/<name>.ts` to find it. If multiple matches, list them and ask which one. If no match, search by partial name and suggest the closest hits.
3. **Read it.** Open the file and identify its type from the directory (`actions/`, `tools/`, `workflows/`, etc.).
4. **Filter the baseline output.** From the type-check and `adk check` output captured in step 1, pull out diagnostics that mention the primitive's name or file path.
5. **Static checks** (read the source and verify):
   - Imports come from `@botpress/runtime` (not the SDK).
   - The primitive is exported in the shape the ADK expects for its type (see references in the `adk` skill).
   - Zod / schema definitions cover all inputs and outputs the code uses.
   - Any referenced integration is installed (`adk list --format json`) and configured in `agent.config.ts`.
   - Any referenced model is available in the project's model config.
   - Any referenced sibling primitive (table, action, tool) actually exists in `src/`.
   - No hardcoded secrets, tokens, or API keys.
6. **Report.** Group findings as ❌ Errors → ⚠️ Warnings → ✅ Passed. For each error/warning, include the file:line and the suggested fix. End with one line: *"Run `/adk-test <name>` to actually invoke it."*

If the user adds the word "fix" to `$ARGUMENTS` (e.g., `/adk-validate search fix`), apply the suggested fixes for errors after reporting them, then re-run the baseline checks from step 1.
