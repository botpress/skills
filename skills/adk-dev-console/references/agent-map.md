# Agent Map

The Agent Map (`/agent-map`) is a full-screen interactive graph that visualizes the agent's architecture — every primitive and the relationships between them. It uses static analysis (AST parsing) of the agent's source code to build the graph, streamed in real time as files change.

Accessed from the **Build** or **Observe** tab groups. Requires feature flag `enable_agent_forge`. Dev-only.

## Data Model: AgentSnapshot

The graph is built from an `AgentSnapshot` — a structured representation of all agent primitives and their edges.

### Primitives (nodes)

**Handlers** (have code that runs):
- **Conversation** — channel-specific message handlers
- **Workflow** — multi-step stateful processes
- **Trigger** — event-driven handlers

**Leaves** (called by handlers):
- **Action** — reusable functions
- **Tool** — standalone autonomous tools
- **Table** — persistent data storage
- **Knowledge** — RAG data sources
- **CustomComponent** — webchat UI components the LLM can yield

**Synthetic** (derived from AST analysis, not user-defined files):
- **AIAgent** — one per `execute({...})` call site inside a handler. Shows model, tool refs, knowledge refs, instructions, hooks, exits.
- **IntegrationAction** — one per `actions.<alias>.<name>(...)` call site.
- **Trigger Entry** — channel messages, integration events, or cron schedules that activate a trigger.
- **Model Node** — one per unique model string referenced by AI agents.

### Edges (relationships)

| Type | Meaning | Example |
|------|---------|---------|
| `invokes` | One primitive calls another | Workflow invokes an Action |
| `reads` | Reads from a table | Action reads from `orders` table |
| `writes` | Writes to a table | Workflow writes to `audit_log` table |
| `queries` | Queries a table | Tool queries `users` table |
| `uses_component` | Conversation binds a custom component | Conversation registers a `ProductCard` component |

### Common fields on every primitive

- `id` — unique identifier (e.g., `action:validateOrder`, `conversation:src_conversations_support`)
- `definedAt` — source file path + line range (1-based)
- `parseStatus` — success or partial/failed parse state

## Visual Mapping

### Node shapes

| Shape | Types |
|-------|-------|
| Square | Conversation, Workflow, Trigger (handlers) |
| Circle | Action, Tool, Table, Knowledge, CustomComponent, IntegrationAction, Model Node (leaves) |
| Wide rectangle | AIAgent (with bottom sub-handles for model, tool, knowledge ports) |
| Pill/tile | Trigger Entry (with lightning-bolt accent on left edge) |

### Node colors

| Type | Color |
|------|-------|
| Action | Red (`#EF4444`) |
| Tool | Purple (`#8B5CF6`) |
| Workflow | Amber (`#F59E0B`) |
| Conversation | Green (`#10B981`) |
| Trigger | Orange (`#F97316`) |
| Table | Cyan (`#06B6D4`) |
| Knowledge | Pink (`#EC4899`) |
| CustomComponent | Light purple (`#A78BFA`) |
| IntegrationAction | Medium purple (`#C084FC`) |
| AIAgent | Indigo (`#6366F1`) |
| Trigger Entry | Blue accent (`#3B82F6`) with integration icon |
| Model Node | Indigo (`#6366F1`), same as AIAgent |

### Visual states

- **Orphan nodes** (unconnected): shown at 58% opacity, brighten on hover/select
- **Selected node**: highlighted with border, background, and shadow
- **Hover**: frame appears around node

## Interactions

- **Click node** — opens detail panel (right sidebar, 340px) with metadata, definition location, and action buttons
- **Detail panel actions**: invoke action/workflow, open related page, open source file in editor
- **Drag node** — reposition; persisted in localStorage per agent
- **Pan/Zoom** — mouse wheel zoom (0.1x–2x range), drag to pan
- **Reset layout** — button to clear persisted positions and recompute ElkJS layout

## Real-Time Updates

- Connects via SSE to `/api/agent-map/stream`
- File watchers detect source changes, coalesce bursts, and broadcast updated snapshots
- Events: `snapshot` (full AgentSnapshot), `parse-error` (partial failure, snapshot retained), `keepalive` (30s heartbeat)
- Loading spinner while connecting; error state with fallback message if stream unavailable

## Limitations

The agent map uses best-effort static analysis (AST parsing). It cannot capture:
- Fully dynamic tool registration or conditional logic that only runs at runtime
- Template literals or computed property names in call sites
- Code paths that are never statically reachable

Parse warnings are shown in the UI when extraction is incomplete.
