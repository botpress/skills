# Component Registry

The Components page (`/components`) lets developers browse, inspect, and install custom webchat components — UI elements the LLM can yield during conversations.

Accessed from the **Components** tab group. Available in both dev and production modes.

## Two-Tab Interface

### Installed Tab

Shows components currently present in the agent's `src/components/` directory.

- Masonry card layout with live component preview (rendered in shadow DOM for style isolation)
- Click a card to expand an overlay with full component details
- Reflects hot-reload changes — components update as source files are modified
- Empty state: "No components installed yet" with guidance to add under `src/components` or pull from the registry

### Registry Tab

Shows available components from the external component registry (published via CI).

- Same masonry layout as the Installed tab
- Click a card to expand an overlay with installation instructions and metadata
- Empty state: "Registry is empty" — the registry requires a CI pipeline to publish a component manifest

## Component Lifecycle

1. **Registry publish** — CI publishes component manifests to the registry
2. **Browse** — Developer views available components in the Registry tab
3. **Install** — Developer adds the component to `src/components/` (following overlay instructions)
4. **Registration** — At runtime, when a conversation starts on webchat, custom components are auto-registered in the Chat class's internal component registry (`componentRegistry: Map<string, ComponentRegistration>`)
5. **LLM usage** — The autonomous agent can yield registered components during execution; the component handler renders them in the webchat

## Runtime Component Registry (Chat class)

The runtime component registry is a `Map<string, ComponentRegistration>` inside the `Chat` class. It manages which components the LLM can yield and how they're rendered.

### Registration types

**Built-in components** — registered automatically in the Chat constructor based on integration type:
- Webchat: Text, Audio, Image, Video, Location, Choice, Dropdown, Carousel
- Other integrations: Text only

**Custom components** — auto-registered when a conversation starts on webchat. Each custom component from the Components page becomes an `Autonomous.Component` in the registry with a handler that sends it as a `customComponent` message type.

### ComponentRegistration structure

Each registration contains:
- **component** — an `Autonomous.Component` instance with name, aliases, description, usage examples, and a Zod props schema
- **handler** (optional) — async function that processes the rendered component. If not provided, the default handler sends the message via the Botpress API.

### Lookup behavior

When the LLM yields a component:
1. Exact name match (lowercased) in the registry
2. Fallback: search by component aliases
3. Dispatch to the registered handler or the default API handler

## UI Features

- **Shadow DOM previews** — component previews render in isolated shadow DOM to prevent style leaking
- **Loading skeletons** — 6 placeholders (installed) or 9 placeholders (registry) while fetching
- **Error states** — red alerts if components fail to load or registry fetch fails
- **Live reload** — listens for component change events and refreshes the gallery
