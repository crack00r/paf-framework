# PAF Nested Subagent Plugin

> Integral component of the PAF Framework

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PAF](https://img.shields.io/badge/PAF-Framework-blue)](https://github.com/crack00r/paf-framework)

Enables **unlimited hierarchical agent nesting** in Claude Code. Agents can spawn additional agents - essential for PAF's 38-agent architecture.

---

## How It Works

Claude Code's native Task tool **blocks subagents from spawning additional subagents**:

```
Native Task:       CTO → Agent → BLOCKED (Task tool filtered)
PAF Plugin:        CTO → Agent → Agent → Agent → ... (unlimited)
```

The plugin spawns fresh `claude -p` processes. Each process is an isolated main agent with full tool access - including the ability to spawn additional agents.

### PAF Hierarchy Example

```
CTO (Level 0)
 └─→ Sarah (Level 1) - Lead Developer
      └─→ Chris (Level 2) - Frontend
           └─→ Worker (Level 3) - Component
      └─→ Dan (Level 2) - Backend
           └─→ Worker (Level 3) - API
                └─→ Worker (Level 4) - Database
```

---

## Installation

The plugin is installed automatically with PAF:

```bash
cd ~/.paf && ./install.sh
```

### Manual Build (if needed)

```bash
cd ~/.paf/plugins/nested-subagent/mcp-server
npm install
npm run build
```

---

## Tool Reference

The `mcp__plugin_nested_subagent__Task` tool:

| Parameter | Type | Description |
|-----------|------|-------------|
| `prompt` | string | **Required.** The task for the agent |
| `description` | string | Short summary (3-5 words) |
| `model` | string | `sonnet`, `opus`, or `haiku` (default: sonnet) |
| `allowWrite` | boolean | Enable write permissions |
| `timeout` | number | Timeout in ms (default: 600000) |
| `systemPrompt` | string | Custom System Prompt |
| `allowedTools` | string[] | Restrict to specific tools |
| `maxBudgetUsd` | number | Cost limit for the task |

### Usage in PAF Agents

```typescript
// CTO spawns Sarah
mcp__plugin_nested_subagent__Task({
  prompt: "Implement feature X...",
  description: "Sarah Implementation",
  model: "sonnet",
  allowWrite: true,
  timeout: 600000
})
```

---

## Features

| Feature | Status |
|---------|--------|
| Unlimited nesting depth | ✅ |
| Context isolation (fresh 200k) | ✅ |
| Real-time progress | ✅ |
| Token & cost tracking | ✅ |
| Model selection | ✅ |
| Tool restrictions | ✅ |
| Budget limits | ✅ |
| Abort / Cancel | ✅ |

---

## Architecture

See [ARCHITECTURE.md](./ARCHITECTURE.md) for technical details.

## License

MIT License - see [LICENSE](./LICENSE)
