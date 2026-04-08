---
name: adk-doc-sync
description: Check if project documentation is in sync with the bot's code
argument-hint: "[optional-doc-path]"
---

Check if the bot's documentation is current with its implementation. Focus on **$ARGUMENTS** or review all project docs if not specified.

First, load the `adk-docs` skill for documentation standards and the `adk` skill for ADK context, make sure the skills are up to date.

## Sync Check Strategy

### 1. Find API Changes

```javascript
// Check runtime exports
Grep({ pattern: "export.*class.*Conversation|Workflow|Action|Tool", output_mode: "files_with_matches" })

// Find new or deprecated features
Grep({ pattern: "TODO|FIXME|@deprecated", output_mode: "files_with_matches" })

// Find ADK example projects for undocumented patterns (HIGHEST PRIORITY)
Glob({ pattern: "**/agent.config.ts" })
```

### 2. Cross-Reference Documentation

```javascript
// What's currently documented in the project?
Glob({ pattern: "./{docs,guides}/**/*.md" })
Grep({ pattern: "^### ", path: "./{docs,guides}", output_mode: "content" })

// Count code examples in docs
Grep({ pattern: "```typescript", path: "./{docs,guides}", output_mode: "count" })

// Check for outdated patterns
Grep({ pattern: "@deprecated|removed|legacy", path: "./{docs,guides}" })
```

### 3. Verify Examples

```javascript
// Check that documented patterns still exist in actual code
Grep({ pattern: "<documented-pattern>", output_mode: "files_with_matches" })
```

## Common Drift Indicators

**API Changes:**
- New methods in runtime not in docs
- Deprecated methods still documented
- Changed signatures in examples

**Feature Gaps:**
- New ADK features without documentation
- Production patterns in example projects not documented (HIGHEST PRIORITY)
- Common mistakes not captured

**Outdated References:**
- File paths that moved
- Old import patterns
- Deprecated workflow syntax

## Sync Report Format

1. **New Features Undocumented** — Features found in code but not in docs
2. **Deprecated Content** — Docs referencing removed/deprecated APIs
3. **Broken Examples** — Code examples that won't work with current API
4. **Missing Common Patterns** — Patterns used in projects but not documented
5. **Recommendations** — Priority: what to update first

## After Sync Check

If gaps found:
- Use `/adk-doc-update` for existing docs
- Use `/adk-doc-create` for new topics
- Update any project-level doc index if documentation structure changed

Keep documentation current so it remains trustworthy.
