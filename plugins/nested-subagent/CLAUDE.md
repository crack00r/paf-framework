# CLAUDE.md - nested-subagent Plugin

> **NOTE:** This CLAUDE.md applies **ONLY to plugin development**.
> - For normal PAF usage, this file is irrelevant
> - Do not mix with the Framework CLAUDE.md (`/paf-framework/CLAUDE.md`)
> - These instructions only concern developers working on the plugin itself

---

Context for Claude Code when working with this plugin.

## Project Overview

This plugin is an integral component of the PAF Framework. It enables **unlimited hierarchical agent nesting** - essential for PAF's 38-agent architecture.

Claude Code's native Task tool blocks subagents from spawning additional subagents (via tool filtering). This plugin bypasses this limitation by spawning fresh `claude -p` processes, which are complete main agents with full tool access.

## Commands

### Build & Development

```bash
cd mcp-server && npm run build      # Build MCP Server (tsdown)
cd mcp-server && npm run dev        # Development Mode (tsx)
cd mcp-server && npm run typecheck  # TypeScript Type-Checking
```

### Testing

```bash
cd mcp-server && npm run test           # Unit Tests
cd mcp-server && npm run test:watch     # Watch Mode
cd mcp-server && npm run test:integration  # Integration Tests
```

## Architecture

### Core Insight

The native Task tool's recursion blocker (`.filter(_ => _.name !== AgentTool.name)`) is **process-local**. By spawning a fresh `claude -p` process via MCP, we create a new main agent with full tool access including the Task tool.

```
Native:  Main → Subagent → BLOCKED (Task tool filtered)
Plugin:  Main → MCP Tool → spawn "claude -p" → Fresh Main Agent → CAN use Task → Unlimited
```

### Directory Structure

```
nested-subagent/
├── mcp-server/
│   ├── src/index.ts        # MCP Server Implementation (Kern-Logik)
│   ├── dist/               # Build Output
│   └── test/               # Tests
├── README.md
├── LICENSE
└── CLAUDE.md
```

### MCP Server (`mcp-server/src/index.ts`)

The MCP server exposes a tool named `Task`:

1. Spawns `claude -p --output-format stream-json --verbose` subprocess
2. Parses streaming JSON output line by line for real-time progress
3. Emits MCP `notifications/progress` for each tool use
4. Handles abort via SIGTERM/SIGKILL

**Critical detail:** `proc.stdin?.end()` must be called immediately after spawn - the prompt is passed via CLI argument, not via stdin.

## Tool Parameters

The `mcp__plugin_nested_subagent__Task` tool accepts:

| Parameter | Type | Description |
|-----------|------|-------------|
| `prompt` | string | **Required.** Task for the agent |
| `model` | string | `sonnet`, `opus`, or `haiku` (Default: `sonnet`) |
| `timeout` | number | Timeout in ms (Default: `600000`) |
| `allowWrite` | boolean | Enable write permissions |
| `permissionMode` | string | `default`, `acceptEdits`, `bypassPermissions`, or `plan` |
| `systemPrompt` | string | Custom System Prompt |
| `allowedTools` | string[] | Allowed tools (overrides default) |
| `disallowedTools` | string[] | Forbidden tools |
| `maxBudgetUsd` | number | Cost limit in USD |

## Debug Logging

All MCP server operations log to `/tmp/paf-nested-subagent-debug.log` for troubleshooting.
