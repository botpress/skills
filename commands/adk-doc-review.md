---
name: adk-doc-review
description: Review project documentation for accuracy and completeness
argument-hint: "[doc-path]"
---

Review the documentation at **$ARGUMENTS** in the user's bot project for technical accuracy, searchability, and completeness.

First, load the `adk-docs` skill for documentation standards and the `adk` skill for ADK context.

## Review Focus Areas

### 1. Code Accuracy

- [ ] All code examples use correct imports (`@botpress/runtime`)
- [ ] Examples match current ADK API
- [ ] All examples come from actual project code (with file paths)
- [ ] No invented or speculative examples
- [ ] `this.send()` vs `client.createMessage()` used correctly

### 2. Searchability (Critical for AI)

- [ ] Clear section headers (`##`, `###`, `####`)
- [ ] Table of contents present and accurate
- [ ] Keyword-rich section names (not vague "Overview" or "Advanced")
- [ ] Test: `Grep({ pattern: "^## ", path: "$ARGUMENTS", output_mode: "content" })`

### 3. Completeness

- [ ] Common mistakes section ONLY if from user feedback (not invented)
- [ ] `❌ WRONG` / `✅ CORRECT` only when documenting actual reported errors
- [ ] Best practices ONLY if user-provided
- [ ] Quick reference if appropriate
- [ ] All workflows verified from actual project code

### 4. ADK-Specific Concerns

- [ ] Distinguishes ADK primitives from Botpress SDK primitives
- [ ] No confusion between messages (persistent) and events (ephemeral)
- [ ] Channel-specific vs agnostic features clearly marked
- [ ] File paths reference actual code locations

### 5. Document Health

Check against the doc-standards reference for length and structure guidelines.

## Validation Commands

```javascript
// Check that referenced imports exist in the user's project
Grep({ pattern: "from ['\"]@botpress/runtime", output_mode: "files_with_matches" })

// Verify example code references real files
Glob({ pattern: "**/agent.config.ts" })

// Check for speculative content in the doc
Grep({ pattern: "## Common Mistakes|## Best Practices", path: "$ARGUMENTS", output_mode: "content" })
```

## Report Format

1. **Critical Issues** — Wrong code, broken examples, invented examples
2. **Searchability Issues** — Missing TOC, unclear headers
3. **Speculative Content** — Common mistakes without user feedback, invented best practices
4. **Missing Verification** — Examples without file path references
5. **Recommendations** — Priority improvements

Focus on keeping the doc reliable and evidence-based for both AI agents and human developers.
