---
name: adk-document
description: Create, review, update, sync, or search project documentation for an ADK bot
argument-hint: "[action] [topic or doc-path]"
---

Load the `adk-docs` skill for documentation standards and the `adk` skill for ADK context, then help with documentation immediately.

Parse `$ARGUMENTS` to determine the action. The first word is usually the action (but not always); everything after is the target.

## Route by Action

### create [topic]
E.g., `/adk-document create workflows`, `/adk-document create the checkout flow`

If the topic is a broad term ("workflows", "tools", "actions"), read `src/<relevant-dir>/` to enumerate the user's actual primitives first. Document *their specific implementations* — not generic concepts.

1. **Research**: Find the user's ADK project (`agent.config.ts`), read relevant source files in `src/`, check existing docs in `./docs/` or `./guides/`.
2. **Choose type**: Reference (400-500 lines), Conceptual (500-700), Comprehensive (600-800) — see doc-standards reference.
3. **Write**: Every concept needs a working code example from the user's actual code. Include file paths for verification. Use clear headers for ripgrep searchability. No speculative Common Mistakes or Best Practices sections.
4. **Save**: Ask where if unclear (common: `./docs/`, `./guides/`). Verify headers are searchable.

### review [doc-path]
E.g., `/adk-document review docs/workflows.md`

Review the doc for technical accuracy, searchability, and completeness:
- **Code accuracy**: correct imports (`@botpress/runtime`), examples from actual code with file paths, no speculation
- **Searchability**: clear section headers, TOC present, keyword-rich section names
- **ADK-specific**: distinguishes ADK vs SDK primitives, messages vs events, channel-specific vs agnostic
- **Validation**: `Grep` for imports, check referenced files exist, flag speculative content

Report: Critical Issues → Searchability Issues → Speculative Content → Missing Verification → Recommendations.

### update [doc-path] [what-changed]
E.g., `/adk-document update docs/workflows.md added new step type`

1. Read the existing doc.
2. Find what changed in the user's project code.
3. Preserve existing structure, style, and TOC.
4. Verify all code examples still work. Add new features with project code examples.
5. Mark deprecations clearly. Update file path references.

### sync [optional-doc-path]
E.g., `/adk-document sync`, `/adk-document sync docs/actions.md`

Check if docs are current with the code:
1. Find API changes: new exports, deprecated features, changed signatures.
2. Cross-reference: what's documented vs. what exists in `src/`.
3. Verify: do documented code examples still match actual code?

Report: Undocumented Features → Deprecated Content → Broken Examples → Missing Patterns → Recommendations.
If gaps found, offer to fix them.

### search [term]
E.g., `/adk-document search workflows`, `/adk-document search sendMessage`

1. Find project docs: `Glob({ pattern: "./{docs,guides}/**/*.md" })`
2. Search headers and content for the term.
3. Return: which file, which section, key excerpt (not full dump), related docs.
4. If not found in docs, search the project code, then suggest creating docs for the gap.

## If No Action Specified

If `$ARGUMENTS` doesn't start with create/review/update/sync/search, infer the intent:
- Looks like a file path (contains `/` or `.md`) → **review** that file
- Looks like a search term → **search** for it
- Looks like a topic to document → **create** docs for it
- Looks like gibberish, ask the user a clarification question
