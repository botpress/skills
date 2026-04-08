---
name: agent-visualizer
description: Generates a dark-themed HTML flow diagram that visualizes any Botpress ADK bot's architecture — conversations, tools, actions, workflows, knowledge bases, tables, and triggers.
license: MIT
---

# Agent Visualizer Skill

You generate a dark-themed HTML flow diagram that visualizes any Botpress ADK bot's architecture. When the user provides a path to an ADK project (or you're already in one), analyze the codebase and produce a single self-contained HTML file.

## When to Use This Skill

Use this skill when the developer asks about:

- **Bot architecture overview** — "What does my bot look like?" or "Show me the architecture"
- **Visual diagram** — "Generate a flow diagram" or "Visualize my bot"
- **Understanding bot behavior** — "How does my bot work end to end?"
- **Documentation visuals** — "Create a visual reference for my bot"
- **Onboarding** — New team members wanting to understand the bot structure

**Trigger questions:**
- "Visualize my bot"
- "Generate a flow diagram for this project"
- "What does my bot's architecture look like?"
- "Show me how my bot works"
- "Create an architecture diagram"
- "I need a visual overview of this agent"
- "Map out my bot's flow"
- "What tools and actions does my bot have?"

## How to Generate the Diagram

Follow these three steps exactly.

### Step 1 — Analyze the Bot

Read these files to extract all bot metadata:

1. **`agent.config.ts`** — name, description, defaultModels (autonomous + zai), bot/user state schemas, dependencies (integrations with versions)
2. **`src/conversations/*.ts`** — channel(s), pre-execute logic (guards, commands, routing), execute() call with instructions/tools/knowledge/exits, any disambiguation rules from the system prompt
3. **`src/actions/*.ts`** — every exported Action: name, description, input/output schemas, what it calls internally (APIs, internal modules, client methods)
4. **`src/tools/*.ts`** — every Autonomous.Tool: name, description, input/output schemas, internal logic
5. **`src/workflows/*.ts`** — name, schedule (cron), steps, step.map/forEach/batch usage
6. **`src/knowledge/*.ts`** — Knowledge base names, descriptions, data sources (Directory, Website), file filters
7. **`src/tables/*.ts`** — Table definitions, column schemas, computed columns
8. **`src/triggers/*.ts`** — Event triggers
9. **Internal module directories** — If actions/tools import from subdirectories (e.g., `../bot-checker/`, `../latency-analyzer/`), list those submodules as chips inside the parent tool/action card

Determine which files are **placeholder** (contain `export default {}` or only TODO comments) vs **implemented**.

### Step 2 — Generate the HTML

Produce a single `.html` file named `flow-diagram.html` in the project root. Use the exact visual system described in `references/visual-design-system.md`. **Do NOT use Mermaid, SVG libraries, or external dependencies.** Everything is pure HTML + inline CSS.

### Step 3 — Open It

Run `open <path>/flow-diagram.html` to show the user.

## Available Documentation

| File | Contents |
|------|----------|
| `references/visual-design-system.md` | Complete HTML/CSS visual design system — color palette, component templates, arrow styles, layout order, and adaptation rules |

## How to Answer

1. **"Visualize my bot"** — Run the full 3-step process: analyze, generate HTML, open
2. **"What does my bot look like?"** — Same as above, generate the visual
3. **"Update the diagram"** — Re-analyze the codebase and regenerate `flow-diagram.html`
4. **"Can you add X to the diagram?"** — Modify the existing `flow-diagram.html` to include the requested section

## Key Rules

- **Single file** — The output is always ONE self-contained HTML file with inline CSS. No external dependencies.
- **No libraries** — Do not use Mermaid, D3, SVG libraries, or any JavaScript framework.
- **Dark theme only** — Use the exact color palette from the visual design system reference.
- **Skip empty sections** — Only render sections that have actual content. List placeholders under "Not Implemented".
- **Accurate** — Every tool, action, workflow, and knowledge base shown must come from the actual codebase. Do not invent components.
- **Open automatically** — Always run `open` on the generated file so the user sees it immediately.

## Response Format

When generating a diagram:

1. **Briefly list what you found** — "Found 3 tools, 2 actions, 1 workflow, and 2 knowledge bases"
2. **Generate the HTML** — Write `flow-diagram.html` to the project root
3. **Open it** — Run `open flow-diagram.html`
4. **Summarize** — One sentence describing what the diagram shows

Do not dump the full HTML into the chat. Write it to the file and open it.
