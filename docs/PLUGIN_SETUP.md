# Plugin Setup Guide

PAF includes an integrated MCP plugin for hierarchical agent orchestration.

## 🔌 PAF Plugin

### nested-subagent

The plugin enables unlimited agent nesting - essential for PAF's multi-agent architecture.

```
CTO → Perspective Agents (parallel)
CTO → Implementation Agents (parallel via Sarah coordination)
CTO → Rachel → Stan, Scanner, Perf (hierarchical)
```

## Prerequisites

1. **Claude Code** installed
2. **Claude Pro or Team** subscription (for MCP plugins)
3. **Node.js** v18+ (for plugin runtime)
4. **npm** package manager

## 🚀 Automatic Installation

The plugin is automatically installed with PAF:

```bash
git clone https://github.com/crack00r/paf-framework.git
cd paf-framework
./install.sh
```

The installer:
1. Copies files to `~/.paf/`
2. Builds the plugin (`npm install && npm run build`)
3. Registers the plugin via `claude mcp add`

## 🔧 Manual Plugin Build

If the plugin needs to be built manually:

```bash
cd ~/.paf/plugins/nested-subagent/mcp-server
npm install
npm run build
```

Verify:
```bash
ls ~/.paf/plugins/nested-subagent/mcp-server/dist/index.mjs
```

## Claude Code MCP Configuration

Register the plugin via Claude Code CLI:

```bash
# Add plugin
claude mcp add nested-subagent node ~/.paf/plugins/nested-subagent/mcp-server/dist/index.mjs -s user

# Verify it's registered
claude mcp list
```

**Note:** The path is automatically resolved. If there are issues, use the absolute path:

```bash
claude mcp add nested-subagent node /Users/YOUR_USERNAME/.paf/plugins/nested-subagent/mcp-server/dist/index.mjs -s user
```

### Remove plugin

```bash
claude mcp remove nested-subagent
```

## ✅ Verify Installation

Enter in Claude:
```
/paf-cto "Quick test"
```

If agents spawn, the plugin is working.

## Troubleshooting

### "Plugin not found" error

1. Check if plugin is registered: `claude mcp list`
2. Verify that `dist/index.mjs` exists
3. Re-register plugin: `claude mcp add nested-subagent node ~/.paf/plugins/nested-subagent/mcp-server/dist/index.mjs -s user`

### "Permission denied" error

```bash
chmod +x ~/.paf/plugins/nested-subagent/mcp-server/dist/index.mjs
```

### Agents don't spawn

1. Verify MCP server status: `claude mcp list`
2. Check debug log: `cat /tmp/paf-nested-subagent-debug.log`
3. Try a simple test command

### Plugin crashes

1. Check Node.js version: `node --version` (v18+ required)
2. Reinstall dependencies: `cd ~/.paf/plugins/nested-subagent/mcp-server && rm -rf node_modules && npm install`
3. Rebuild: `npm run build`

## 🧪 Test Plugin

### Basic Test

```
/paf-cto "Quick security check" --build=quick
```

Expected: CTO spawns 3-5 agents, receives responses.

### Parallel Test

```
/paf-cto "Full review" --build=comprehensive
```

Expected: All perspective agents spawn in parallel.

## 📊 Plugin Capabilities

| Feature | Description |
|---------|-------------|
| `Task` | Spawn sub-agent with specific task |
| `model` | Select model (sonnet, opus, haiku) |
| `timeout` | Set maximum execution time |
| `allowWrite` | Enable filesystem access |
| Unlimited depth | Agents spawn agents recursively |

### Example (CTO spawns agent)

```javascript
mcp__plugin_nested_subagent__Task({
  description: "Alex Security Review",
  prompt: "You are Alex, Security Analyst...",
  model: "sonnet",
  allowWrite: true,
  timeout: 600000
})
```

## Security Notes

- The plugin runs with your user permissions
- Sub-agents can read/write files when `allowWrite: true`
- Keep plugin installation secure

## Additional Resources

- [MCP Documentation](https://docs.anthropic.com/mcp)
- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [PAF Troubleshooting](TROUBLESHOOTING.md)

---

Need help? Open an issue on GitHub.
