# PAF Agent Prologue

> **MANDATORY PROTOCOL** - Every spawned agent MUST follow this before doing ANY work!

---

## CRITICAL REQUIREMENTS

### 1. COMMS.md Update is MANDATORY

**BEFORE you start any analysis or work:**

```markdown
1. Read: .paf/COMMS.md
2. Find your section: <!-- AGENT:[YOUR_NAME]:START -->
3. Update status to IN_PROGRESS immediately
4. Write timestamp
```

**Example (do this FIRST):**

```markdown
<!-- AGENT:ALEX:START -->
### Status: IN_PROGRESS
### Timestamp: 2026-01-11T12:00:00Z

**Task:** [Your assigned task]
**Started:** [NOW]

<!-- Working... -->
<!-- AGENT:ALEX:END -->
```

### 2. Progress Updates Every 2 Minutes

**During your work, update COMMS.md every 2 minutes:**

```markdown
<!-- AGENT:ALEX:START -->
### Status: IN_PROGRESS
### Timestamp: 2026-01-11T12:02:00Z

**Task:** Security Review
**Progress:** 40% complete
**Current:** Analyzing authentication module
**Findings so far:** 2 issues identified
<!-- AGENT:ALEX:END -->
```

### 3. Completion is MANDATORY

**When finished, you MUST update COMMS.md:**

```markdown
<!-- AGENT:ALEX:START -->
### Status: COMPLETED
### Timestamp: 2026-01-11T12:10:00Z

**Task:** Security Review

**Findings:**
- OK: [what's good]
- Warning: [improvements]
- Critical: [must fix]

**Recommendations:**
1. [Recommendation]

**Handoff:** @ORCHESTRATOR
<!-- AGENT:ALEX:END -->
```

---

## FAILURE MODES

### If you cannot complete:

```markdown
### Status: BLOCKED
### Timestamp: [NOW]

**Blocker:** [What's preventing completion]
**Attempted:** [What you tried]
**Need:** [What you need to continue]

**Handoff:** @ORCHESTRATOR
```

### If you encounter an error:

```markdown
### Status: ERROR
### Timestamp: [NOW]

**Error:** [Error description]
**Context:** [What you were doing]

**Handoff:** @ORCHESTRATOR
```

---

## COMMUNICATION PATH

**All agents use PROJECT-LOCAL COMMS.md:**

```
.paf/COMMS.md   <-- Use THIS (project directory)
```

**NOT the global path (~/.paf/COMMS.md)**

---

## STATUS VALUES

| Status | Meaning | When to use |
|--------|---------|-------------|
| `IDLE` | Waiting | Initial state (set by template) |
| `IN_PROGRESS` | Working | IMMEDIATELY when starting |
| `BLOCKED` | Stuck | When you need input |
| `COMPLETED` | Done | When task finished |
| `ERROR` | Failed | When something breaks |
| `TIMEOUT` | Timed out | Set by CTO if no response |

---

## TIMING REQUIREMENTS

| Action | Timing |
|--------|--------|
| First COMMS.md update | Within 30 seconds of starting |
| Progress updates | Every 2 minutes |
| Final update | Before returning |

---

## ENFORCEMENT

The CTO monitors COMMS.md and will:

1. **Mark as TIMEOUT** - If no update for 5 minutes
2. **Mark as FAILED** - If no completion after timeout
3. **Retry or skip** - Based on agent importance

---

## CHECKLIST (Do This NOW)

- [ ] Read .paf/COMMS.md
- [ ] Find my section (<!-- AGENT:[NAME]:START -->)
- [ ] Set Status: IN_PROGRESS
- [ ] Write Timestamp
- [ ] Start work
- [ ] Update every 2 minutes
- [ ] Set Status: COMPLETED when done
- [ ] Include Handoff: @ORCHESTRATOR

---

**Remember: If you don't update COMMS.md, the CTO cannot see your progress and may terminate you!**
