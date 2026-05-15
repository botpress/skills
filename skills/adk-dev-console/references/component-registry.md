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

Shows available components from the external component registry.

- Same masonry layout as the Installed tab
- Click a card to expand an overlay with installation instructions and metadata
- Empty state: "Registry is empty"

## Creating Custom Components

Custom components are React function components in `.bp.tsx` files inside `src/components/`.

### 1. Create the component file

```tsx
// src/components/TicketCard.bp.tsx
import React from 'react'

type Props = {
  ticketId: string
  title: string
  priority: 'low' | 'medium' | 'high' | 'urgent'
  status: string
}

const TicketCard: React.FC<Props> = ({ ticketId, title, priority, status }) => (
  <div style={{ padding: 16, borderRadius: 8, background: '#f8fafc', fontFamily: 'sans-serif' }}>
    <strong>{title}</strong>
    <p style={{ margin: '4px 0', fontSize: 13, color: '#64748b' }}>
      {ticketId} · {priority} · {status}
    </p>
  </div>
)

export default TicketCard
```

### 2. Register in `src/components/index.ts`

```typescript
import { CustomComponent, z } from '@botpress/runtime'
import TicketCard from './TicketCard.bp.tsx'

export const TicketCardComponent = new CustomComponent(TicketCard, {
  description: 'Display a ticket summary card. Use after creating or looking up a ticket.',
  props: z.object({
    ticketId: z.string().describe('The ticket ID'),
    title: z.string().describe('Short summary of the issue'),
    priority: z.enum(['low', 'medium', 'high', 'urgent']).describe('Priority level'),
    status: z.string().describe('Current ticket status'),
  }),
  exampleValues: [
    { ticketId: 'TKT-001', title: 'VPN not working', priority: 'high', status: 'open' },
    { ticketId: 'TKT-042', title: "Can't access email", priority: 'low', status: 'in-progress' },
  ],
})
```

The metadata fields:
- **description** — shown in the dev console and tells the LLM when to use this component
- **props** — Zod schema for the component's props; drives dev console forms and LLM prop validation
- **exampleValues** — seed values for dev console previews and LLM usage examples

Components without metadata can still be sent directly but cannot be listed in `Conversation.components` (the LLM won't know about them).

### 3. Add to a conversation

```typescript
import { Conversation } from '@botpress/runtime'
import { TicketCardComponent } from '../components'

export const Chat = new Conversation({
  channel: 'webchat.channel',
  components: [TicketCardComponent],

  async handler({ execute }) {
    await execute({
      instructions: 'Always use the TicketCard component to display ticket details.',
    })
  },
})
```

Components listed in `components` are auto-registered so the LLM can yield them during autonomous execution.

### 4. Send a component directly

Outside of autonomous execution, you can send a component message explicitly:

```typescript
import { WelcomeBannerComponent } from '../components'

await conversation.send({
  type: 'customComponent',
  payload: {
    component: WelcomeBannerComponent,
    props: {},
  },
})
```

## Component Lifecycle

1. **Create** — Add a `.bp.tsx` file in `src/components/` and register it in `index.ts`
2. **Preview** — The Installed tab shows live previews; edit your `.bp.tsx` and see changes instantly
3. **Register** — List the component in a `Conversation`'s `components` array so the LLM can use it
4. **Deploy** — `adk deploy` bundles and uploads components; URLs are resolved automatically
5. **Render** — The webchat renders the component when the LLM yields it or you send it explicitly

## File Naming Conventions

- `.bp.tsx` — React component source
- `.bp.css` — Optional component styles (scoped via shadow DOM)

## UI Features

- **Shadow DOM previews** — component previews render in isolated shadow DOM to prevent style leaking
- **Loading skeletons** — placeholder cards while fetching components
- **Error states** — red alerts if components fail to load or registry fetch fails
- **Live reload** — listens for component change events and refreshes the gallery
