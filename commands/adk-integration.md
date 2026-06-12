---
name: adk-integration
description: Discover, add, and configure Botpress integrations
argument-hint: '[integration name or question]'
---

Load the `adk` skill, then help with integrations immediately.

If `$ARGUMENTS` names a specific integration (e.g., "slack", "linear", "whatsapp"), check the current state first by running `adk integrations list --format json`. If it's already installed, show its status — version, whether it's configured, and available actions. If installed but unconfigured, flag the issue and guide configuration. If not installed, run `adk integrations info <name> --format json` and offer to add it with a pinned version.

If `$ARGUMENTS` names a plugin (e.g., "desk-hitl"), use `adk plugins` commands instead: `adk plugins list --format json` to check installed state, `adk plugins info <name> --format json` for details, `adk plugins add <name>@<version>` to install. Plugins use separate commands from integrations.

If `$ARGUMENTS` is a general question ("what's available?", "messaging") or empty, run `adk integrations list --format json` to show what's installed, then `adk integrations search <query> --format json` for discovery.

Always confirm before running `adk integrations add` or `adk integrations remove`. Always pin versions: `adk integrations add <name>@<version>`. Use `--format json` on `adk integrations remove` and `adk integrations upgrade` for scripting.

Follow the integration lifecycle patterns from the skill documentation.
