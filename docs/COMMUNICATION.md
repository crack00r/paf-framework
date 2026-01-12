# PAF Inter-Agent Communication Protocol

> Complete documentation for agent-to-agent communication, hierarchy, and spawning.

---

## 🏗️ Agent Hierarchy

### Spawning Permissions

```
                    ┌─────────────┐
                    │     CTO     │ ← Can spawn ALL agents
                    └──────┬──────┘
                           │
       ┌───────────────────┼───────────────────┐
       ▼                   ▼                   ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Phase Leads │    │ Perspectives│    │   George    │
│ (Sophia,    │    │ (10 Agents) │    │ (Aggregator)│
│  Rachel)    │    │             │    │             │
└──────┬──────┘    └─────────────┘    └─────────────┘
       │
       ▼
┌─────────────┐
│ Team Members│
│ (Phase-     │
│  specific)  │
└─────────────┘
```

### Who Can Spawn Whom?

| Agent | Can Spawn | Is Spawned By |
|-------|-----------|---------------|
| **CTO** | All 37 other agents | - (Entry Point) |
| **Sophia** (Architect) | Michael, Kai | CTO |
| **Rachel** (Review Lead) | Stan, Scanner, Perf | CTO |
| **Sarah** (Implementation Lead) | NONE (coordinates only) | CTO |
| **Chris, Dan, Anna, Tina** | NONE | CTO (directly!) |
| **Tony** (Deployment Lead) | Rel, Miggy | CTO |
| **Inci** (Operations Lead) | Monitor, Feedback | CTO |
| **George** (Aggregator) | None | CTO |
| **Perspective Agents** | None (review only) | CTO |
| **SDLC Team Members** | None | CTO, Phase Lead |

**NOTE:** Implementation Team is spawned DIRECTLY by CTO (flat structure).

### Hierarchy Rules

1. **CTO is the only Entry Point** - User always talks to CTO first
2. **Phase Leads can spawn their team** - e.g., Rachel → Stan, Scanner, Perf
3. **Perspective Agents don't spawn** - They only review
4. **George is spawned last** - He aggregates all findings

---

## 📡 Communication Channels

### 1. COMMS.md (Primary)

**Central communication hub** - Each agent has their section.

```markdown
## [Agent Name] [Emoji] ([Role])
<!-- AGENT:[NAME]:START -->
### Status: [STATUS]
### Timestamp: [ISO-TIMESTAMP]

**Task:** [What the agent is doing]

**Findings:**
[Results]

**Handoff:** @[NEXT_AGENT] or @ORCHESTRATOR
<!-- AGENT:[NAME]:END -->
```

### 2. Status Values

| Status | Meaning | Next Action |
|--------|---------|-------------|
| `IDLE` | Waiting for activation | - |
| `IN_PROGRESS` | Actively working | Wait |
| `BLOCKED` | Needs input | CTO/Lead resolves blocker |
| `COMPLETED` | Done | Check handoff |
| `ERROR` | Error occurred | CTO investigates |

### 3. Handoff Protocol

```markdown
**Handoff:** @GEORGE  // Handoff to George
**Handoff:** @ORCHESTRATOR  // Back to CTO
**Handoff:** @RACHEL  // To Review Lead
**Handoff:** NONE  // No further action needed
```

---

## 🔄 Spawning Protocol

### For CTO: Spawning an Agent

```javascript
mcp__plugin_nested_subagent__Task({
  description: "[Agent] - [Task Description]",
  prompt: `You are [Agent], [Role] in the PAF Team.

Your motto: "[Motto]"

## Your Task
[TASK_DESCRIPTION]

## Workflow
1. Read .paf/COMMS.md for context
2. Perform your analysis
3. Document findings in structured format
4. Write to COMMS.md under AGENT:[NAME]

## Output Format
[EXPECTED_FORMAT]

## Status
Set Status to IN_PROGRESS at start.
Set Status to COMPLETED when done.
End with: Handoff: @ORCHESTRATOR`,

  model: "sonnet",  // or "opus" for complex tasks
  allowWrite: true,
  timeout: 600000   // 10 minutes
})
```

### For Phase Leads: Spawning a Sub-Agent

```javascript
// Rachel spawns Stan
mcp__plugin_nested_subagent__Task({
  description: "Stan - Standards Check",
  prompt: `You are Stan, Standards Checker, spawned by Rachel.

## Your Task
[TASK]

## Reporting
Write to COMMS.md under AGENT:STAN.
Handoff: @RACHEL`,

  model: "sonnet",
  allowWrite: true,
  timeout: 180000
})
```

---

## 📝 COMMS.md Writing Rules

### 1. Find Your Section

Each agent has a dedicated section:
```markdown
<!-- AGENT:ALEX:START -->
[Content here]
<!-- AGENT:ALEX:END -->
```

### 2. Always Start with Status

```markdown
### Status: IN_PROGRESS
### Timestamp: 2026-01-09T15:30:00Z
```

### 3. Use Structured Format

```markdown
**Task:** [What you're doing]

**Findings:**
- ✅ OK: [What's good]
- ⚠️ Warning: [Improvements]
- ❌ Critical: [Must be fixed]

**Risk Level:** [LOW | MEDIUM | HIGH | CRITICAL]

**Recommendations:**
1. [Recommendation 1]
2. [Recommendation 2]

**Handoff:** @ORCHESTRATOR
```

### 4. Update Status at End

```markdown
### Status: COMPLETED
```

---

## 🔁 Workflow Examples

### Quick Review Flow

```
1. User → CTO: "Quick security check"

2. CTO detects signals:
   - Build: quick
   - Focus: security

3. CTO spawns in parallel:
   - Alex 🔒 (Security)
   - Max 🔧 (Maintainability)
   - Nina 🎯 (Triage)
   - Emma ⚡ (Performance)

4. Agents write to COMMS.md:
   <!-- AGENT:ALEX:START -->
   ### Status: COMPLETED
   **Findings:** [...]
   **Handoff:** @ORCHESTRATOR
   <!-- AGENT:ALEX:END -->

5. CTO waits until all COMPLETED

6. CTO aggregates itself (quick build)

7. CTO presents result
```

### Standard Review Flow

```
1. User → CTO: "Review this feature"

2. CTO spawns Perspective Agents SERIALIZED (max 3-4 ACTIVE AT ONCE!):
   - Start alex, emma, sam, david (4 active)
   - STOP! Wait until at least 1 COMPLETED
   - alex done → Start max (4 active)
   - emma done → Start luna (4 active)
   - ... etc until all 10 done

   NEVER more than 4 agents IN_PROGRESS at once!

3. All write to their COMMS.md section

4. CTO waits for all COMPLETED

5. CTO spawns George for aggregation

6. George reads all sections

7. George writes Aggregation Report

8. CTO presents George's Report
```

### Comprehensive Flow with Hierarchy

```
1. User → CTO: "Full audit before release"

2. CTO spawns Discovery Team:
   - Ben, Maya, Iris

3. After Discovery COMPLETED:
   CTO spawns Planning Team:
   - Sophia (spawns Michael, Kai)

4. After Planning COMPLETED:
   CTO spawns Perspectives SERIALIZED (max 3-4 ACTIVE AT ONCE!)

5. After Perspectives COMPLETED:
   CTO spawns Review Team:
   - Rachel (spawns Stan, Scanner, Perf)

6. After Review COMPLETED:
   CTO spawns George for aggregation

7. George creates Enterprise Report

8. CTO presents with Risk Matrix
```

---

## 🚨 Blocker Handling

### Agent Reports Blocker

```markdown
### Status: BLOCKED
### Timestamp: [NOW]

**Blocker:** Need architecture info from Sophia

**Waiting for:** @SOPHIA

**Can continue after:** Architecture decision on caching strategy
```

### CTO Resolves Blocker

1. CTO reads BLOCKED status
2. CTO identifies missing info
3. CTO spawns needed agent or retrieves info
4. CTO updates context for blocked agent
5. Blocked agent continues

---

## 📊 Parallel vs. Sequential

### Parallel (independent tasks)

Perspective Agents are independent - don't need input from each other.
**BUT:** Max 3-4 agents ACTIVE AT ONCE (not per batch - TOTAL)!

```javascript
// CTO spawns SERIALIZED with limit check
let active = 0;
const MAX = 4;

for (const agent of [alex, emma, sam, david, max, luna, ...]) {
  // WAIT if already MAX active
  while (active >= MAX) {
    await sleep(30000);
    active = countAgentsWithStatus("IN_PROGRESS");
  }
  // Now active < MAX - spawn next
  await spawnAgent(agent);
  active++;
}
```

### Sequential (dependent tasks)

Discovery → Planning → Implementation → Review

```javascript
// Wait for Discovery
await spawnTeam("discovery");

// Then Planning (needs Discovery output)
await spawnTeam("planning");

// etc.
```

---

## ✅ Best Practices

1. **Always update status** - IN_PROGRESS → COMPLETED
2. **Use structured format** - Consistency helps with aggregation
3. **Clearly specify handoff** - Who should be next?
4. **Report blockers immediately** - Don't get stuck
5. **Use timestamps** - For traceability
6. **Keep it short and concise** - George must be able to aggregate

---

## 🔧 Troubleshooting

### Agent doesn't write to COMMS.md

- Check: `allowWrite: true` in spawn call?
- Check: Correct section specified?

### Agent can't find their section

- COMMS.md must exist with `<!-- AGENT:NAME:START/END -->` markers
- Check case sensitivity

### Handoff doesn't work

- Handoff is just a signal - CTO must read it and act
- CTO monitors COMMS.md and spawns next agent

### George aggregates incorrectly

- All agents must be COMPLETED
- Format must be consistent (Findings, Risk Level, etc.)
