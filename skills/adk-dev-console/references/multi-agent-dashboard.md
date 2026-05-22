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

The following commands manage the multi-agent Dev Console from the terminal. For full options, flags, and examples, see the [CLI Reference](../../adk/references/cli.md).

| Command | What it does |
|---------|-------------|
| `adk agents` | List all agents registered with the Dev Console |
| `adk ps` | List running processes with PIDs, ports, uptime (`--watch` for live refresh) |
| `adk dashboard` | Open the Dev Console standalone — no agent project required |
| `adk kill` | Stop agents or the entire Dev Console (`--all`, `--current`, `--pid`, or by name) |
| `adk status` | Show project health and status info |

## Data Isolation

Each agent's data is isolated to its own project directory (`.adk/`). Traces, logs, eval results, and dev bot IDs stay per-project — switching agents in the UI switches the data you see.
