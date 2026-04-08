---
name: adk-doc-create
description: Create documentation for a feature in the user's ADK bot
argument-hint: "[topic-name]"
---

Create documentation for **$ARGUMENTS** — a feature, workflow, or component in the user's ADK bot.

First, load the `adk-docs` skill for documentation standards and the `adk` skill for ADK context.

## Process

### 1. Research Phase

Understand the topic before writing:

```javascript
// Find the user's ADK project
Glob({ pattern: "**/agent.config.ts" })

// Search for topic patterns in the user's project
Grep({ pattern: "$ARGUMENTS", path: "<user-project-dir>" })

// Find official ADK examples if available locally
Glob({ pattern: "**/adk/examples/**/*.ts" })

// Check existing project docs
Glob({ pattern: "./{docs,guides}/**/*.md" })
```

**Priority order for code examples:**
1. The user's own ADK project — BEST
2. Official ADK repo examples (find locally or reference public repo)
3. ADK runtime source (`@botpress/runtime` packages)

### 2. Choose Document Type

Refer to the `adk-docs` skill's doc-standards reference for templates:
- **Reference Documentation** (CLI, API): 400-500 lines, Quick Start at top
- **Conceptual Guides** (workflows, patterns): 500-700 lines, Core Concepts structure
- **Comprehensive Guides** (messages, tables): 600-800 lines, full TOC

### 3. Write the Documentation

- Every concept needs a working code example from the user's bot or the official ADK repo
- Include file paths with line numbers for verification
- Use clear `##`/`###` headers for ripgrep searchability
- Do NOT add Common Mistakes or Best Practices sections unless user provides them
- Follow the writing style: direct, actionable, technically accurate, no fluff

### 4. After Writing

1. Save the file where the user wants it (ask if unclear — common: `./docs/`, `./guides/`)
2. Verify sections are searchable: `Grep({ pattern: "^## ", path: "<output-file>", output_mode: "content" })`
3. Read the file back to check overall length and quality

Begin research and create a reference-quality guide for the user's bot.
