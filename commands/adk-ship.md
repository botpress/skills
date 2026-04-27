---
name: adk-ship
description: Run pre-flight checks and deploy an ADK bot to production
argument-hint: "[--env <env>] [message]"
---

Load the `adk` skill, then run pre-flight checks before deploying.

This is a deploy-to-production command — treat it as destructive-by-default. Confirm with the user before running `adk deploy`, even when pre-flight is green. Never pass `--yes` to `adk deploy` unless the user has explicitly approved it in this turn.

## Workflow

1. **Pre-flight (run in parallel where possible):**
   - `adk check --format json` — must pass with zero errors.
   - `adk evals --format json` — must pass if any evals exist; if none exist, surface that as a warning and offer `/adk-eval` before shipping.
   - `git status` — surface uncommitted changes; ask whether to ship the working tree as-is or commit first.
   - `adk status --format json` — confirm the project is linked to the intended workspace and bot.
   - Check `agent.config.ts` for unconfigured integrations (missing secrets, missing models). If any, block the ship and list them.

2. **Summarize.** Show a tight pre-flight report: ✅ checks passed, ⚠️ warnings, ❌ blockers. Include target env (default `production`), linked bot, and a one-line diff summary if there are uncommitted changes.

3. **Confirm.** If there are blockers, stop and offer to fix each. If only warnings, ask: *"Ship to <env> as <bot>? (yes / no)"*. Do not assume consent from the original `/adk-ship` invocation.

4. **Deploy.** Run `adk deploy` (add `--env <env>` if the user passed one). Stream output. If `adk deploy` prompts for preflight approval, surface the prompt to the user — do not auto-approve.

5. **Verify.** After deploy, run `adk status --format json` to confirm the deployed version. Report deployed version, environment, and any post-deploy warnings. Note: `adk chat` runs against the local dev bot, not the deployed one — do not use it as a production smoke test. Direct the user to the Dev Console for live verification.

6. **Wrap up.** Link the user to the Dev Console (control panel) if a URL is in the deploy output. Suggest writing a regression eval if the ship fixed a bug, or scheduling a soak check if the deploy changed user-facing behavior.

If the user invokes `/adk-ship` again within the same session and pre-flight already ran clean, you may skip re-running checks that have not changed — but always confirm before the second `adk deploy`.
