---
name: adk-init
description: Scaffold a new Botpress ADK project
argument-hint: "[project-name]"
---

Help the user initialize a new Botpress ADK project.

First, load the `adk` skill for full ADK knowledge.

1. If `$ARGUMENTS` contains a project name, use it. Otherwise ask.
2. Ensure the user is logged in (`adk login --token "$BOTPRESS_TOKEN"` or `adk login`).
3. Run `adk init <name> --yes --skip-link --template hello-world` to scaffold the project.
4. Guide through linking with `adk link` and initial configuration.
5. Explain the generated project structure and conventions.

Follow all ADK CLI best practices from the skill documentation.
