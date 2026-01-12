/**
 * PAF Nested Subagent MCP Server - Streaming Edition
 *
 * This MCP server enables PAF's unlimited agent hierarchy by spawning fresh Claude processes
 * with REAL-TIME progress streaming using MCP progress notifications.
 *
 * KEY FEATURES:
 * - Uses `claude -p --output-format stream-json --verbose` for real-time streaming
 * - Emits MCP progress notifications for each tool use
 * - Supports abort via SIGTERM (graceful) and SIGKILL (forced)
 * - Passes through all relevant CLI options to match native Task tool behavior
 *
 * Architecture:
 * ```
 * Main Plugin Session
 *     └── MCP Tool: spawn_subagent({prompt, progressToken})
 *             │
 *             ├── Spawns: claude -p --output-format stream-json --verbose
 *             │
 *             ├── Parses streaming JSON line by line
 *             │
 *             ├── Emits: notifications/progress for each tool_use
 *             │
 *             └── Returns final result when complete
 * ```
 */

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool,
} from "@modelcontextprotocol/sdk/types.js";
import { spawn, ChildProcess } from "child_process";
import { createInterface } from "readline";
import { appendFileSync, writeFileSync, readFileSync, existsSync, openSync, closeSync, statSync, readSync } from "fs";

// Debug logging to file - use /tmp for reliable access
const LOG_FILE = "/tmp/paf-nested-subagent-debug.log";

/**
 * Sanitize agent name for safe use in shell commands and file paths.
 * CRITICAL SECURITY FIX: Prevents bash injection attacks.
 * Only allows alphanumeric characters, hyphens, and underscores.
 */
function sanitizeAgentName(name: string): string {
  return name.replace(/[^a-zA-Z0-9_-]/g, '_').slice(0, 64);
}

function log(message: string) {
  const timestamp = new Date().toISOString();
  const logLine = `[${timestamp}] ${message}\n`;
  try {
    appendFileSync(LOG_FILE, logLine);
  } catch {
    // Ignore logging errors
  }
}

// Initialize log file - APPEND instead of overwrite to preserve logs across sessions
const SERVER_INSTANCE_ID = `${Date.now()}-${Math.random().toString(36).slice(2, 6)}`;
try {
  appendFileSync(LOG_FILE, `\n=== PAF Nested Subagent MCP Server Started (instance: ${SERVER_INSTANCE_ID}) ===\n`);
  appendFileSync(LOG_FILE, `CLAUDE_PLUGIN_ROOT=${process.env.CLAUDE_PLUGIN_ROOT || '(not set)'}\n`);
} catch {
  // Ignore
}

// Types for Claude CLI stream-json output
interface StreamMessage {
  type: "system" | "assistant" | "user" | "result";
  subtype?: string;
  message?: {
    content: Array<{
      type: "text" | "tool_use" | "tool_result";
      text?: string;
      name?: string;
      id?: string;
      input?: Record<string, unknown>;
      content?: string;
    }>;
  };
  session_id?: string;
  uuid?: string;
  result?: string;
  is_error?: boolean;
  duration_ms?: number;
  total_cost_usd?: number;
  usage?: {
    input_tokens: number;
    output_tokens: number;
    cache_read_input_tokens?: number;
    cache_creation_input_tokens?: number;
  };
  tool_use_result?: {
    stdout?: string;
    stderr?: string;
    interrupted?: boolean;
  };
}

// Tool definition - named "Task" to match native Task tool UX
const NESTED_TASK_TOOL: Tool = {
  name: "Task",
  description: `Launch a new agent that has access to all tools including Task. When you are searching for a keyword or file and are not confident that you will find the right match on the first try, use the Agent tool to perform the search for you. For example:

- If you are searching for a keyword like "config" or "logger", the Agent tool is appropriate
- If you want to read a specific file path, use the Read or Glob tool instead of the Agent tool, to find the match more quickly
- If you are searching for a specific class definition like "class Foo", use the Glob tool instead, to find the match more quickly

Usage notes:
1. Launch multiple agents concurrently whenever possible, to maximize performance; to do that, use a single message with multiple tool uses
2. When the agent is done, it will return a single message back to you. The result returned by the agent is not visible to the user. To show the user the result, you should send a text message back to the user with a concise summary of the result.
3. Each agent invocation is stateless. You will not be able to send additional messages to the agent, nor will the agent be able to communicate with you outside of its final report. Therefore, your prompt should contain a highly detailed task description for the agent to perform autonomously and you should specify exactly what information the agent should return back to you in its final and only message to you.
4. The agent's outputs should generally be trusted
5. IMPORTANT: The spawned agent runs as a fresh process with its own 200k context window and CAN use the Task tool.`,
  inputSchema: {
    type: "object" as const,
    properties: {
      description: {
        type: "string",
        description: "A short (3-5 word) description of the task",
      },
      prompt: {
        type: "string",
        description: "The task for the agent to perform",
      },
      model: {
        type: "string",
        enum: ["sonnet", "opus", "haiku"],
        default: "sonnet",
        description: "Model to use (default: sonnet)",
      },
      workingDir: {
        type: "string",
        description: "Working directory (defaults to current)",
      },
      timeout: {
        type: "number",
        default: 1200000,
        description: "Timeout in ms (default: 20 minutes)",
      },
      allowWrite: {
        type: "boolean",
        default: false,
        description: "Enable file write permissions (--dangerously-skip-permissions)",
      },
      permissionMode: {
        type: "string",
        enum: ["default", "acceptEdits", "bypassPermissions", "plan"],
        description: "Permission mode for the spawned subagent",
      },
      systemPrompt: {
        type: "string",
        description: "Custom system prompt for the spawned subagent",
      },
      appendSystemPrompt: {
        type: "string",
        description: "Append to default system prompt",
      },
      allowedTools: {
        type: "array",
        items: { type: "string" },
        description: "List of allowed tools (e.g., ['Bash', 'Read', 'Edit'])",
      },
      disallowedTools: {
        type: "array",
        items: { type: "string" },
        description: "List of disallowed tools",
      },
      maxBudgetUsd: {
        type: "number",
        description: "Maximum API cost budget in USD",
      },
      addDirs: {
        type: "array",
        items: { type: "string" },
        description: "Additional directories to allow access to",
      },
      runInBackground: {
        type: "boolean",
        default: false,
        description: "Run agent in background and return immediately with taskId. Agent communicates via COMMS.md. Use this for parallel agent spawning without blocking.",
      },
      agentName: {
        type: "string",
        description: "Name of the agent (e.g., 'alex', 'sophia'). Used for tracking in background mode.",
      },
    },
    required: ["prompt"],
  },
};

interface TaskInput {
  description?: string;
  prompt: string;
  model?: "sonnet" | "opus" | "haiku";
  workingDir?: string;
  timeout?: number;
  allowWrite?: boolean;
  permissionMode?: "default" | "acceptEdits" | "bypassPermissions" | "plan";
  systemPrompt?: string;
  appendSystemPrompt?: string;
  allowedTools?: string[];
  disallowedTools?: string[];
  maxBudgetUsd?: number;
  addDirs?: string[];
  runInBackground?: boolean;
  agentName?: string;
}

// Track background tasks
interface BackgroundTask {
  taskId: string;
  agentName: string;
  pid: number;
  startTime: number;
  workingDir: string;
  status: "running" | "completed" | "failed" | "timeout";
  watchdogPid?: number;      // PID of timeout watchdog process
  timeoutAt?: number;        // Timestamp when task should timeout
  logFile?: string;          // Path to agent log file
  exitCode?: number | null;  // Process exit code (null = signal killed)
  endTime?: number;          // Timestamp when process ended
}

const backgroundTasks = new Map<string, BackgroundTask>();

// ============================================================
// FIX 1: Persistent Task Storage
// ============================================================
const TASKS_FILE = "/tmp/paf-background-tasks.json";

/**
 * Save all background tasks to persistent storage
 */
function saveTasksToFile(): void {
  try {
    const data: Record<string, BackgroundTask> = {};
    for (const [taskId, task] of backgroundTasks) {
      data[taskId] = task;
    }
    writeFileSync(TASKS_FILE, JSON.stringify(data, null, 2));
    log(`Saved ${backgroundTasks.size} tasks to ${TASKS_FILE}`);
  } catch (err) {
    log(`Failed to save tasks: ${err}`);
  }
}

/**
 * Load background tasks from persistent storage
 * FIX: Auto-cleanup old completed/failed tasks (>2 hours)
 */
const TASK_DISPLAY_MAX_AGE_MS = 2 * 60 * 60 * 1000; // 2 hours for completed/failed
const TASK_STORAGE_MAX_AGE_MS = 24 * 60 * 60 * 1000; // 24 hours max storage

function loadTasksFromFile(): void {
  try {
    if (!existsSync(TASKS_FILE)) {
      log("No tasks file found, starting fresh");
      return;
    }
    const data = JSON.parse(readFileSync(TASKS_FILE, "utf-8"));
    const now = Date.now();
    let loaded = 0;
    let cleaned = 0;
    let purged = 0;

    for (const [taskId, task] of Object.entries(data)) {
      const t = task as BackgroundTask;
      const age = now - t.startTime;

      // PURGE: Remove tasks older than 24 hours completely
      if (age > TASK_STORAGE_MAX_AGE_MS) {
        purged++;
        log(`[CLEANUP] Purged old task ${taskId} (age: ${Math.round(age / 3600000)}h)`);
        continue;
      }

      // Check if process is still running
      if (t.status === "running" && !isProcessRunning(t.pid)) {
        // Process died while we were away - mark as failed
        t.status = "failed";
        t.endTime = t.endTime || now;
        cleaned++;
      }

      backgroundTasks.set(taskId, t);
      loaded++;
    }
    log(`Loaded ${loaded} tasks from file (${cleaned} marked as failed, ${purged} purged)`);

    // Save back if we purged any
    if (purged > 0) {
      saveTasksToFile();
    }
  } catch (err) {
    log(`Failed to load tasks: ${err}`);
  }
}

// ============================================================
// FIX 5: COMMS.md Prologue for automatic communication
// FIX 7: GitHub Integration for issue creation
// ============================================================
function getCommsPrologue(agentName: string): string {
  // Agent-specific GitHub Prefixes
  const agentPrefixes: Record<string, { prefix: string; label: string; board: number }> = {
    alex: { prefix: "SEC", label: "🔒 alex", board: 25 },
    emma: { prefix: "PERF", label: "⚡ emma", board: 24 },
    sam: { prefix: "UX", label: "🎨 sam", board: 26 },
    david: { prefix: "SCALE", label: "🔀 david", board: 27 },
    max: { prefix: "MAINT", label: "🔧 max", board: 29 },
    luna: { prefix: "A11Y", label: "♿ luna", board: 26 },
    tom: { prefix: "COST", label: "💰 tom", board: 24 },
    nina: { prefix: "TRIAGE", label: "🎯 nina", board: 24 },
    leo: { prefix: "DOC", label: "📚 leo", board: 26 },
    ava: { prefix: "IDEA", label: "💡 ava", board: 26 },
    rachel: { prefix: "REV", label: "👁️ rachel", board: 24 },
    sophia: { prefix: "ARCH", label: "📐 sophia", board: 27 },
    maya: { prefix: "PRD", label: "📋 maya", board: 26 },
    george: { prefix: "RETRO", label: "🔄 george", board: 24 },
    otto: { prefix: "PROC", label: "⚙️ otto", board: 24 },
  };

  const agentConfig = agentPrefixes[agentName.toLowerCase()] || { prefix: "PAF", label: "🤖 agent", board: 24 };

  return `
## MANDATORY PROTOCOL (HIGHEST PRIORITY!)

You are Agent "${agentName}" in the PAF Multi-Agent System.

### EXECUTE IMMEDIATELY (BEFORE YOU DO ANYTHING ELSE):

1. **Update COMMS.md** - Write to .paf/COMMS.md:
   \`\`\`markdown
   <!-- AGENT:${agentName.toUpperCase()}:START -->
   ### Status: IN_PROGRESS
   ### Timestamp: ${new Date().toISOString()}

   **Task:** [Your task]
   **Progress:** Started...
   <!-- AGENT:${agentName.toUpperCase()}:END -->
   \`\`\`

2. **Every 2 minutes** - Update your progress in COMMS.md

3. **At the end** - Set status to COMPLETED:
   \`\`\`markdown
   ### Status: COMPLETED
   ### Timestamp: [NOW]
   **Findings:** [Your results]
   **Handoff:** @ORCHESTRATOR
   \`\`\`

### IMPORTANT:
- IF YOU DON'T UPDATE COMMS.MD, YOUR WORK WILL BE IGNORED!
- The CTO polls COMMS.md to see your progress
- Without updates you will be marked as TIMEOUT

---

## GITHUB INTEGRATION (MANDATORY FOR FINDINGS!)

For EVERY important finding, bug, or task create a GitHub Issue!

**Your Config:**
- Prefix: \`${agentConfig.prefix}\`
- Label: \`${agentConfig.label}\`
- Board: ${agentConfig.board}

**Create Issue (via Bash Tool):**
\`\`\`bash
# Read .paf/GITHUB_SYSTEM.md first for repository details!

# Create Finding Issue:
gh issue create -R owner/repo \\
  --title "[${agentConfig.prefix}-001] Brief description" \\
  --body "## Finding\\n\\nDescription...\\n\\n## Location\\n\\\`file.ts:42\\\`\\n\\n## Severity\\nP1\\n\\n## Recommendation\\n...\\n\\n---\\n_Generated by PAF Agent ${agentName}_" \\
  --label "finding,🤖 agent,${agentConfig.label}"
\`\`\`

**IMPORTANT:**
- Create Issues for P0/P1/P2 Findings (not P3)
- ALWAYS use your prefix [${agentConfig.prefix}-XXX]
- Number sequentially (001, 002, ...)

`;
}

// ============================================================
// FIX 6: Cleanup alter Tasks (24h max age)
// ============================================================
const MAX_TASK_AGE_MS = 24 * 60 * 60 * 1000; // 24 hours
const CLEANUP_INTERVAL_MS = 5 * 60 * 1000;   // 5 minutes

function cleanupOldTasks(): void {
  const now = Date.now();
  let cleaned = 0;

  for (const [taskId, task] of backgroundTasks) {
    const age = now - task.startTime;

    // Check for timeout - use graceful SIGTERM before SIGKILL
    if (task.status === "running" && task.timeoutAt && now > task.timeoutAt) {
      log(`[${taskId}] Task timed out, killing gracefully...`);
      if (isProcessRunning(task.pid)) {
        try {
          // FIX: Try SIGTERM first for graceful shutdown
          process.kill(task.pid, "SIGTERM");
          // Schedule SIGKILL if still running after 3 seconds
          const pidToKill = task.pid;
          setTimeout(() => {
            if (isProcessRunning(pidToKill)) {
              try {
                process.kill(pidToKill, "SIGKILL");
                log(`[${taskId}] SIGKILL sent after SIGTERM timeout`);
              } catch { /* ignore */ }
            }
          }, 3000).unref();
        } catch { /* ignore */ }
      }
      if (task.watchdogPid && isProcessRunning(task.watchdogPid)) {
        try {
          process.kill(task.watchdogPid, "SIGKILL");
        } catch { /* ignore */ }
      }
      task.status = "timeout";
      cleaned++;
    }

    // Check for old completed/failed tasks
    if (age > MAX_TASK_AGE_MS && task.status !== "running") {
      log(`[${taskId}] Removing old task (age: ${Math.round(age / 1000 / 60)}min)`);
      backgroundTasks.delete(taskId);
      cleaned++;
    }

    // Check for zombie processes (running status but process dead)
    if (task.status === "running" && !isProcessRunning(task.pid)) {
      task.status = "failed";
      cleaned++;
    }
  }

  if (cleaned > 0) {
    saveTasksToFile();
    log(`Cleanup: ${cleaned} tasks cleaned up`);
  }
}

// Start cleanup interval (store reference for shutdown)
const cleanupIntervalId = setInterval(cleanupOldTasks, CLEANUP_INTERVAL_MS);
cleanupIntervalId.unref(); // Don't prevent process exit

// ============================================================
// Additional Tools for Agent Management
// ============================================================

const TASK_LIST_TOOL: Tool = {
  name: "TaskList",
  description: `List all running background agents with their status, PID, and runtime.
Use this to monitor progress of spawned agents and detect stuck/hung agents.`,
  inputSchema: {
    type: "object" as const,
    properties: {},
    required: [],
  },
};

const TASK_KILL_TOOL: Tool = {
  name: "TaskKill",
  description: `Kill a running background agent by taskId or PID.
Use this to terminate stuck/hung agents that are not responding.`,
  inputSchema: {
    type: "object" as const,
    properties: {
      taskId: {
        type: "string",
        description: "The taskId returned from runInBackground spawn",
      },
      pid: {
        type: "number",
        description: "Process ID to kill (alternative to taskId)",
      },
    },
    required: [],
  },
};

const TASK_STATUS_TOOL: Tool = {
  name: "TaskStatus",
  description: `Check if a specific background agent is still running.
Returns process status and runtime information.`,
  inputSchema: {
    type: "object" as const,
    properties: {
      taskId: {
        type: "string",
        description: "The taskId to check status for",
      },
      pid: {
        type: "number",
        description: "Process ID to check (alternative to taskId)",
      },
    },
    required: [],
  },
};

// FIX C: TaskLog Tool - allows CTO to read agent output logs
const TASK_LOG_TOOL: Tool = {
  name: "TaskLog",
  description: `Read the log output of a background agent.
Returns the last N lines from the agent's log file. Use this to debug agent issues or see what an agent is doing.`,
  inputSchema: {
    type: "object" as const,
    properties: {
      taskId: {
        type: "string",
        description: "The taskId to read logs for",
      },
      lines: {
        type: "number",
        default: 100,
        description: "Number of lines to return (default: 100, max: 1000)",
      },
    },
    required: ["taskId"],
  },
};

/**
 * Check if a process with given PID is running
 * FIX: Validates pid > 0 to avoid unexpected behavior with invalid PIDs
 */
function isProcessRunning(pid: number): boolean {
  // Invalid PIDs: 0 = current process group, negative = process groups
  if (!pid || pid <= 0 || !Number.isInteger(pid)) {
    return false;
  }
  try {
    process.kill(pid, 0); // Signal 0 = just check if process exists
    return true;
  } catch {
    return false;
  }
}

/**
 * Sync task statuses with actual process states.
 * Call this periodically or before displaying task list.
 * Returns number of tasks that were updated.
 */
function syncTaskStatuses(): number {
  let updated = 0;
  for (const [taskId, task] of backgroundTasks) {
    if (task.status === "running" && !isProcessRunning(task.pid)) {
      task.status = "completed";
      task.endTime = Date.now();
      updated++;
    }
  }
  if (updated > 0) {
    saveTasksToFile();
    log(`Synced ${updated} task statuses`);
  }
  return updated;
}

/**
 * List all background tasks with their current status
 */
function listBackgroundTasks(): string {
  // Sync task statuses with actual process states (single batched save)
  syncTaskStatuses();

  if (backgroundTasks.size === 0) {
    return "📋 No background agents active.";
  }

  const now = Date.now();
  const lines: string[] = ["📋 **Background Agents:**\n"];
  let hiddenOldTasks = 0;

  // Sort tasks: running first, then by start time (newest first)
  const sortedTasks = Array.from(backgroundTasks.entries()).sort((a, b) => {
    // Running tasks first
    if (a[1].status === "running" && b[1].status !== "running") return -1;
    if (b[1].status === "running" && a[1].status !== "running") return 1;
    // Then by start time (newest first)
    return b[1].startTime - a[1].startTime;
  });

  for (const [taskId, task] of sortedTasks) {
    const age = now - task.startTime;

    // FILTER: Hide completed/failed tasks older than 2 hours
    if (task.status !== "running" && age > TASK_DISPLAY_MAX_AGE_MS) {
      hiddenOldTasks++;
      continue;
    }

    const runtime = Math.round((Date.now() - task.startTime) / 1000);
    const isRunning = isProcessRunning(task.pid);

    // Determine status icon and text
    let statusIcon: string;
    let statusText: string;
    switch (task.status) {
      case "running":
        statusIcon = isRunning ? "🟢" : "❓";
        statusText = isRunning ? "RUNNING" : "UNKNOWN";
        break;
      case "completed":
        statusIcon = "✅";
        statusText = "COMPLETED";
        break;
      case "failed":
        statusIcon = "❌";
        statusText = "FAILED";
        break;
      case "timeout":
        statusIcon = "⏰";
        statusText = "TIMEOUT";
        break;
      default:
        statusIcon = "❓";
        statusText = task.status;
    }

    // Calculate timeout info
    let timeoutInfo = "";
    if (task.timeoutAt && task.status === "running") {
      const remaining = Math.round((task.timeoutAt - Date.now()) / 1000);
      timeoutInfo = remaining > 0 ? ` (timeout in ${remaining}s)` : " (OVERDUE!)";
    }

    // Calculate actual runtime
    const actualRuntime = task.endTime
      ? Math.round((task.endTime - task.startTime) / 1000)
      : runtime;

    // Exit code display
    let exitInfo = "";
    if (task.exitCode !== undefined) {
      exitInfo = task.exitCode === 0
        ? " [exit: 0 ✅]"
        : task.exitCode === null
          ? " [killed by signal]"
          : ` [exit: ${task.exitCode} ❌]`;
    }

    lines.push(`${statusIcon} **${task.agentName}** (${statusText})${exitInfo}${timeoutInfo}`);
    lines.push(`   TaskID: ${taskId}`);
    lines.push(`   PID: ${task.pid}`);
    lines.push(`   Runtime: ${actualRuntime}s${task.endTime ? " (finished)" : ""}`);
    lines.push(`   WorkDir: ${task.workingDir}`);
    if (task.logFile) {
      lines.push(`   LogFile: ${task.logFile}`);
    }
    lines.push("");
  }

  // Show summary of hidden old tasks
  if (hiddenOldTasks > 0) {
    lines.push(`---`);
    lines.push(`📦 ${hiddenOldTasks} old tasks hidden (>2h). Will be automatically deleted after 24h.`);
  }

  // Show if no visible tasks after filtering
  if (lines.length === 1 && hiddenOldTasks > 0) {
    return `📋 No active background agents.\n📦 ${hiddenOldTasks} old tasks hidden (>2h).`;
  }

  return lines.join("\n");
}

/**
 * Kill a background task
 */
function killBackgroundTask(taskId?: string, pid?: number): string {
  let targetPid: number | undefined;
  let targetTask: BackgroundTask | undefined;

  if (taskId) {
    targetTask = backgroundTasks.get(taskId);
    if (targetTask) {
      targetPid = targetTask.pid;
    }
  } else if (pid) {
    targetPid = pid;
    // Find task by PID
    for (const task of backgroundTasks.values()) {
      if (task.pid === pid) {
        targetTask = task;
        break;
      }
    }
  }

  if (!targetPid) {
    return `❌ Task not found (taskId: ${taskId}, pid: ${pid})`;
  }

  try {
    // Kill main process
    process.kill(targetPid, "SIGTERM");

    // Also kill watchdog if exists
    if (targetTask?.watchdogPid && isProcessRunning(targetTask.watchdogPid)) {
      try {
        process.kill(targetTask.watchdogPid, "SIGKILL");
      } catch { /* ignore */ }
    }

    // FIX D: Give it 2 seconds, then SIGKILL - only if still running
    const pidToKill = targetPid;
    const killTimeout = setTimeout(() => {
      try {
        // Only kill if still running - avoids unnecessary kill attempt
        if (isProcessRunning(pidToKill)) {
          process.kill(pidToKill, "SIGKILL");
          log(`[TaskKill] SIGKILL sent to PID ${pidToKill} after timeout`);
        }
      } catch {
        // Already dead - this is fine
      }
    }, 2000);

    // FIX D: Unref the timeout so it doesn't keep the process alive
    // and allow garbage collection if MCP server shuts down
    if (killTimeout.unref) {
      killTimeout.unref();
    }

    if (targetTask) {
      targetTask.status = "failed";
      saveTasksToFile();
    }

    return `☠️ Agent terminated (PID: ${targetPid}, Agent: ${targetTask?.agentName || "unknown"})`;
  } catch (err) {
    if (targetTask) {
      targetTask.status = "failed";
      saveTasksToFile();
    }
    return `❌ Could not terminate process: ${err}`;
  }
}

/**
 * Get status of a specific task
 */
function getTaskStatus(taskId?: string, pid?: number): string {
  let targetTask: BackgroundTask | undefined;

  if (taskId) {
    targetTask = backgroundTasks.get(taskId);
  } else if (pid) {
    for (const task of backgroundTasks.values()) {
      if (task.pid === pid) {
        targetTask = task;
        break;
      }
    }
  }

  if (!targetTask) {
    return `❌ Task not found (taskId: ${taskId}, pid: ${pid})`;
  }

  const runtime = Math.round((Date.now() - targetTask.startTime) / 1000);
  const isRunning = isProcessRunning(targetTask.pid);

  // FIX B: Update status if process died but was marked as running
  if (!isRunning && targetTask.status === "running") {
    targetTask.status = "completed";
    saveTasksToFile();
  }

  // FIX B: Show ACTUAL status, not just running/completed based on PID
  let statusIcon: string;
  switch (targetTask.status) {
    case "running":
      statusIcon = isRunning ? "🟢 RUNNING" : "❓ UNKNOWN";
      break;
    case "completed":
      statusIcon = "✅ COMPLETED";
      break;
    case "failed":
      statusIcon = "❌ FAILED";
      break;
    case "timeout":
      statusIcon = "⏰ TIMEOUT";
      break;
    default:
      statusIcon = "❓ " + targetTask.status;
  }

  // Calculate timeout info
  let timeoutInfo = "";
  if (targetTask.timeoutAt && targetTask.status === "running") {
    const remaining = Math.round((targetTask.timeoutAt - Date.now()) / 1000);
    timeoutInfo = remaining > 0 ? `\nTimeout in: ${remaining}s` : "\nTimeout: OVERDUE!";
  }

  // Calculate actual runtime (use endTime if available)
  const actualRuntime = targetTask.endTime
    ? Math.round((targetTask.endTime - targetTask.startTime) / 1000)
    : runtime;

  // Exit code info
  let exitInfo = "";
  if (targetTask.exitCode !== undefined) {
    exitInfo = targetTask.exitCode === 0
      ? "\nExit: ✅ Success (code 0)"
      : targetTask.exitCode === null
        ? "\nExit: ⚠️ Killed by signal"
        : `\nExit: ❌ Failed (code ${targetTask.exitCode})`;
  }

  return `**Agent: ${targetTask.agentName}**
Status: ${statusIcon}
PID: ${targetTask.pid}
TaskID: ${targetTask.taskId}
Runtime: ${actualRuntime}s${targetTask.endTime ? " (finished)" : " (running)"}
WorkDir: ${targetTask.workingDir}${targetTask.logFile ? `\nLogFile: ${targetTask.logFile}` : ""}${exitInfo}${timeoutInfo}`;
}

/**
 * FIX C: Read log file of a background task
 * Memory-safe: For large files, only reads the last chunk needed.
 */
function readTaskLog(taskId: string, lines: number = 100): string {
  const task = backgroundTasks.get(taskId);

  if (!task) {
    return `❌ Task not found: ${taskId}`;
  }

  if (!task.logFile) {
    return `❌ No log file for task: ${taskId}`;
  }

  if (!existsSync(task.logFile)) {
    return `❌ Log file does not exist: ${task.logFile}`;
  }

  try {
    // Limit lines to max 1000
    const maxLines = Math.min(lines, 1000);
    const MAX_SAFE_SIZE = 1024 * 1024; // 1MB - read entire file only if smaller

    const stats = statSync(task.logFile);
    const fileSize = stats.size;

    let content: string;
    let isPartialRead = false;

    if (fileSize <= MAX_SAFE_SIZE) {
      // Small file - read entire content (current behavior)
      content = readFileSync(task.logFile, "utf-8");
    } else {
      // Large file - read only what we need from the end (sync version)
      // Estimate: 200 bytes per line average (generous for logs)
      const bytesToRead = Math.min(fileSize, maxLines * 200);
      const startPosition = Math.max(0, fileSize - bytesToRead);

      const fd = openSync(task.logFile, 'r');
      const buffer = Buffer.alloc(bytesToRead);
      const bytesRead = readSync(fd, buffer, 0, bytesToRead, startPosition);
      closeSync(fd);

      content = buffer.toString('utf-8', 0, bytesRead);
      // Skip potential partial first line if we didn't start at 0
      if (startPosition > 0) {
        const firstNewline = content.indexOf('\n');
        if (firstNewline > 0) {
          content = content.slice(firstNewline + 1);
        }
      }
      isPartialRead = true;
    }

    const allLines = content.split("\n");
    const lastLines = allLines.slice(-maxLines);

    let truncatedNote: string;
    if (isPartialRead) {
      // Large file - we only read the end
      const estimatedTotalLines = Math.round(fileSize / 100);
      truncatedNote = `\n(... ~${estimatedTotalLines} total lines estimated, file is ${Math.round(fileSize / 1024)}KB ...)\n\n`;
    } else if (allLines.length > maxLines) {
      // Small file but truncated
      truncatedNote = `\n(... ${allLines.length - maxLines} earlier lines omitted ...)\n\n`;
    } else {
      truncatedNote = "";
    }

    return `📝 **Log for ${task.agentName}** (${lastLines.length} lines shown):\n${truncatedNote}\`\`\`\n${lastLines.join("\n")}\n\`\`\``;
  } catch (err) {
    return `❌ Could not read log: ${err}`;
  }
}

interface ToolOutput {
  tool: string;
  output: string;
}

interface ProgressState {
  toolUseCount: number;
  currentToolUse: string | null;
  startTime: number;
  toolOutputs: ToolOutput[];
}

// Create MCP server
const server = new Server(
  {
    name: "paf-nested-subagent",
    version: "1.12.0",  // Mandatory Gideon bootstrap in paf-cto/paf-init skills
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Load persisted tasks on startup
loadTasksFromFile();

// Track active processes for abort handling
const activeProcesses = new Map<string, ChildProcess>();

// HARD LIMIT: Maximum concurrent agents to prevent system overload
// More than 4 concurrent agents causes Exit 143 (SIGTERM/timeout) and crashes
const MAX_CONCURRENT_AGENTS = 4;

// RACE CONDITION FIX: Track spawning agents SYNCHRONOUSLY before async spawn
// This counter is incremented IMMEDIATELY when spawn is requested,
// BEFORE the async process actually starts. This prevents parallel spawns
// from all seeing count=0 and bypassing the limit.
let pendingSpawns = 0;

/**
 * Count currently running agents (exclude finished ones)
 * Includes both registered background tasks AND pending spawns
 */
function countRunningAgents(): number {
  let running = 0;
  for (const [taskId, task] of backgroundTasks) {
    if (task.status === "running") {
      running++;
    }
  }
  // Add pending spawns that haven't been registered yet
  return running + pendingSpawns;
}

/**
 * Helper to format numbers with K/M suffixes
 */
function formatNumber(num: number): string {
  if (num >= 1000000) return (num / 1000000).toFixed(1) + 'M';
  if (num >= 1000) return (num / 1000).toFixed(1) + 'k';
  return num.toString();
}

/**
 * Helper to format duration
 */
function formatDuration(ms: number): string {
  if (ms < 1000) return `${ms}ms`;
  return `${(ms / 1000).toFixed(0)}s`;
}

/**
 * Spawns a nested task (fresh Claude process) with streaming output
 *
 * If runInBackground is true, returns immediately with taskId.
 * The agent will communicate via COMMS.md - the caller should poll COMMS.md for status.
 */
async function runTask(
  input: TaskInput,
  progressToken?: string | number,
): Promise<{ success: boolean; result?: string; error?: string; usage?: object; toolUseCount?: number; duration?: number; tokens?: number; toolOutputs?: ToolOutput[]; taskId?: string; backgroundMode?: boolean }> {
  const {
    prompt,
    model = "sonnet",
    workingDir = process.cwd(),
    timeout = 600000,
    allowWrite = false,
    permissionMode,
    systemPrompt,
    appendSystemPrompt,
    allowedTools,
    disallowedTools,
    maxBudgetUsd,
    addDirs,
    runInBackground = false,
    agentName = "unknown",
  } = input;

  // SECURITY: Validate workingDir to prevent path traversal attacks
  if (workingDir) {
    const path = await import('path');
    if (workingDir.includes('..') || !path.isAbsolute(workingDir)) {
      return {
        success: false,
        error: 'Invalid workingDir: must be absolute path without ".."',
      };
    }
  }

  // ╔═══════════════════════════════════════════════════════════════════════════╗
  // ║  HARD LIMIT CHECK: Prevent spawning more than MAX_CONCURRENT_AGENTS       ║
  // ║  This is a TECHNICAL ENFORCEMENT - cannot be bypassed by documentation    ║
  // ╚═══════════════════════════════════════════════════════════════════════════╝
  const currentlyRunning = countRunningAgents();
  if (currentlyRunning >= MAX_CONCURRENT_AGENTS) {
    const errorMsg = `🚨 CONCURRENT AGENT LIMIT REACHED! Currently ${currentlyRunning}/${MAX_CONCURRENT_AGENTS} agents running.

❌ Cannot spawn agent "${agentName}" - system would crash with Exit 143.

🔧 SOLUTION: Wait for existing agents to complete before spawning new ones.
   Check COMMS.md for agent status - look for "Status: COMPLETED".

📋 Currently running agents: Check "paf-status" or poll COMMS.md.

⏳ RETRY: Wait 30-60 seconds, then try again.`;

    log(`[LIMIT] Rejected spawn of "${agentName}": ${currentlyRunning}/${MAX_CONCURRENT_AGENTS} agents already running`);

    return {
      success: false,
      error: errorMsg,
    };
  }

  log(`[LIMIT] Spawning "${agentName}": ${currentlyRunning + 1}/${MAX_CONCURRENT_AGENTS} agents will be running`);

  // RACE CONDITION FIX: Increment pending count IMMEDIATELY (synchronously)
  // This ensures parallel spawns see the correct count
  pendingSpawns++;
  log(`[LIMIT] pendingSpawns incremented to ${pendingSpawns}`);

  const state: ProgressState = {
    toolUseCount: 0,
    currentToolUse: null,
    startTime: Date.now(),
    toolOutputs: [],
  };

  // Build CLI arguments - matching native Task tool capabilities
  const args: string[] = [
    "-p", prompt,
    "--output-format", "stream-json",
    "--verbose",
    "--model", model,
  ];

  // Permission handling
  if (allowWrite) {
    args.push("--dangerously-skip-permissions");
  } else if (permissionMode) {
    args.push("--permission-mode", permissionMode);
  }

  // System prompt
  if (systemPrompt) {
    args.push("--system-prompt", systemPrompt);
  }
  if (appendSystemPrompt) {
    args.push("--append-system-prompt", appendSystemPrompt);
  }

  // Tool restrictions
  if (allowedTools && allowedTools.length > 0) {
    args.push("--allowed-tools", ...allowedTools);
  }
  if (disallowedTools && disallowedTools.length > 0) {
    args.push("--disallowed-tools", ...disallowedTools);
  }

  // Budget
  if (maxBudgetUsd !== undefined) {
    args.push("--max-budget-usd", String(maxBudgetUsd));
  }

  // Additional directories
  if (addDirs && addDirs.length > 0) {
    args.push("--add-dir", ...addDirs);
  }

  // Don't persist session (isolation)
  args.push("--no-session-persistence");

  // CRITICAL: Pass plugin directory so spawned process has access to the same plugins
  // This enables true nested subagents - the spawned process can also use this MCP tool
  const pluginRoot = process.env.CLAUDE_PLUGIN_ROOT;
  if (pluginRoot) {
    args.push("--plugin-dir", pluginRoot);
  }

  // ============================================================
  // BACKGROUND MODE: Fire-and-Forget with Full Monitoring
  // Spawns agent and returns immediately. Agent communicates via COMMS.md.
  // CTO/caller should poll COMMS.md for status updates.
  //
  // FIXES IMPLEMENTED:
  // - Fix 2: Watchdog timeout process
  // - Fix 3: Error handling for spawn failures
  // - Fix 4: Logging to file instead of stdio:ignore
  // - Fix 5: Auto-inject COMMS.md prologue
  // ============================================================
  if (runInBackground) {
    // CRITICAL SECURITY FIX: Sanitize agentName to prevent bash injection
    // agentName is user input and will be used in shell commands and file paths
    const safeAgentName = sanitizeAgentName(agentName);
    const taskId = `${safeAgentName}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
    const logFile = `/tmp/paf-agent-${taskId}.log`;
    const timeoutMs = timeout || 1200000; // Default 20 minutes

    log(`[${taskId}] BACKGROUND MODE: Spawning ${safeAgentName}`);
    log(`[${taskId}] Working dir: ${workingDir}`);
    log(`[${taskId}] Timeout: ${timeoutMs}ms`);
    log(`[${taskId}] LogFile: ${logFile}`);

    // For background mode, we don't need streaming - just run the agent
    let bgArgs = args.filter(arg => arg !== "--output-format" && arg !== "stream-json");

    // FIX 5: Auto-inject COMMS.md prologue if not already present
    const hasCommsPrologue = appendSystemPrompt?.includes("COMMS.md") ||
                              systemPrompt?.includes("COMMS.md") ||
                              prompt.includes("COMMS.md");

    if (!hasCommsPrologue) {
      const commsPrologue = getCommsPrologue(safeAgentName);
      // Check if we already have append-system-prompt in args
      const appendIndex = bgArgs.indexOf("--append-system-prompt");
      if (appendIndex !== -1) {
        // Append to existing
        bgArgs[appendIndex + 1] = bgArgs[appendIndex + 1] + "\n\n" + commsPrologue;
      } else {
        bgArgs.push("--append-system-prompt", commsPrologue);
      }
      log(`[${taskId}] Injected COMMS.md prologue`);
    }

    log(`[${taskId}] Args: ${JSON.stringify(bgArgs.slice(0, 8))}...`);
    log(`[${taskId}] Full args count: ${bgArgs.length}`);

    // ========== EXTENSIVE DEBUG LOGGING v1.9.0 ==========
    log(`[${taskId}] DEBUG: Pre-spawn diagnostics starting...`);
    log(`[${taskId}] DEBUG: process.pid=${process.pid}, ppid=${process.ppid}`);
    log(`[${taskId}] DEBUG: PATH contains claude: ${process.env.PATH?.includes('claude') || 'checking...'}`);

    // FIX 4: Open log file for stdout/stderr capture
    let stdoutFd: number;
    let stderrFd: number;
    log(`[${taskId}] DEBUG: Opening log file: ${logFile}`);
    try {
      stdoutFd = openSync(logFile, "w");
      log(`[${taskId}] DEBUG: stdoutFd opened: ${stdoutFd}`);
      stderrFd = openSync(logFile, "a");
      log(`[${taskId}] DEBUG: stderrFd opened: ${stderrFd}`);
    } catch (err) {
      log(`[${taskId}] DEBUG: FAILED to open log file: ${err}`);
      // RACE CONDITION FIX: Decrement on early return
      pendingSpawns--;
      log(`[LIMIT] pendingSpawns decremented to ${pendingSpawns} (log file error)`);
      return Promise.resolve({
        success: false,
        error: `Failed to create log file ${logFile}: ${err}`,
      });
    }

    // Pre-spawn: Verify FDs are valid
    try {
      const fdStat = statSync(logFile);
      log(`[${taskId}] DEBUG: Log file stat - size: ${fdStat.size}, mode: ${fdStat.mode.toString(8)}`);
    } catch (err) {
      log(`[${taskId}] DEBUG: Could not stat log file: ${err}`);
    }

    log(`[${taskId}] DEBUG: About to spawn claude process...`);
    log(`[${taskId}] DEBUG: spawn("claude", [${bgArgs.length} args], {cwd: "${workingDir}", detached: true, stdio: ["ignore", ${stdoutFd}, ${stderrFd}]})`);
    const spawnStartTime = Date.now();

    // Spawn with detached: true so process survives parent exit
    const proc = spawn("claude", bgArgs, {
      cwd: workingDir,
      env: process.env,
      stdio: ["ignore", stdoutFd, stderrFd],  // FIX 4: Log to file
      detached: true,
    });

    const spawnDuration = Date.now() - spawnStartTime;
    log(`[${taskId}] DEBUG: spawn() returned in ${spawnDuration}ms`);
    log(`[${taskId}] DEBUG: proc.pid=${proc.pid}, proc.killed=${proc.killed}, proc.exitCode=${proc.exitCode}`);
    log(`[${taskId}] DEBUG: proc.spawnfile=${proc.spawnfile || 'N/A'}`);
    log(`[${taskId}] DEBUG: proc.connected=${proc.connected}`);

    // FIX 3: Check for spawn errors
    let spawnError: Error | undefined = undefined;
    proc.on("error", (err) => {
      spawnError = err;
      log(`[${taskId}] DEBUG: ERROR EVENT received: ${err.message}`);
      log(`[${taskId}] DEBUG: Error stack: ${err.stack}`);
    });

    // Additional debug events
    proc.on("spawn", () => {
      log(`[${taskId}] DEBUG: SPAWN EVENT received - process successfully started`);
    });

    proc.on("disconnect", () => {
      log(`[${taskId}] DEBUG: DISCONNECT EVENT received`);
    });

    proc.on("close", (code, signal) => {
      log(`[${taskId}] DEBUG: CLOSE EVENT - code=${code}, signal=${signal}`);
    });

    // Give it a moment to check for immediate spawn failures
    log(`[${taskId}] DEBUG: Waiting 100ms for immediate spawn errors...`);
    await new Promise(resolve => setTimeout(resolve, 100));
    log(`[${taskId}] DEBUG: 100ms wait complete`);

    // Post-wait diagnostics
    log(`[${taskId}] DEBUG: After 100ms - proc.killed=${proc.killed}, proc.exitCode=${proc.exitCode}`);

    // Check log file size after spawn
    try {
      const postSpawnStat = statSync(logFile);
      log(`[${taskId}] DEBUG: Log file size after spawn: ${postSpawnStat.size} bytes`);
    } catch (err) {
      log(`[${taskId}] DEBUG: Could not stat log file after spawn: ${err}`);
    }

    if (spawnError !== undefined) {
      const errorMsg = (spawnError as Error).message;
      log(`[${taskId}] DEBUG: Spawn failed with error: ${errorMsg}`);
      // RACE CONDITION FIX: Decrement on spawn error
      pendingSpawns--;
      log(`[LIMIT] pendingSpawns decremented to ${pendingSpawns} (spawn error)`);
      return Promise.resolve({
        success: false,
        error: `Failed to spawn agent "${safeAgentName}": ${errorMsg}`,
      });
    }

    const pid = proc.pid;
    if (!pid) {
      // RACE CONDITION FIX: Decrement on no PID
      pendingSpawns--;
      log(`[LIMIT] pendingSpawns decremented to ${pendingSpawns} (no PID)`);
      return Promise.resolve({
        success: false,
        error: `Failed to spawn agent "${safeAgentName}": No PID returned`,
      });
    }

    // FIX 3: Verify process is actually running
    if (!isProcessRunning(pid)) {
      // RACE CONDITION FIX: Decrement on process not running
      pendingSpawns--;
      log(`[LIMIT] pendingSpawns decremented to ${pendingSpawns} (process not running)`);
      return Promise.resolve({
        success: false,
        error: `Agent "${safeAgentName}" failed to start (PID ${pid} not running). Check ${logFile} for errors.`,
      });
    }

    // EXIT CODE TRACKING: Listen for process exit BEFORE unref()
    // This allows us to track success/failure even for detached processes
    const capturedTaskId = taskId;
    const capturedWatchdogPid = { value: 0 }; // Will be set after watchdog spawn
    proc.on("exit", (code: number | null, signal: NodeJS.Signals | null) => {
      const task = backgroundTasks.get(capturedTaskId);
      if (task) {
        task.exitCode = code;
        task.endTime = Date.now();

        // Determine status based on exit code (don't override timeout status)
        if (task.status === "running") {
          if (code === 0) {
            task.status = "completed";
            log(`[${capturedTaskId}] Agent completed successfully (exit code 0)`);
          } else if (code !== null) {
            task.status = "failed";
            log(`[${capturedTaskId}] Agent failed with exit code ${code}`);
          } else if (signal) {
            // Killed by signal - mark as failed
            task.status = "failed";
            log(`[${capturedTaskId}] Agent killed by signal ${signal}`);
          }
        } else {
          // Status was already set (e.g., to "timeout") - just log
          log(`[${capturedTaskId}] Agent exited (code: ${code}, signal: ${signal}, status was: ${task.status})`);
        }

        // Kill watchdog since process is done
        if (capturedWatchdogPid.value && isProcessRunning(capturedWatchdogPid.value)) {
          try {
            process.kill(capturedWatchdogPid.value, "SIGKILL");
            log(`[${capturedTaskId}] Watchdog killed (no longer needed)`);
          } catch { /* ignore */ }
        }

        saveTasksToFile();
      }
    });

    // Unref allows parent to exit independently
    log(`[${taskId}] DEBUG: About to call proc.unref()...`);
    proc.unref();
    log(`[${taskId}] DEBUG: proc.unref() called successfully`);

    // FIX A: Close FDs in parent - child has its own copies
    // Without this, we leak 2 FDs per background spawn!
    log(`[${taskId}] DEBUG: Closing FDs in parent (stdoutFd=${stdoutFd}, stderrFd=${stderrFd})...`);
    try {
      closeSync(stdoutFd);
      log(`[${taskId}] DEBUG: stdoutFd closed`);
      closeSync(stderrFd);
      log(`[${taskId}] DEBUG: stderrFd closed`);
    } catch (err) {
      log(`[${taskId}] DEBUG: FD close error (ignored): ${err}`);
    }

    // Post-close: Check log file again
    try {
      const postCloseStat = statSync(logFile);
      log(`[${taskId}] DEBUG: Log file size after FD close: ${postCloseStat.size} bytes`);
    } catch (err) {
      log(`[${taskId}] DEBUG: Could not stat log file after FD close: ${err}`);
    }

    log(`[${taskId}] DEBUG: Background process started with PID: ${pid}`);

    // FIX 2: Start watchdog timeout process with HEARTBEAT MONITORING
    const timeoutSec = Math.ceil(timeoutMs / 1000);
    const debugLogFile = LOG_FILE; // Reference to main debug log
    const watchdog = spawn("bash", ["-c", `
      # Heartbeat monitoring - log status every 30s for first 5 minutes
      HEARTBEAT_COUNT=0
      HEARTBEAT_MAX=10
      while [ $HEARTBEAT_COUNT -lt $HEARTBEAT_MAX ]; do
        sleep 30
        HEARTBEAT_COUNT=$((HEARTBEAT_COUNT + 1))
        if kill -0 ${pid} 2>/dev/null; then
          # Portable log size check (works on both macOS and Linux)
          LOG_SIZE=$(wc -c < "${logFile}" 2>/dev/null | tr -d ' ' || echo "?")
          TCP_CONNS=$(lsof -p ${pid} 2>/dev/null | grep -c "TCP.*ESTABLISHED" || echo "0")
          echo "[$(date -Iseconds)] [${taskId}] HEARTBEAT #$HEARTBEAT_COUNT: PID ${pid} alive, log=$LOG_SIZE bytes, tcp=$TCP_CONNS" >> "${debugLogFile}"
        else
          echo "[$(date -Iseconds)] [${taskId}] HEARTBEAT #$HEARTBEAT_COUNT: PID ${pid} NOT RUNNING" >> "${debugLogFile}"
          exit 0
        fi
      done

      # Now wait for remaining timeout
      REMAINING=$((${timeoutSec} - 300))
      if [ $REMAINING -gt 0 ]; then
        sleep $REMAINING
      fi

      if kill -0 ${pid} 2>/dev/null; then
        echo "[$(date -Iseconds)] [${taskId}] WATCHDOG: Timeout reached, killing PID ${pid}" >> "${debugLogFile}"
        echo "[WATCHDOG] Timeout reached, killing PID ${pid}" >> "${logFile}"
        kill -TERM ${pid} 2>/dev/null
        sleep 5
        if kill -0 ${pid} 2>/dev/null; then
          echo "[$(date -Iseconds)] [${taskId}] WATCHDOG: SIGTERM failed, using SIGKILL" >> "${debugLogFile}"
          kill -KILL ${pid} 2>/dev/null
        fi
      fi
    `], {
      detached: true,
      stdio: "ignore",
    });
    watchdog.unref();
    const watchdogPid = watchdog.pid || 0;
    capturedWatchdogPid.value = watchdogPid; // Set for exit handler
    log(`[${taskId}] Watchdog started with PID: ${watchdogPid} (timeout: ${timeoutSec}s)`);

    // Track the background task with all metadata
    const taskInfo: BackgroundTask = {
      taskId,
      agentName: safeAgentName,  // Store sanitized name
      pid,
      startTime: Date.now(),
      workingDir,
      status: "running",
      watchdogPid,
      timeoutAt: Date.now() + timeoutMs,
      logFile,
    };
    backgroundTasks.set(taskId, taskInfo);

    // RACE CONDITION FIX: Decrement pending count now that task is registered
    pendingSpawns--;
    log(`[LIMIT] pendingSpawns decremented to ${pendingSpawns} (task registered: ${taskId})`);

    // FIX 1: Persist to file
    saveTasksToFile();

    // Return IMMEDIATELY - don't wait for completion
    return Promise.resolve({
      success: true,
      backgroundMode: true,
      taskId,
      result: `✅ Agent "${safeAgentName}" started in background (PID: ${pid}, TaskID: ${taskId}).\n\n` +
        `📋 The agent will write its status to .paf/COMMS.md.\n` +
        `🔄 Poll COMMS.md regularly to see progress.\n` +
        `⏰ Timeout: ${Math.round(timeoutMs / 1000 / 60)} minutes\n` +
        `📝 LogFile: ${logFile}\n\n` +
        `Look for: <!-- AGENT:${safeAgentName.toUpperCase()}:START -->`,
    });
  }

  // ============================================================
  // SYNCHRONOUS MODE: Wait for completion (original behavior)
  // ============================================================
  return new Promise((resolve) => {
    let lastResult: StreamMessage | null = null;
    let timedOut = false;
    const processId = `${Date.now()}-${Math.random().toString(36).slice(2)}`;

    log(`[${processId}] CLAUDE_PLUGIN_ROOT=${process.env.CLAUDE_PLUGIN_ROOT || '(not set)'}`);
    log(`[${processId}] Spawning claude with args: ${JSON.stringify(args)}`);
    log(`[${processId}] Working dir: ${workingDir}`);

    // Spawn Claude CLI
    const proc = spawn("claude", args, {
      cwd: workingDir,
      env: process.env,
      stdio: ["pipe", "pipe", "pipe"],
    });

    log(`[${processId}] Process spawned with PID: ${proc.pid}`);

    // Close stdin immediately - Claude with -p doesn't need it
    proc.stdin?.end();
    log(`[${processId}] stdin closed`);

    // Track for abort
    activeProcesses.set(processId, proc);

    // Timeout handling
    const timeoutId = setTimeout(() => {
      timedOut = true;
      proc.kill("SIGTERM");
      const killTimeout = setTimeout(() => {
        if (!proc.killed) {
          proc.kill("SIGKILL");
        }
      }, 5000);
      killTimeout.unref(); // Don't prevent process exit
    }, timeout);

    // Parse streaming JSON output line by line
    const rl = createInterface({ input: proc.stdout! });

    rl.on("line", (line) => {
      log(`[${processId}] STDOUT line: ${line.slice(0, 200)}${line.length > 200 ? '...' : ''}`);
      if (!line.trim()) return;

      try {
        const msg: StreamMessage = JSON.parse(line);

        // Handle different message types
        switch (msg.type) {
          case "system":
            // Session initialized - could emit init progress
            if (progressToken !== undefined) {
              server.notification({
                method: "notifications/progress",
                params: {
                  progressToken,
                  progress: 0,
                  message: `Session initialized (${msg.session_id?.slice(0, 8)}...)`,
                },
              });
            }
            break;

          case "assistant":
            // Check for tool uses
            if (msg.message?.content) {
              for (const block of msg.message.content) {
                if (block.type === "tool_use" && block.name) {
                  state.toolUseCount++;
                  state.currentToolUse = block.name;

                  if (progressToken !== undefined) {
                    server.notification({
                      method: "notifications/progress",
                      params: {
                        progressToken,
                        progress: state.toolUseCount,
                        message: `Tool: ${block.name}${block.input ? ` (${JSON.stringify(block.input).slice(0, 50)}...)` : ""}`,
                      },
                    });
                  }
                } else if (block.type === "text" && block.text) {
                  // Text response
                  if (progressToken !== undefined) {
                    server.notification({
                      method: "notifications/progress",
                      params: {
                        progressToken,
                        progress: state.toolUseCount,
                        message: `Response: ${block.text.slice(0, 100)}${block.text.length > 100 ? "..." : ""}`,
                      },
                    });
                  }
                }
              }
            }
            break;

          case "user":
            // Tool result - capture output and emit progress
            if (msg.tool_use_result) {
              const stdout = msg.tool_use_result.stdout || "";
              // Capture tool output for final result
              if (stdout && state.currentToolUse) {
                state.toolOutputs.push({
                  tool: state.currentToolUse,
                  output: stdout,
                });
              }
              if (progressToken !== undefined) {
                const resultPreview = stdout.slice(0, 50) || "(no output)";
                server.notification({
                  method: "notifications/progress",
                  params: {
                    progressToken,
                    progress: state.toolUseCount,
                    message: `Result: ${resultPreview}${stdout.length > 50 ? "..." : ""}`,
                  },
                });
              }
            }
            break;

          case "result":
            // Final result
            lastResult = msg;
            break;
        }
      } catch {
        // Ignore JSON parse errors (might be partial lines)
      }
    });

    // Collect stderr for errors
    let stderr = "";
    proc.stderr?.on("data", (data: Buffer) => {
      const chunk = data.toString();
      stderr += chunk;
      log(`[${processId}] STDERR: ${chunk}`);
    });

    // Handle process completion
    proc.on("close", (code: number | null) => {
      log(`[${processId}] Process closed with code: ${code}`);
      clearTimeout(timeoutId);
      activeProcesses.delete(processId);

      // RACE CONDITION FIX: Decrement pending count for synchronous tasks
      pendingSpawns--;
      log(`[LIMIT] pendingSpawns decremented to ${pendingSpawns} (sync task closed)`);

      const duration = Date.now() - state.startTime;
      log(`[${processId}] Duration: ${duration}ms, timedOut: ${timedOut}, hasResult: ${!!lastResult}`);

      if (timedOut) {
        log(`[${processId}] Resolving with timeout error`);
        resolve({
          success: false,
          error: `Task timed out after ${timeout}ms`,
        });
        return;
      }

      if (lastResult) {
        // Calculate total tokens
        const totalTokens = lastResult.usage
          ? (lastResult.usage.cache_creation_input_tokens ?? 0) +
          (lastResult.usage.cache_read_input_tokens ?? 0) +
          lastResult.usage.input_tokens +
          lastResult.usage.output_tokens
          : 0;

        // Emit final progress
        if (progressToken !== undefined) {
          server.notification({
            method: "notifications/progress",
            params: {
              progressToken,
              progress: state.toolUseCount,
              total: state.toolUseCount,
              message: `Done (${state.toolUseCount} tool uses, ${duration}ms, $${lastResult.total_cost_usd?.toFixed(4) ?? "?"})`,
            },
          });
        }

        resolve({
          success: !lastResult.is_error,
          result: lastResult.result,
          usage: lastResult.usage,
          toolUseCount: state.toolUseCount,
          duration,
          tokens: totalTokens,
          toolOutputs: state.toolOutputs,
        });
      } else if (code === 0) {
        resolve({
          success: true,
          result: "(completed with no output)",
          toolUseCount: state.toolUseCount,
          duration,
          tokens: 0,
          toolOutputs: state.toolOutputs,
        });
      } else {
        resolve({
          success: false,
          error: stderr.trim() || `Process exited with code ${code}`,
        });
      }
    });

    proc.on("error", (err: Error) => {
      clearTimeout(timeoutId);
      activeProcesses.delete(processId);
      // RACE CONDITION FIX: Decrement on error
      pendingSpawns--;
      log(`[LIMIT] pendingSpawns decremented to ${pendingSpawns} (sync spawn error)`);
      resolve({
        success: false,
        error: `Failed to spawn: ${err.message}`,
      });
    });
  });
}

// Handle tool listing - expose all management tools
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [NESTED_TASK_TOOL, TASK_LIST_TOOL, TASK_KILL_TOOL, TASK_STATUS_TOOL, TASK_LOG_TOOL],
}));

// Handle tool execution
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const toolName = request.params.name;
  log(`Tool called: ${toolName}`);

  // ============================================================
  // MANAGEMENT TOOLS (for CTO to monitor/control agents)
  // ============================================================

  if (toolName === "TaskList") {
    const result = listBackgroundTasks();
    return {
      content: [{ type: "text", text: result }],
    };
  }

  if (toolName === "TaskKill") {
    const args = request.params.arguments as { taskId?: string; pid?: number };
    const result = killBackgroundTask(args.taskId, args.pid);
    return {
      content: [{ type: "text", text: result }],
    };
  }

  if (toolName === "TaskStatus") {
    const args = request.params.arguments as { taskId?: string; pid?: number };
    const result = getTaskStatus(args.taskId, args.pid);
    return {
      content: [{ type: "text", text: result }],
    };
  }

  // FIX C: TaskLog handler
  if (toolName === "TaskLog") {
    const args = request.params.arguments as { taskId: string; lines?: number };
    const result = readTaskLog(args.taskId, args.lines);
    return {
      content: [{ type: "text", text: result }],
    };
  }

  // ============================================================
  // MAIN TASK TOOL (spawn agents)
  // ============================================================

  if (toolName !== "Task") {
    return {
      content: [{ type: "text", text: `Unknown tool: ${toolName}` }],
      isError: true,
    };
  }

  const input = request.params.arguments as unknown as TaskInput;
  const progressToken = request.params._meta?.progressToken;

  log(`Prompt: ${input.prompt?.slice(0, 100)}...`);
  log(`Model: ${input.model}, timeout: ${input.timeout}, allowWrite: ${input.allowWrite}, runInBackground: ${input.runInBackground}`);

  if (!input.prompt) {
    return {
      content: [{ type: "text", text: "Error: prompt is required" }],
      isError: true,
    };
  }

  const result = await runTask(input, progressToken);
  log(`Result: success=${result.success}, backgroundMode=${result.backgroundMode}, error=${result.error}`);

  // Background mode - return immediately with task info
  if (result.backgroundMode) {
    return {
      content: [{ type: "text", text: result.result || "Agent started in background" }],
    };
  }

  // Synchronous mode - return full result
  if (result.success) {
    // Format output to match native Task tool: "Done (X tool uses · Yk tokens · Zs)"
    const toolUseText = result.toolUseCount === 1 ? '1 tool use' : `${result.toolUseCount ?? 0} tool uses`;
    const tokensText = formatNumber(result.tokens ?? 0) + ' tokens';
    const durationText = formatDuration(result.duration ?? 0);
    const summary = `Done (${toolUseText} · ${tokensText} · ${durationText})`;

    // Format tool outputs for display (similar to native Task tool)
    let toolOutputsText = '';
    if (result.toolOutputs && result.toolOutputs.length > 0) {
      toolOutputsText = result.toolOutputs
        .map(to => `[${to.tool}]\n${to.output}`)
        .join('\n\n');
    }

    // Build final output: tool outputs + result + summary
    const parts: string[] = [];
    if (toolOutputsText) parts.push(toolOutputsText);
    if (result.result) parts.push(result.result);
    parts.push(summary);

    return {
      content: [
        {
          type: "text",
          text: parts.join('\n\n'),
        },
      ],
    };
  } else {
    return {
      content: [
        {
          type: "text",
          text: `Error: ${result.error}`,
        },
      ],
      isError: true,
    };
  }
});

// Graceful shutdown helper
function shutdownTasks(signal: string): void {
  log(`Received ${signal}, shutting down...`);

  // Clear cleanup interval
  clearInterval(cleanupIntervalId);

  // Mark all running tasks as failed due to server shutdown
  for (const [taskId, task] of backgroundTasks) {
    if (task.status === "running") {
      task.status = "failed";
      task.endTime = Date.now();
      log(`Task ${taskId} marked as failed due to ${signal}`);
    }
  }
  saveTasksToFile();

  // Kill all active processes
  for (const [id, proc] of activeProcesses) {
    proc.kill(signal === "SIGINT" ? "SIGINT" : "SIGTERM");
  }
}

// Graceful shutdown - abort all active processes
process.on("SIGTERM", () => {
  shutdownTasks("SIGTERM");
  const exitTimeout = setTimeout(() => {
    for (const [id, proc] of activeProcesses) {
      if (!proc.killed) proc.kill("SIGKILL");
    }
    process.exit(0);
  }, 5000);
  exitTimeout.unref();
});

process.on("SIGINT", () => {
  shutdownTasks("SIGINT");
  process.exit(0);
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("PAF Nested Subagent MCP Server v1.12.0 running on stdio");
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
