# Multi-Agent Dashboard

The Dev Console is a **singleton shared dashboard** that coordinates multiple running agents. Each `adk dev` process registers its agent with the shared DevConsole, and the UI lets developers switch between them instantly.

## How It Works

Running `adk dev` in multiple project directories registers each agent with a single shared DevConsole. The UI automatically updates to show all running agents, and developers can switch between them from the sidebar.

Each agent shows a status indicator:

| Status | Meaning |
|--------|---------|
| `starting` | Agent is initializing (building, syncing) |
| `ready` | Agent is running and accepting requests |
| `error` | Agent encountered a fatal error |

If all agents are stopped, the DevConsole exits automatically (unless started in standalone mode via `adk dashboard`).

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

## Data Isolation

Each agent's data is isolated to its own project directory (`.adk/`). Traces, logs, eval results, and dev bot IDs stay per-project — switching agents in the UI switches the data you see.
