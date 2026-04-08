# Visual Design System for Flow Diagrams

This is the complete specification for generating `flow-diagram.html`. Follow every detail exactly.

## Global Styles

- **Background:** `#0f0f13` (near-black)
- **Font:** `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif`
- **Max width:** `1200px`, centered
- **Text color:** `#e0e0e0` default
- **All sections:** `border-radius: 14px`, `padding: 20px 24px`, `margin-bottom: 12px`
- **Section labels:** `font-size: 10px`, `text-transform: uppercase`, `letter-spacing: 1.5px`, `font-weight: 600`

## Color Palette

Each component type gets a unique hue. Use these exact values:

| Component | Background | Border | Label color | Text accent |
|---|---|---|---|---|
| Integration / Entry | `#111827` | `#1e3a5f` | `#93c5fd` | `#5b7ea8` |
| Conversation Handler | `#1a1028` | `#3b1f6e` | `#c084fc` | `#d8b4fe` |
| Execute / Autonomous | `#0f1f15` | `#1b4332` | `#6ee7b7` | `#a7f3d0` |
| Action Tool (amber) | `#1f1708` | `#92400e` | `#fbbf24` | `#fcd34d` |
| Autonomous Tool (blue) | `#0c1929` | `#1e40af` | `#60a5fa` | `#93c5fd` |
| Knowledge Base | `#1a0f2e` | `#5b21b6` | `#a78bfa` | `#c4b5fd` |
| Security / Gate | `#1f0a0a` | `#7f1d1d` | `#fca5a5` | `#f87171` |
| Response | `#1f0a18` | `#6b213f` | `#f472b6` | `#f9a8d4` |
| Extra Action (green) | `#14170f` | `#3f6212` | `#a3e635` | `#bef264` |
| Workflow (teal) | `#0f1a1a` | `#134e4a` | `#5eead4` | `#99f6e4` |
| Table / Storage | `#1a1410` | `#78350f` | `#d6a56a` | `#e8c48a` |
| Trigger | `#1a0f1a` | `#6b21a8` | `#c084fc` | `#d8b4fe` |
| Not Implemented | `#141418` | `#2a2a3a` (dashed) | `#555` | `#555` |
| Config chips | `#1a1a24` | `#2a2a3a` | `#888` label | `#e0e0e0` value |
| User bubble | `#1a1a24` | `#2a2a3a` | — | `#ccc` |

### Extra Hue Cycle

For tools/actions that need additional hues beyond amber and blue, cycle through these in order:

- **Teal:** bg `#0c1920`, border `#155e75`, label `#22d3ee`, accent `#67e8f9`
- **Rose:** bg `#1f0a14`, border `#9f1239`, label `#fb7185`, accent `#fda4af`
- **Emerald:** bg `#0a1f14`, border `#065f46`, label `#34d399`, accent `#6ee7b7`
- **Indigo:** bg `#0f0c29`, border `#3730a3`, label `#818cf8`, accent `#a5b4fc`

## Arrows

SVG arrows connecting sections vertically:

```html
<div class="arrow-down">
  <svg viewBox="0 0 24 40"><path d="M12 0 L12 32"/><polygon points="6,30 12,40 18,30"/></svg>
</div>
```

CSS for arrows:

```css
.arrow-down {
  text-align: center;
  margin: 8px 0;
}
.arrow-down svg {
  width: 24px;
  height: 40px;
}
.arrow-down path {
  stroke: #444;
  stroke-width: 2;
  fill: none;
}
.arrow-down polygon {
  fill: #444;
}
.arrow-label {
  text-align: center;
  font-style: italic;
  font-size: 11px;
  color: #666;
  margin: -4px 0 8px 0;
}
```

## Component Templates

### Config Bar

Horizontal row of chips at the top showing: Name, Autonomous model, Zai model, Integration count.

```html
<div class="config-bar">
  <div class="config-chip">
    <span class="config-label">Name</span>
    <span class="config-value">my-bot</span>
  </div>
  <div class="config-chip">
    <span class="config-label">Autonomous Model</span>
    <span class="config-value">gpt-4o-mini</span>
  </div>
  <!-- more chips -->
</div>
```

```css
.config-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-bottom: 16px;
}
.config-chip {
  background: #1a1a24;
  border: 1px solid #2a2a3a;
  border-radius: 8px;
  padding: 8px 14px;
  display: flex;
  flex-direction: column;
  gap: 2px;
}
.config-label {
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 1px;
  color: #888;
}
.config-value {
  font-size: 13px;
  color: #e0e0e0;
  font-family: monospace;
}
```

### User Bubble

Pill-shaped, centered:

```html
<div class="user-bubble">
  <span>User sends a message</span>
</div>
```

```css
.user-bubble {
  background: #1a1a24;
  border: 1px solid #2a2a3a;
  border-radius: 50px;
  padding: 12px 28px;
  text-align: center;
  color: #ccc;
  font-size: 13px;
  max-width: 300px;
  margin: 0 auto;
}
```

### Entry Points (Integrations)

Horizontal row of cards, one per integration:

```html
<div class="section" style="background: #111827; border: 1px solid #1e3a5f;">
  <div class="section-label" style="color: #93c5fd;">Entry Points</div>
  <div class="entry-grid">
    <div class="entry-card">
      <div class="entry-icon">💬</div>
      <div class="entry-name">slack</div>
      <div class="entry-version">v3.0.0</div>
    </div>
    <!-- more entries -->
  </div>
</div>
```

```css
.entry-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 10px;
}
.entry-card {
  background: rgba(30, 58, 95, 0.3);
  border: 1px solid #1e3a5f;
  border-radius: 10px;
  padding: 12px 16px;
  text-align: center;
  min-width: 100px;
}
.entry-icon {
  font-size: 20px;
  margin-bottom: 4px;
}
.entry-name {
  font-size: 13px;
  font-weight: 600;
  color: #93c5fd;
}
.entry-version {
  font-size: 11px;
  color: #5b7ea8;
  font-family: monospace;
}
```

Integration icon mapping (use text/emoji fallbacks):
- Slack: 💬
- WhatsApp: 📱
- Linear: 📋
- Zendesk: 🎫
- GitHub: 🐙
- Webchat: 🌐
- Email: 📧
- Generic: 🔌

If Slack is present, optionally override its border to `#4a154b`.

### Conversation Handler

Purple section with file path and pre-execute logic:

```html
<div class="section" style="background: #1a1028; border: 1px solid #3b1f6e;">
  <div class="section-label" style="color: #c084fc;">Conversation Handler</div>
  <div class="file-chip">src/conversations/chat.ts</div>
  <p class="section-desc" style="color: #d8b4fe;">Pre-execute logic description here</p>
  <!-- Disambiguation grid if applicable -->
  <div class="disambig-grid">
    <div class="disambig-card">
      <div class="disambig-label">Route Name</div>
      <div class="disambig-desc">Route description</div>
    </div>
  </div>
</div>
```

```css
.file-chip {
  display: inline-block;
  background: #2d1a4e;
  border-radius: 6px;
  padding: 4px 10px;
  font-family: monospace;
  font-size: 12px;
  color: #c084fc;
  margin: 8px 0;
}
.section-desc {
  font-size: 13px;
  line-height: 1.5;
  margin: 8px 0;
}
.disambig-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 8px;
  margin-top: 10px;
}
.disambig-card {
  background: rgba(59, 31, 110, 0.3);
  border: 1px solid #3b1f6e;
  border-radius: 8px;
  padding: 10px 14px;
}
.disambig-label {
  font-size: 12px;
  font-weight: 600;
  color: #c084fc;
}
.disambig-desc {
  font-size: 11px;
  color: #d8b4fe;
  margin-top: 4px;
}
```

When there are **multiple conversation files**, show each as a separate sub-block inside the conversation section.

### Security Gate

Red section with numbered steps (only if the system prompt describes access controls):

```html
<div class="section" style="background: #1f0a0a; border: 1px solid #7f1d1d;">
  <div class="section-label" style="color: #fca5a5;">Security Gate</div>
  <div class="security-steps">
    <div class="security-step">
      <span class="step-num" style="color: #f87171;">1</span>
      <span>Check user authentication</span>
    </div>
    <!-- more steps -->
  </div>
</div>
```

```css
.security-steps {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 10px;
}
.security-step {
  background: rgba(127, 29, 29, 0.3);
  border: 1px solid #7f1d1d;
  border-radius: 8px;
  padding: 10px 14px;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 13px;
  color: #fca5a5;
}
.step-num {
  font-weight: 700;
  font-size: 16px;
}
```

### Execute Section

Green section with quoted instructions and tool/knowledge lists:

```html
<div class="section" style="background: #0f1f15; border: 1px solid #1b4332;">
  <div class="section-label" style="color: #6ee7b7;">Execute (Autonomous)</div>
  <blockquote class="instructions" style="border-left: 3px solid #34d399; color: #a7f3d0;">
    Bot instructions summary here...
  </blockquote>
  <div class="execute-lists">
    <div>
      <div class="list-title" style="color: #6ee7b7;">Tools</div>
      <ul class="execute-list">
        <li>toolName</li>
      </ul>
    </div>
    <div>
      <div class="list-title" style="color: #6ee7b7;">Knowledge</div>
      <ul class="execute-list">
        <li>knowledgeBaseName</li>
      </ul>
    </div>
  </div>
</div>
```

```css
.instructions {
  font-style: italic;
  padding: 10px 16px;
  margin: 10px 0;
  font-size: 13px;
  line-height: 1.5;
  background: rgba(27, 67, 50, 0.2);
  border-radius: 0 8px 8px 0;
}
.execute-lists {
  display: flex;
  flex-wrap: wrap;
  gap: 24px;
  margin-top: 12px;
}
.list-title {
  font-size: 11px;
  text-transform: uppercase;
  letter-spacing: 1px;
  font-weight: 600;
  margin-bottom: 6px;
}
.execute-list {
  list-style: none;
  padding: 0;
  margin: 0;
}
.execute-list li {
  font-family: monospace;
  font-size: 12px;
  color: #a7f3d0;
  padding: 2px 0;
}
```

### Tool/Action Cards Grid

Use responsive grid for tool cards:

```html
<div class="section" style="background: transparent; border: none; padding: 0;">
  <div class="section-label" style="color: #fbbf24; margin-bottom: 12px;">Tools & Actions</div>
  <div class="tools-grid">
    <!-- Tool card example (Autonomous.Tool - blue) -->
    <div class="tool-card" style="background: #0c1929; border: 1px solid #1e40af;">
      <div class="tool-type" style="color: #60a5fa;">Autonomous.Tool</div>
      <div class="tool-name" style="color: #93c5fd;">searchDocs</div>
      <div class="tool-desc">Searches documentation by keyword</div>
      <div class="tool-io">
        <div>Input: <code style="background: #0a1220; color: #93c5fd;">{ query: string, limit?: number }</code></div>
        <div>Output: <code style="background: #0a1220; color: #93c5fd;">{ results: Doc[] }</code></div>
      </div>
      <!-- Optional submodules -->
      <div class="submodules">
        <div class="submodules-title">Internal Modules (search-engine/)</div>
        <div class="submodule-grid">
          <div class="submodule-chip" style="background: #080f1a; color: #60a5fa;">indexer</div>
          <div class="submodule-chip" style="background: #080f1a; color: #60a5fa;">ranker</div>
        </div>
      </div>
    </div>

    <!-- Action card example (amber) -->
    <div class="tool-card" style="background: #1f1708; border: 1px solid #92400e;">
      <div class="tool-type" style="color: #fbbf24;">Action .asTool()</div>
      <div class="tool-name" style="color: #fcd34d;">createTicket</div>
      <div class="tool-desc">Creates a support ticket</div>
      <div class="tool-io">
        <div>Input: <code style="background: #1a1205; color: #fcd34d;">{ title: string, body: string }</code></div>
        <div>Output: <code style="background: #1a1205; color: #fcd34d;">{ ticketId: string }</code></div>
      </div>
    </div>
  </div>
</div>
```

```css
.tools-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 12px;
}
/* For bots with >4 tools, use denser grid */
.tools-grid.dense {
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
}
.tool-card {
  border-radius: 12px;
  padding: 16px;
}
.tool-type {
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 1px;
  font-weight: 600;
  margin-bottom: 4px;
}
.tool-name {
  font-size: 16px;
  font-weight: 700;
  margin-bottom: 6px;
}
.tool-desc {
  font-size: 12px;
  color: #aaa;
  margin-bottom: 10px;
  line-height: 1.4;
}
.tool-io {
  font-size: 11px;
  color: #999;
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.tool-io code {
  font-family: monospace;
  padding: 1px 5px;
  border-radius: 3px;
  font-size: 11px;
}
.submodules {
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px solid rgba(255,255,255,0.1);
}
.submodules-title {
  font-size: 10px;
  text-transform: uppercase;
  letter-spacing: 1px;
  color: #888;
  margin-bottom: 6px;
}
.submodule-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 4px;
}
.submodule-chip {
  border-radius: 4px;
  padding: 2px 8px;
  font-family: monospace;
  font-size: 11px;
}
```

### Knowledge Base Section

```html
<div class="section" style="background: #1a0f2e; border: 1px solid #5b21b6;">
  <div class="section-label" style="color: #a78bfa;">Knowledge Base</div>
  <div class="kb-name" style="color: #c4b5fd;">support-docs</div>
  <div class="kb-desc">Support documentation and FAQs</div>
  <div class="kb-source">Source: <code style="background: #120a22; color: #c4b5fd;">./knowledge/support-docs/</code></div>
  <!-- Content groups if applicable -->
  <div class="kb-groups">
    <div class="kb-group">
      <div class="kb-group-label">Category Name</div>
      <div class="kb-group-items">item1, item2, item3</div>
    </div>
  </div>
</div>
```

```css
.kb-name {
  font-size: 16px;
  font-weight: 700;
  margin: 8px 0 4px;
}
.kb-desc {
  font-size: 12px;
  color: #aaa;
  margin-bottom: 8px;
}
.kb-source {
  font-size: 11px;
  color: #888;
}
.kb-groups {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  margin-top: 12px;
}
.kb-group {
  background: rgba(91, 33, 182, 0.2);
  border-radius: 8px;
  padding: 10px;
}
.kb-group-label {
  font-size: 11px;
  font-weight: 600;
  color: #a78bfa;
  margin-bottom: 4px;
}
.kb-group-items {
  font-size: 11px;
  color: #c4b5fd;
}
```

### Workflow Cards

```html
<div class="section" style="background: #0f1a1a; border: 1px solid #134e4a;">
  <div class="section-label" style="color: #5eead4;">Workflows</div>
  <div class="workflow-grid">
    <div class="workflow-card">
      <div class="workflow-name" style="color: #99f6e4;">dailySyncWorkflow</div>
      <div class="workflow-schedule">
        Schedule: <code style="background: #0a1414; color: #5eead4;">0 9 * * *</code>
      </div>
      <div class="workflow-steps">
        <span class="step-chip" style="background: rgba(19, 78, 74, 0.4); color: #5eead4;">fetchData</span>
        <span class="step-arrow">→</span>
        <span class="step-chip" style="background: rgba(19, 78, 74, 0.4); color: #5eead4;">processData</span>
        <span class="step-arrow">→</span>
        <span class="step-chip" style="background: rgba(19, 78, 74, 0.4); color: #5eead4;">notify</span>
      </div>
    </div>
  </div>
</div>
```

```css
.workflow-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 12px;
  margin-top: 10px;
}
.workflow-card {
  background: rgba(19, 78, 74, 0.2);
  border: 1px solid #134e4a;
  border-radius: 10px;
  padding: 14px;
}
.workflow-name {
  font-size: 14px;
  font-weight: 700;
  margin-bottom: 6px;
}
.workflow-schedule {
  font-size: 11px;
  color: #888;
  margin-bottom: 8px;
}
.workflow-steps {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 6px;
}
.step-chip {
  border-radius: 6px;
  padding: 4px 10px;
  font-family: monospace;
  font-size: 11px;
}
.step-arrow {
  color: #555;
  font-size: 14px;
}
```

### Table / Storage Section

```html
<div class="section" style="background: #1a1410; border: 1px solid #78350f;">
  <div class="section-label" style="color: #d6a56a;">Tables</div>
  <div class="table-grid">
    <div class="table-card">
      <div class="table-name" style="color: #e8c48a;">Users</div>
      <div class="table-cols">
        <code style="background: #14100a; color: #d6a56a;">name: string</code>
        <code style="background: #14100a; color: #d6a56a;">email: string (searchable)</code>
      </div>
    </div>
  </div>
</div>
```

```css
.table-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 12px;
  margin-top: 10px;
}
.table-card {
  background: rgba(120, 53, 15, 0.2);
  border: 1px solid #78350f;
  border-radius: 10px;
  padding: 14px;
}
.table-name {
  font-size: 14px;
  font-weight: 700;
  margin-bottom: 8px;
}
.table-cols {
  display: flex;
  flex-direction: column;
  gap: 4px;
}
.table-cols code {
  display: block;
  font-family: monospace;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 11px;
}
```

### Trigger Section

```html
<div class="section" style="background: #1a0f1a; border: 1px solid #6b21a8;">
  <div class="section-label" style="color: #c084fc;">Triggers</div>
  <div class="trigger-grid">
    <div class="trigger-card">
      <div class="trigger-name" style="color: #d8b4fe;">onNewTicket</div>
      <div class="trigger-desc">Fires when a new support ticket is created</div>
    </div>
  </div>
</div>
```

```css
.trigger-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 12px;
  margin-top: 10px;
}
.trigger-card {
  background: rgba(107, 33, 168, 0.2);
  border: 1px solid #6b21a8;
  border-radius: 10px;
  padding: 14px;
}
.trigger-name {
  font-size: 14px;
  font-weight: 700;
  margin-bottom: 4px;
}
.trigger-desc {
  font-size: 12px;
  color: #aaa;
}
```

### Extra Actions (Not Passed to Execute)

```html
<div class="section" style="background: #14170f; border: 1px solid #3f6212;">
  <div class="section-label" style="color: #a3e635;">Extra Actions (Not in Execute)</div>
  <div class="extra-grid">
    <div class="extra-card">
      <span class="extra-icon">⚡</span>
      <div>
        <div class="extra-name" style="color: #bef264;">processWebhook</div>
        <div class="extra-desc">Handles incoming webhook payloads</div>
      </div>
    </div>
  </div>
</div>
```

```css
.extra-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 10px;
  margin-top: 10px;
}
.extra-card {
  background: rgba(63, 98, 18, 0.2);
  border: 1px solid #3f6212;
  border-radius: 10px;
  padding: 12px 16px;
  display: flex;
  align-items: center;
  gap: 10px;
}
.extra-icon {
  font-size: 18px;
}
.extra-name {
  font-size: 13px;
  font-weight: 600;
}
.extra-desc {
  font-size: 11px;
  color: #aaa;
}
```

### Output Section

Grid of output cards showing what each tool returns:

```html
<div class="section" style="background: transparent; border: none; padding: 0;">
  <div class="section-label" style="color: #fbbf24; margin-bottom: 12px;">Tool Outputs</div>
  <div class="output-grid">
    <div class="output-card" style="background: #0c1929; border: 1px solid #1e40af;">
      <div class="output-tool" style="color: #60a5fa;">searchDocs</div>
      <div class="output-desc">Returns matching documents with relevance scores</div>
    </div>
  </div>
</div>
```

```css
.output-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 10px;
}
.output-card {
  border-radius: 10px;
  padding: 12px 16px;
}
.output-tool {
  font-size: 12px;
  font-weight: 600;
  margin-bottom: 4px;
}
.output-desc {
  font-size: 11px;
  color: #aaa;
}
```

### Response Section

```html
<div class="section" style="background: #1f0a18; border: 1px solid #6b213f; text-align: center;">
  <div class="section-label" style="color: #f472b6;">Response</div>
  <p style="color: #f9a8d4; font-size: 13px;">
    LLM generates a natural language response based on tool outputs
  </p>
</div>
```

### Not Implemented Section

Dashed border section listing placeholder directories:

```html
<div class="section" style="background: #141418; border: 2px dashed #2a2a3a;">
  <div class="section-label" style="color: #555;">Not Implemented</div>
  <div class="not-impl-list">
    <span class="not-impl-chip">src/workflows/</span>
    <span class="not-impl-chip">src/triggers/</span>
  </div>
</div>
```

```css
.not-impl-list {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 8px;
}
.not-impl-chip {
  background: #1a1a24;
  border: 1px dashed #2a2a3a;
  border-radius: 6px;
  padding: 4px 10px;
  font-family: monospace;
  font-size: 11px;
  color: #555;
}
```

### Legend

Horizontal flex row of legend items at the bottom:

```html
<div class="legend">
  <div class="legend-item">
    <div class="legend-swatch" style="background: #1e3a5f;"></div>
    <span>Integration</span>
  </div>
  <div class="legend-item">
    <div class="legend-swatch" style="background: #3b1f6e;"></div>
    <span>Conversation</span>
  </div>
  <div class="legend-item">
    <div class="legend-swatch" style="background: #1b4332;"></div>
    <span>Execute</span>
  </div>
  <div class="legend-item">
    <div class="legend-swatch" style="background: #92400e;"></div>
    <span>Action</span>
  </div>
  <div class="legend-item">
    <div class="legend-swatch" style="background: #1e40af;"></div>
    <span>Tool</span>
  </div>
  <div class="legend-item">
    <div class="legend-swatch" style="background: #5b21b6;"></div>
    <span>Knowledge</span>
  </div>
  <div class="legend-item">
    <div class="legend-swatch" style="background: #134e4a;"></div>
    <span>Workflow</span>
  </div>
  <div class="legend-item">
    <div class="legend-swatch" style="background: #78350f;"></div>
    <span>Table</span>
  </div>
  <div class="legend-item">
    <div class="legend-swatch" style="background: #7f1d1d;"></div>
    <span>Security</span>
  </div>
  <div class="legend-item">
    <div class="legend-swatch" style="background: #2a2a3a; border-style: dashed;"></div>
    <span>Not Implemented</span>
  </div>
</div>
```

```css
.legend {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  margin-top: 20px;
  padding: 16px;
  border-top: 1px solid #222;
}
.legend-item {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 11px;
  color: #888;
}
.legend-swatch {
  width: 12px;
  height: 12px;
  border-radius: 3px;
  border: 1px solid rgba(255,255,255,0.1);
}
```

## Layout Order (Top to Bottom)

Only include sections that are relevant. Skip empty/placeholder sections (except listing them under "Not Implemented").

1. **Title** (h1) + optional tagline + subtitle with model in monospace chip
2. **Config Bar** (chips)
3. **User Bubble** (top)
4. Arrow
5. **Entry Points** (integrations)
6. Arrow
7. **Conversation Handler** (with disambiguation if applicable)
8. Arrow + label "calls execute()"
9. **Security Gate** (only if system prompt describes access controls)
10. Arrow
11. **Execute Section**
12. Arrow + label "LLM selects tool"
13. **Tools Grid** (all tools passed to execute)
14. **Knowledge Base** (if present)
15. **Workflow Cards** (if present)
16. **Table / Storage** (if present)
17. **Extra Actions** (actions not in execute, if any)
18. Arrow
19. **Output Section** (what each tool returns)
20. Arrow + label
21. **Response Section**
22. Arrow
23. **User Bubble** (bottom)
24. **Not Implemented** (placeholder directories)
25. **Legend**

## Adaptations

- **No tools** — Skip the tools grid, show only the execute section with instructions
- **Many tools (>4)** — Use `tools-grid dense` class for denser layout (`minmax(220px, 1fr)`)
- **Has workflows** — Add workflow cards between Knowledge and Extra Actions
- **Has tables** — Add storage section with table names and column highlights
- **Has triggers** — Add trigger section before the conversation handler
- **Slack integration** — Override that entry node's border to `#4a154b`
- **Multiple conversation files** — Show each as a separate sub-block inside the conversation section

## Base HTML Template

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Bot Name — Architecture</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      background: #0f0f13;
      color: #e0e0e0;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      padding: 40px 20px;
    }
    .container { max-width: 1200px; margin: 0 auto; }
    h1 { font-size: 24px; font-weight: 700; margin-bottom: 4px; }
    .tagline { font-size: 13px; color: #888; margin-bottom: 4px; }
    .subtitle { font-size: 12px; color: #666; margin-bottom: 20px; }
    .model-chip {
      display: inline-block;
      background: #1a1a24;
      border: 1px solid #2a2a3a;
      border-radius: 4px;
      padding: 1px 6px;
      font-family: monospace;
      font-size: 11px;
      color: #aaa;
    }
    .section {
      border-radius: 14px;
      padding: 20px 24px;
      margin-bottom: 12px;
    }
    .section-label {
      font-size: 10px;
      text-transform: uppercase;
      letter-spacing: 1.5px;
      font-weight: 600;
    }
    /* ... paste all CSS from above ... */
  </style>
</head>
<body>
  <div class="container">
    <!-- Build sections here based on analysis -->
  </div>
</body>
</html>
```

Combine ALL CSS into the single `<style>` block. The HTML file must be completely self-contained.
