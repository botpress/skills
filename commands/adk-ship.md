---
name: adk-ship
description: Run pre-flight checks and deploy an ADK bot to production
---

Load the `adk` skill, then run pre-flight checks before deploying.

This is a deploy-to-production command — treat it as destructive-by-default. Confirm with the user before running `adk deploy`, even when pre-flight is green. Never pass `--yes` to `adk deploy` unless the user has explicitly approved it in this turn.

## Workflow

1. **Pre-flight (run in parallel where possible):**
   - `adk check --format json` — must pass with zero errors.
   - `adk evals --format json` — must pass if any evals exist; if none exist, surface that as a warning and offer `/adk-eval` before shipping.
   - `git status` — surface uncommitted changes; ask whether to ship the working tree as-is or commit first.
   - `adk status --format json` — confirm the project is linked to the intended workspace and bot.
   - `adk integrations status --target prod --format json` and `adk plugins status --target prod --format json` — block on unavailable/unconfigured enabled dependencies. Check `agent.config.ts` for missing models.
   - If a project command reports an ADK runtime/package mismatch, run `adk project upgrade --dry-run`, show the plan, and get approval before `adk project upgrade`.

2. **Summarize.** Show a tight pre-flight report: ✅ checks passed, ⚠️ warnings, ❌ blockers. Include the linked bot and a one-line diff summary if there are uncommitted changes.

3. **Confirm.** Always ask before deploying — the original `/adk-ship` invocation is not consent. If there are blockers, stop and offer to fix each. Otherwise (warnings or fully green), ask: _"Ship to <bot>? (yes / no)"_.

4. **Deploy.** Run `adk deploy`. Stream output. If `adk deploy` prompts for preflight approval, surface the prompt to the user — do not auto-approve. If deploy warns that integration versions differ between dev and prod, show the warning and recommend `adk integrations copy --from dev --to prod --dry-run` before any promotion.

5. **Verify.** After deploy, run `adk status --format json` to confirm the deployed version. Report deployed version and any post-deploy warnings. Note: `adk chat` runs against the local dev bot, not the deployed one — do not use it as a production smoke test. Direct the user to the Dev Console for live verification.

6. **Wrap up.** Link the user to the Dev Console if a URL is in the deploy output. If the ship fixed a bug, point the user at `/adk-eval` to capture a regression eval.

Always re-run pre-flight on every `/adk-ship` invocation. The filesystem may have changed between invocations (manual edits, `git pull`, codegen) and there is no reliable way to detect that from inside the conversation.
