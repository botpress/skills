---
name: adk-integration
description: Discover, add, and configure Botpress integrations
argument-hint: "[integration name or question]"
---

Load the `adk` skill, then help with integrations immediately.

If `$ARGUMENTS` names a specific integration or plugin (e.g., "slack", "linear", "whatsapp", "desk-hitl"), check the current state first by running `adk integrations list --format json`. If it's already installed, show its status — version, whether it's configured, and available actions. If installed but unconfigured, flag the issue and guide configuration. If not installed, run `adk integrations info <name> --format json` for integrations and offer to add it with a pinned version. Note: `adk integrations info` and `adk integrations search` only work for integrations, not plugins. For plugins, use `adk integrations add plugin:<name>@<version>` directly.

If `$ARGUMENTS` is a general question ("what's available?", "messaging") or empty, run `adk integrations list --format json` to show what's installed, then `adk integrations search <query> --format json` for discovery.

Always confirm before running `adk integrations add` or `adk integrations remove`. Always pin versions: `adk integrations add <name>@<version>`. Use `--format json` on `adk integrations remove` and `adk integrations upgrade` for scripting.

Follow the integration lifecycle patterns from the skill documentation.
