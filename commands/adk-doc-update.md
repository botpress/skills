---
name: adk-doc-update
description: Update project documentation after code changes
argument-hint: "[doc-path] [what-changed]"
---

Update the documentation at **$1** in the user's bot project with changes related to **$2**.

First, load the `adk-docs` skill for documentation standards and the `adk` skill for ADK context.

## Update Strategy

1. **Preserve Structure** — Maintain existing section hierarchy and TOC
2. **Match Style** — Keep the same tone and code example format
3. **Verify Examples** — All code examples must be from actual project or user-provided
4. **Update Metadata** — Check if any project-level doc index needs updating
5. **No Speculation** — Only add Common Mistakes/Best Practices if user provides them

## Research Current State

```javascript
// Read the existing doc
Read({ file_path: "$1" })

// Find what changed in the user's project
Grep({ pattern: "<new-feature-pattern>", output_mode: "files_with_matches" })

// Find official ADK examples for reference
Glob({ pattern: "**/adk/examples/**/*.ts" })
```

## Update Checklist

- [ ] Existing code examples still work
- [ ] New features added with examples from project code
- [ ] Deprecated patterns marked clearly
- [ ] Section headers maintained for ripgrep
- [ ] Table of contents updated if structure changed
- [ ] Common mistakes/best practices ONLY if user-provided
- [ ] File path references still accurate
- [ ] Document length still reasonable (reference: 400-500, conceptual: 500-700)

## When Adding New Sections

```markdown
#### New Subsection Name

Brief intro to the new feature.

**Example:**
\`\`\`typescript
// From <file-path>:<line-number>
await newFeature({
  option: "value"
});
\`\`\`
```

## When Marking Deprecations

```markdown
### Old Method (Deprecated)

⚠️ **Deprecated**: Use `newMethod()` instead.

**Old Way:**
\`\`\`typescript
await oldMethod(); // From <old-file-path>:<line>
\`\`\`

**New Way:**
\`\`\`typescript
await newMethod(); // From <new-file-path>:<line>
\`\`\`
```

## Quality Checks

- [ ] Sections still searchable: `Grep({ pattern: "^## ", path: "$1", output_mode: "content" })`
- [ ] No broken cross-references
- [ ] Integrates smoothly with existing content

Keep the doc as a reliable reference — fix inaccuracies, add new patterns, maintain searchability.
