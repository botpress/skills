---
name: adk-dev-console
description: Explain ADK Dev Console features, tabs, and UI concepts
argument-hint: "[UI concept, tab name, or question]"
---

Load the `adk-dev-console` skill, then answer the user's question about **$ARGUMENTS** immediately.

Resolve shorthand: "agent steps" = the execution visualizer on the Chat page, "turns" = conversation exchanges in Agent Steps, "iterations" = autonomous loop steps, "traces" = the Observe > Traces page, "cp" / "panel" / "console" = the Control Panel itself.

If the user named a specific UI concept (e.g., "agent steps", "turns", "iterations"), look it up in the skill's references and explain what it is and what the user sees. A one-word or short topic is a conceptual question — give a clear definition and describe the visual, then stop.

If the user named a tab or page (e.g., "evals tab", "observe", "tables"), explain what that page shows, its layout, and key features.

If the user asks a broad question ("what is the control panel?", "what tabs are there?", or no arguments), give the quick reference from the SKILL.md — tab groups with their pages and purpose.

If the user asks "where do I find X?", name the tab group, page, and URL path.
