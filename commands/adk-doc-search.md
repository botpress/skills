---
name: adk-doc-search
description: Search project documentation for specific topics or patterns
argument-hint: "[search-term]"
---

Search the bot's project documentation for **$ARGUMENTS** and provide relevant excerpts.

First, load the `adk-docs` skill for context and the `adk` skill for ADK knowledge.

## Search Strategy

### 1. Find Relevant Docs

```javascript
// Find all project documentation
Glob({ pattern: "./{docs,guides}/**/*.md" })

// Search section headers
Grep({ pattern: "^## .*$ARGUMENTS", path: "./{docs,guides}", output_mode: "files_with_matches" })

// Search content
Grep({ pattern: "$ARGUMENTS", path: "./{docs,guides}", output_mode: "files_with_matches" })
```

### 2. Extract Context

```javascript
// Get section with surrounding context
Grep({ pattern: "$ARGUMENTS", path: "<found-doc>.md", output_mode: "content", "-C": 10 })

// Find related sections
Grep({ pattern: "^### .*$ARGUMENTS", output_mode: "content", "-n": true })
```

## Common Search Patterns

**By Feature:**
- Messages: `Grep({ pattern: "message|send\\(\\)", output_mode: "files_with_matches" })`
- Workflows: `Grep({ pattern: "workflow|step\\(", output_mode: "files_with_matches" })`
- Conversations: `Grep({ pattern: "conversation|handler", output_mode: "files_with_matches" })`

**By Problem:**
- Errors: `Grep({ pattern: "❌ WRONG|Common Mistakes", output_mode: "files_with_matches" })`
- Best practices: `Grep({ pattern: "✅ CORRECT|Best Practice", output_mode: "files_with_matches" })`

**By API:**
- Specific method: `Grep({ pattern: "this\\.send|client\\.createMessage", output_mode: "files_with_matches" })`
- Import patterns: `Grep({ pattern: "from.*@botpress/runtime", output_mode: "files_with_matches" })`

## Response Format

When found, provide:
1. **Document** — Which file contains the information
2. **Section** — The relevant section header
3. **Excerpt** — Key content (don't dump entire doc)
4. **Related** — Other docs that might be relevant

## Not Found?

If the search term isn't in project docs:
1. Search the user's ADK project code: `Glob({ pattern: "**/agent.config.ts" })` then search within
2. Search official ADK examples if available locally
3. Search the workspace broadly
4. Suggest creating new documentation if it's a gap (use `/adk-doc-create`)

Be efficient — provide the answer, not a full doc dump.
