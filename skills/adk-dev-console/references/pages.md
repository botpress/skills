# Dev Console Pages

Every page accessible from the ADK Dev Console at `http://localhost:3001`.

Pages marked **(dev only)** are hidden when the environment toggle is set to Production.

---

## Chat (`/chat`)

Real-time conversation interface for testing the agent.

**Layout:** Webchat embed (left) + Agent Steps visualization (right)

**Features:**
- Webchat panel for sending messages to the agent
- Agent Steps panel showing execution flow (see `agent-steps.md`)
- Conversation picker dropdown (filters to webchat conversations)
- "Open conversation traces" link to jump to full Traces view
- Download transcript button

---

## Components

### Actions (`/actions`) — dev only

Browse and test bot actions and integration actions.

**Layout:** Sidebar (action list) + detail pane

**Features:**
- Bot custom actions with input/output schema visualization
- Integration actions grouped by integration (icon, title, description)
- "Invoke action" button opens a modal to test with live inputs
- Schema view for input/output types

### Workflows (`/workflows`) — dev only

Browse workflows and view execution history.

**Layout:** Sidebar (workflow list) + detail pane

**Features:**
- Workflow name, path, description, timeout badge
- "Invoke workflow" button to trigger manually
- Workflow definition schema
- **Runs tab** (`/workflows/runs`): execution history table with status, duration, timestamp
- Click a run to open WorkflowRunDetail modal

### Triggers (`/triggers`) — dev only

Browse event triggers defined in the agent.

**Layout:** Sidebar (trigger list) + detail pane

**Features:**
- Trigger names and event types
- Trigger metadata and status

---

## Test

### RAG Search (`/search`)

Test knowledge base search interactively.

**Layout:** Sidebar (KB filter + content tree) + search input + results area + detail drawer

**Features:**
- Dropdown to filter by specific knowledge base
- Query input with advanced settings (result limit, context depth)
- Search results as cards: relevance score, source file, text snippet
- Content tree sidebar showing hierarchical KB structure
- Click a result to open detail drawer with full document + highlighted passages
- Real-time search as you type

### Evals (`/evals`) — dev only

Run and inspect automated conversation tests.

**Layout:** Sidebar (eval list) + detail pane

**Features:**
- Eval definitions with run history
- Run status: pending, in-progress, completed
- Per-turn assertion results with pass/fail badges
- Assertion types: response content, tool usage, state changes, table data, workflow triggers
- Outcome summary (passed/failed/pending counts)
- Elapsed time, turn counts
- **Runs tab** (`/evals/runs`): run history with timestamps and status
- Download results button

---

## Data

### Knowledge (`/knowledge`)

Manage knowledge bases and uploaded files.

**Layout:** Sidebar (KB list) + toolbar + file grid

**Features:**
- Knowledge base list with icons and descriptions
- File grid: name, size, upload date, status badge (synced/syncing/error/local)
- Filter by name, source, status, date range
- Sort by name, date, or size
- File detail drawer: metadata, embedding status, delete/sync/copy path
- KB sync dialog to upload and sync files
- Pagination for large file lists

### Tables (`/tables`)

Manage agent data tables.

**Layout:** Sidebar (table list) + toolbar + data grid + pagination

**Features:**
- Table definitions with row counts
- Sortable, filterable data grid (100 rows/page)
- Add/edit/delete rows
- Import/export data
- "Transfer to prod" option (with confirmation modal)
- "Recreate table" for schema changes
- Column headers with sort indicators

### Files (`/files`) — dev only

Browse agent files.

**Layout:** Folder browser

**Features:**
- Folder tree: All Files, Knowledge Base, System, Webchat
- File list with name, size, modification time
- Copy file path button
- Hover cards with full file info
- Browser-style navigation (back/forward/refresh)

---

## Observe

### Conversations (`/conversations`) — dev only

View all conversations with the agent.

**Layout:** Full-page table

**Features:**
- Table columns: ID, Integration → Channel, Created, Updated, Preview
- Sortable columns
- Real-time polling for new conversations
- Click row to inspect conversation

### Traces (`/traces`) — dev only

Deep execution trace inspection. More detailed than Agent Steps — shows the full span tree including internal runtime spans.

**Layout:** Full-page trace viewer

**Features:**
- Hierarchical span tree grouped by parent
- Span detail panel: name, timing, status, full data payload
- JSON and tree view of span data
- Filter by trace ID or conversation ID
- Auto-refresh
- Trace-level cost calculation
- Timeline visualization showing concurrent spans

### Logs (`/logs`) — dev only

Agent runtime logs.

**Layout:** Full-page log viewer

**Features:**
- Real-time log stream (stdout, stderr, info)
- Time range filters: 5m, 15m, 1h, 6h, all
- Text search/filter
- Color-coded: green (stdout), red (stderr), blue (info)
- ANSI color support (terminal-style rendering)
- Pause/play, clear, copy buttons
- Collapsible JSON payload inspection

---

## Config

### Settings (`/settings`)

Agent configuration management.

**Sections (sidebar navigation):**
1. **Overview** — Agent metadata: name, Bot ID, Workspace ID, file path, created/updated dates. Copy buttons for IDs.
2. **Configuration Variables** (dev only) — Runtime config schema and values. Add/edit/delete variables.
3. **Secrets** (dev only) — Secret schema and values. Add/edit/delete secrets.
4. **LLM Config** (dev only) — Model selection and parameters.

### Integrations (`/integrations`)

Install, configure, and manage integrations.

**Features:**
- Integration Hub UI (Botpress component)
- OAuth redirect handling
- Integration name and alias resolution
- Configuration editing via UI
- Installation status per integration
- Configured integrations' actions appear on the Actions page

---

## Dev vs. Production Mode

The environment toggle in the top navigation switches between dev and prod:

**Dev mode** (default during `adk dev`): All pages and features available.

**Production mode**: Hides development-only pages (Actions, Workflows, Triggers, Evals, Files, Conversations, Traces, Logs) and restricts some Settings sections. Chat, Search, Knowledge, Tables, Integrations, and Settings Overview remain available.
