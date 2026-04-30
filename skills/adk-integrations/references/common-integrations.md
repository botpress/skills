# Common Integrations Quick Reference

Quick-reference for popular Botpress integrations. Details verified via `adk info`.

## chat

**Config:** Optional only (encryptionKey, webhookUrl, webhookSecret — none required)

| | Count |
|--|-------|
| Actions | 1 (sendEvent) |
| Channels | 1 |
| Events | 1 (custom) |

Used internally by `adk chat` CLI command. Good default for basic messaging during development.

## webchat

**Config:** Optional only (~38 theming/behavior props — none required)

| | Count |
|--|-------|
| Actions | 9 (configWebchat, showWebchat, hideWebchat, etc.) |
| Channels | 1 |
| Events | 2 |

Embeddable web chat widget. Config props control appearance (primaryColor, fontFamily, etc.) and behavior (allowFileUpload, showTimestamp, etc.). All optional — works out of the box.

## browser

**Config:** None (zero config properties)

| | Count |
|--|-------|
| Actions | 5 (browsePages, webSearch, discoverUrls, captureScreenshot, getWebsiteLogo) |
| Channels | 0 |
| Events | 0 |

Most commonly used integration for RAG, web search, and page scraping. No configuration needed — just add and enable.

## slack

**Config:** OAuth + required `replyBehaviour` field

| | Count |
|--|-------|
| Actions | Multiple |
| Channels | 3 (channel, dm, thread) |
| Events | 6 |

Alternative config modes: `manifestAppCredentials`, `refreshToken`.

Requires completing the OAuth flow in the Dev Console. If you see "No credentials found", the OAuth link hasn't been clicked yet.

After adding, you must:
1. Enable in Dev Console
2. Set `replyBehaviour` config value
3. Complete OAuth authorization

## whatsapp

**Config:** 3 modes (OAuth, sandbox, manual)

| | Count |
|--|-------|
| Actions | Multiple |
| Channels | 1 |
| Events | Multiple |

**Configuration modes:**
- **OAuth (default):** Click authorization link in Dev Console
- **Sandbox:** Testing mode with shared Botpress phone number (+1-581-701-9840)
- **Manual:** Provide API credentials directly

Sandbox mode is useful for quick testing without setting up your own WhatsApp Business account.

## linear

**Name:** `agi/linear` (private, workspace-scoped) | **Config:** OAuth (default) or API key

| | Count |
|--|-------|
| Actions | Multiple |
| Channels | Multiple |
| Events | Multiple |

**Configuration modes:**
- **OAuth (default):** Click authorization link in Dev Console
- **API Key:** Provide a Linear API key directly

Because it's private, use the full name when searching: `adk info agi/linear`.

## webhook

**Config:** Optional only (secret, allowedOrigins — none required)

| | Count |
|--|-------|
| Actions | 0 |
| Channels | 0 |
| Events | 1 |

Receives external HTTP webhooks. Good for custom triggers from external systems. No actions or channels — it only fires events when a webhook payload arrives.
