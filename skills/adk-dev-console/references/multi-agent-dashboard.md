# Multi-Agent Dashboard

The Dev Console is a **singleton shared dashboard** that coordinates multiple running agents. Each `adk dev` process registers its agent with the shared DevConsole, and the UI lets developers switch between them instantly.

## Architecture

```
Browser → DevConsole UI Server (singleton, :3001+) → proxies to selected agent's backend
                    ↑
    adk dev (agent A) ──socket──┤
    adk dev (agent B) ──socket──┤
    adk dev (agent C) ──socket──┘
```

- **DevConsole UI Server** — detached singleton per user. Serves the React dashboard, owns the agent registry, proxies requests to agent backends.
- **`adk dev` process** — one per agent project. Runs the bot runtime, agent API backend, span ingest, file watcher. Connects to the singleton via Unix socket (`~/.adk/console.sock`).
- **Browser never talks directly to an agent backend** — all requests go through the singleton, which routes by selected agent.

## Agent Lifecycle

Each agent reports its status via heartbeats:

| Status | Meaning |
|--------|---------|
| `starting` | Agent is initializing (building, syncing) |
| `ready` | Agent is running and accepting requests |
| `error` | Agent encountered a fatal error |

Agents that miss heartbeats are evicted from the registry. On clean shutdown (`Ctrl+C`), the agent sends a deregister message. If all agents disconnect and the singleton was started in managed mode (spawned by `adk dev`), it exits after a grace period. Standalone mode (`adk dashboard`) keeps the singleton alive with an empty registry.

## Console Modes

The Dev Console supports two orthogonal concepts:

### Console Mode — where is the console operating?

- **Local Dev Console** — selects a local project registered over the socket. This is the default during `adk dev`.
- **Cloud Dev Console** — selects a deployed Botpress Cloud prod bot from the prod bot picker. No local project backend needed.

### Target — which bot data is used?

- **Dev target** — uses the local project's dev bot ID and local backend. All pages available.
- **Prod target** — uses the deployed prod bot data. Hides dev-only pages (Actions, Workflows, Triggers, Evals, Files, Conversations, Traces, Logs).

| Console Mode | Dev Target | Prod Target |
|-------------|------------|-------------|
| Local | Local dev bot + all pages | Prod bot data + restricted pages |
| Cloud | Not available | Prod bot data + restricted pages |

Prod views that need ADK source-shaped definitions (actions, workflows, triggers, tables, knowledge) read **deployed metadata** published by `adk deploy`, not local source files. This is true in both local-prod and cloud-prod modes.

## Agent Selector UI

### Sidebar Header

Full-width dropdown trigger showing: ADK logo, status ring (color matches agent status), agent name, mode pill (dev/prod/cloud), chevron.

### Dropdown Content

- **Active agents section** — lists running local agents with status dot, name, project path (truncated right-to-left), and close button
- **Cloud Dev Console** — switches to the prod bot picker (workspace dropdown → bot list), shows recent prod bots
- **Recent projects** — projects previously opened but not currently running
- **Footer actions** — Create new project, Open existing project, Switch environment (dev↔prod), About

### Topbar Agent Picker

Compact pill in the top navigation center: status dot + agent name + mode pill + chevron. Opens the same dropdown content. Falls back to a non-interactive label if no agents are connected.

## Routing

All browser requests to the selected agent go through `buildApiUrl(path)`, which appends `?agent=<selectedAgentPath>`.

The singleton resolves the target agent with this precedence:
1. `?agent=<absolute-agent-path>` query parameter
2. `X-Agent-Path` header
3. If exactly one agent is registered, use it implicitly
4. If multiple agents and no selector → `400 Ambiguous agent`

The refusal to guess when ambiguous is intentional — it prevents accidentally mutating the wrong bot.

## CLI Commands

### `adk agents`

Lists all agents currently registered with the DevConsole. Shows agent name, status, runtime version, ports, and project path.

### `adk ps`

Lists running ADK dev processes (console + agents). Shows PID, status, uptime, and ports. Supports `--watch [seconds]` for continuous refresh and `--format json` for structured output.

### `adk dashboard`

Opens the DevConsole UI server in standalone mode — no agent project required. Useful for browsing the dashboard, connecting to Cloud bots, or waiting for agents to register. Automatically opens the browser.

### `adk kill`

Gracefully stops agents or the entire DevConsole.

| Flag | What it stops |
|------|---------------|
| `--all` | All agents + the DevConsole singleton |
| `--current` | The agent in the current working directory |
| `--pid <pid>` | A specific process by PID |
| (positional) | Agents by name or path |

Supports `--force` for SIGKILL escalation and `--dry-run` to preview without acting. Cleans up stale state files (`console.sock`, `console.port`, `console.lock`) on console shutdown.

### `adk status`

Displays project health and status information. Returns JSON when `--format json` is passed.

## Per-User and Per-Project Files

**Per-user** (`~/.adk/`):

| File | Purpose |
|------|---------|
| `console.sock` | Unix socket for agent registration |
| `console.port` | Persisted HTTP port for CLI/browser discovery |
| `console.lock` | Spawn lock preventing duplicate singletons |

**Per-project** (`.adk/`):

| File | Purpose |
|------|---------|
| `traces.db` | SQLite trace store for that agent |
| `dev-ids.json` | Dev bot ID preservation |
| `logs/` | Session logs |
| `evals/runs/` | Eval run results |

Agent-local data stays agent-local. Traces, logs, eval results, and dev bot IDs live under the project's `.adk/` directory, not in the singleton.
