---
name: adk-frontend
description: Build frontend apps that integrate with ADK bots
argument-hint: "[what to build or question]"
---

Load the `adk-frontend` and `adk` skills, then help with the frontend immediately.

If `$ARGUMENTS` names a topic (e.g., "auth", "types", "actions", "client"), check if the user already has a frontend (`Glob({ pattern: "**/package.json" })`) and look for `@botpress/client` usage. If they have existing code, read it before suggesting changes. If they don't, scaffold from the recommended stack in the skill.

If `$ARGUMENTS` is a conceptual question ("what is X?"), answer in one sentence + one code example.

If `$ARGUMENTS` is empty or broad, check if a frontend project exists. If yes, read it and identify what's in place vs. what's missing. If no, ask what they want to build and guide them through the recommended stack.

Provide complete, working code examples with proper TypeScript types. Use the service layer pattern and Zustand client store from the skill documentation.
