# MCP list_changed Integration

## Overview

Claude Code 2.1.x supports MCP `list_changed` notifications for dynamic tool discovery. This enables PAF:

1. Dynamically add/remove agents at runtime
2. Update agent capabilities without restart
3. Support real-time COMMS.md monitoring

## Current Implementation

The nested-subagent plugin (`plugins/nested-subagent/`) provides agent spawning via the `Task` tool.

## Planned Extension

### 1. Add Resource Discovery

```typescript
// In mcp-server/src/index.ts

// Define PAF resources
const resources = [
  {
    uri: "paf://agents",
    name: "PAF Agents",
    description: "List of available PAF agents",
    mimeType: "application/json"
  },
  {
    uri: "paf://comms",
    name: "COMMS Status",
    description: "Real-time agent communication status",
    mimeType: "text/markdown"
  },
  {
    uri: "paf://builds",
    name: "Build Presets",
    description: "Available build presets",
    mimeType: "application/yaml"
  }
];

// Register resource handlers
server.setRequestHandler(ListResourcesRequestSchema, async () => ({
  resources
}));

server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
  const uri = request.params.uri;

  if (uri === "paf://agents") {
    const agents = await loadAgents();
    return {
      contents: [{
        uri,
        mimeType: "application/json",
        text: JSON.stringify(agents, null, 2)
      }]
    };
  }

  if (uri === "paf://comms") {
    const comms = await fs.readFile(COMMS_PATH, 'utf-8');
    return {
      contents: [{
        uri,
        mimeType: "text/markdown",
        text: comms
      }]
    };
  }

  // ... handle other resources
});
```

### 2. Implement list_changed Notifications

```typescript
// Watch for agent changes
const agentWatcher = chokidar.watch(AGENTS_DIR, {
  persistent: true,
  ignoreInitial: true
});

agentWatcher.on('all', async (event, path) => {
  // Notify Claude Code about agent list change
  await server.notification({
    method: "notifications/resources/list_changed"
  });

  console.log(`[PAF] Agent change detected: ${event} ${path}`);
});

// Watch COMMS.md for status updates
const commsWatcher = chokidar.watch(COMMS_PATH, {
  persistent: true
});

commsWatcher.on('change', async () => {
  // Notify about COMMS update
  await server.notification({
    method: "notifications/resources/updated",
    params: {
      uri: "paf://comms"
    }
  });
});
```

### 3. Dynamic Tool Updates

```typescript
// Track active agents
let activeAgents: Set<string> = new Set();

// Update tools on agent changes
async function updateAgentTools() {
  const agents = await loadAgents();

  // Create spawn tool for each agent
  const spawnTools = agents.map(agent => ({
    name: `spawn_${agent.name}`,
    description: `Spawn ${agent.emoji} ${agent.role}`,
    inputSchema: {
      type: "object",
      properties: {
        task: { type: "string", description: "Task for the agent" },
        timeout: { type: "number", default: 180 }
      },
      required: ["task"]
    }
  }));

  // Notify Claude Code about tool list change
  await server.notification({
    method: "notifications/tools/list_changed"
  });
}
```

## Usage Example

```typescript
// Claude Code can now:

// 1. List available agents
const agents = await mcp.readResource("paf://agents");

// 2. Monitor COMMS.md in real-time
const comms = await mcp.readResource("paf://comms");

// 3. Be notified about agent changes
mcp.on("notifications/resources/list_changed", () => {
  console.log("Agent list updated!");
});

// 4. Dynamically spawn new agents
await mcp.callTool("spawn_alex", { task: "Security Review" });
```

## Implementation Steps

1. **Phase 1: Resource Registration**
   - Add resource definitions to MCP server
   - Implement ReadResource handlers
   - Test with MCP Inspector

2. **Phase 2: File Watching**
   - Add chokidar for file watching
   - Implement list_changed notifications
   - Test real-time updates

3. **Phase 3: Dynamic Tools**
   - Generate tools from agent definitions
   - Implement tool list changes
   - Test dynamic agent adding

## Benefits

| Feature | Before | After |
|---------|--------|-------|
| Add new agent | Restart MCP server | Automatic detection |
| Monitor COMMS | Poll file manually | Real-time notifications |
| Agent capabilities | Static tool list | Dynamic per-agent tools |
| Resource discovery | Manual path lookup | MCP resource browser |

## Configuration

Add to `plugins/nested-subagent/.mcp.json`:

```json
{
  "mcpServers": {
    "paf": {
      "command": "node",
      "args": ["${CLAUDE_PLUGIN_ROOT}/mcp-server/dist/index.mjs"],
      "capabilities": {
        "resources": {
          "subscribe": true,
          "listChanged": true
        },
        "tools": {
          "listChanged": true
        }
      }
    }
  }
}
```

## Testing

```bash
# Test resource listing
npx @anthropic-ai/mcp-inspector plugins/nested-subagent

# Verify list_changed works
# 1. Start inspector
# 2. Add new agent file to agents/
# 3. Observe notification in inspector
```
