# PAF Agent Protocol

> **IMPORTANT:** Every agent MUST know and follow this protocol!

---

## 🎯 Quick Reference

```
1. Read first: .paf/COMMS.md
2. Find your section: <!-- AGENT:[NAME]:START -->
3. Set Status: IN_PROGRESS
4. Complete your task
5. Document findings
6. Set Status: COMPLETED
7. Handoff: @ORCHESTRATOR
```

---

## 📡 Communication: COMMS.md

### Where is COMMS.md?

```
.paf/COMMS.md
```

### Finding Your Section

Each agent has a dedicated section:

```markdown
## [Agent Name] [Emoji] ([Role])
<!-- AGENT:[YOUR_NAME]:START -->
[Write here]
<!-- AGENT:[YOUR_NAME]:END -->
```

### Updating Your Section

**ALWAYS use this format:**

```markdown
<!-- AGENT:ALEX:START -->
### Status: IN_PROGRESS
### Timestamp: 2026-01-09T16:00:00Z

**Task:** [What you're doing]

**Findings:**
- ✅ OK: [What's good]
- ⚠️ Warning: [Improvements]
- ❌ Critical: [Must be fixed]

**Risk Level:** [LOW | MEDIUM | HIGH | CRITICAL]

**Recommendations:**
1. [Recommendation]
2. [Recommendation]

### Status: COMPLETED
**Handoff:** @ORCHESTRATOR
<!-- AGENT:ALEX:END -->
```

---

## 📊 Status Values

| Status | Meaning | When to set |
|--------|---------|-------------|
| `IDLE` | Waiting for activation | Initial state |
| `IN_PROGRESS` | Actively working | Immediately on start |
| `BLOCKED` | Needs input | When you can't continue |
| `COMPLETED` | Done | When task is finished |
| `ERROR` | Error occurred | On critical problems |

---

## ⏱️ Timeout & Error Handling

### Timeout

The CTO expects a response from each agent within the workflow timeout (default: 180 seconds per agent).

**If you need more time:**
1. Set Status: `IN_PROGRESS` with progress update
2. The CTO can extend the timeout

**If you won't finish in time:**
1. Set Status: `BLOCKED` with reason
2. Document what you've already completed
3. The CTO decides if another agent takes over

### COMMS.md doesn't exist?

If `.paf/COMMS.md` doesn't exist:
1. **The CTO creates it** from the template `~/.paf/templates/COMMS.md`
2. Agents do NOT create COMMS.md themselves
3. On error: Set status `BLOCKED`, inform CTO

### Agent Crash

If an agent doesn't respond:
1. CTO marks the agent as `TIMEOUT`
2. CTO decides: Retry or Skip
3. For critical agents: Workflow pauses

---

## 🔄 Handoff Protocol

### Back to CTO (Standard)

```markdown
**Handoff:** @ORCHESTRATOR
```

### To Another Agent

```markdown
**Handoff:** @GEORGE
**Handoff:** @RACHEL
**Handoff:** @SOPHIA
```

### No Handoff Needed

```markdown
**Handoff:** NONE
```

---

## 🚨 Reporting Blockers

When you can't continue:

```markdown
### Status: BLOCKED
### Timestamp: [NOW]

**Blocker:** [What's blocking you]
**Waiting for:** @[AGENT_NAME]
**Can continue after:** [What you need]
```

The CTO will resolve the blocker and inform you.

---

## 🏗️ Hierarchy

### Who Can Spawn Whom?

```
CTO (Chief Technology Officer)
 │
 ├── Perspective Agents (10) - Parallel review
 │    alex, emma, sam, david, max, luna, tom, nina, leo, ava
 │
 ├── Discovery Team
 │    ben, maya, iris
 │
 ├── Planning Team
 │    └── Sophia (Architect) → can spawn Michael, Kai
 │
 ├── Implementation Team
 │    anna, chris, dan, sarah, tina
 │
 ├── Review Team
 │    └── Rachel (Lead) → can spawn Stan, Scanner, Perf
 │
 ├── Deployment Team
 │    tony, rel, miggy
 │
 ├── Operations Team
 │    inci, monitor, feedback
 │
 └── Retrospective Team
      george, otto, docu
```

### Rules

1. **CTO is Entry Point** - User always talks to CTO first
2. **Phase Leads can spawn their team** - Sophia → Michael, Kai; Rachel → Stan, Scanner, Perf
3. **Perspective Agents don't spawn** - They only review, no sub-agents
4. **George is spawned last** - He aggregates all findings

---

## 📝 Output Formats

### Perspective Agents

```markdown
### [Emoji] [Name] ([Specialty])
**Risk Level:** [LOW | MEDIUM | HIGH | CRITICAL]

**Findings:**
- ✅ OK: [...]
- ⚠️ Warning: [...]
- ❌ Critical: [...]

**Recommendations:**
1. [...]

**Handoff:** @ORCHESTRATOR
```

### SDLC Team Agents

```markdown
### [Emoji] [Name] ([Role])
**Task:** [What you did]
**Status:** ✅ Done | ⚠️ Partial | ❌ Failed

**Deliverables:**
[Your outputs]

**Next Steps:**
[What should happen next]

**Handoff:** @ORCHESTRATOR
```

### George (Aggregator)

```markdown
### 📋 George (Aggregator)

**AGGREGATION REPORT**

**Executive Summary:**
[2-3 sentences]

**Key Findings:**
1. [Top Finding]
2. [...]

**Risk Matrix:**
| Risk | Severity | Impact | Owner |
|------|----------|--------|-------|
| ... | ... | ... | ... |

**Recommendations (Prioritized):**
1. [P1] [...]
2. [P2] [...]

**Go/No-Go:** [GO | NO-GO | CONDITIONAL]

**Handoff:** @ORCHESTRATOR
```

---

## ⚡ Best Practices

1. **Set status IMMEDIATELY** - IN_PROGRESS on start, COMPLETED at end
2. **Timestamp always current** - ISO format (2026-01-09T16:00:00Z)
3. **Write structured** - George must be able to aggregate
4. **ALWAYS specify handoff** - Never forget!
5. **Report blockers IMMEDIATELY** - Don't hang forever
6. **Keep it short and concise** - No novels, facts and recommendations

---

## 🐙 GitHub Integration

### Overview

In addition to COMMS.md, agents create **GitHub Issues** for their findings.

### When to use GitHub?

| Action | COMMS.md | GitHub |
|--------|----------|--------|
| Status updates | ✅ | ❌ |
| Internal communication | ✅ | ❌ |
| Document findings | ✅ | ✅ |
| Persistent issues | ❌ | ✅ |
| Team tracking | ❌ | ✅ |

### Workflow

```
1. Analyze
2. Write findings to COMMS.md (for George)
3. Create GitHub Issue (for persistence)
4. Add to Project Board
5. Set Status: COMPLETED
```

### Create Issue

```bash
# Determine next number
LAST=$(gh issue list --label "{AGENT_LABEL}" --json title -q '.[].title' | \
  grep -oP '{PREFIX}-\K\d+' | sort -n | tail -1)
NEXT=$((${LAST:-0} + 1))

# Create issue
gh issue create \
  --title "[{PREFIX}-$NEXT] {FINDING_TITLE}" \
  --body "## Finding
{DESCRIPTION}

## Location
{FILE}:{LINE}

## Severity
{CRITICAL|HIGH|MEDIUM|LOW}

## Recommendation
{RECOMMENDATION}

---
_Generated by PAF Agent {NAME}_" \
  --label "finding,🤖 agent,{AGENT_LABEL},{PRIORITY},{CATEGORY}"
```

### Add to Board

```bash
ISSUE_URL=$(gh issue view $ISSUE_NUM --json url -q .url)
gh project item-add {PROJECT_NUM} --owner {OWNER} --url $ISSUE_URL
```

### Find IDs

All repo-specific IDs are in:
```
.paf/GITHUB_SYSTEM.md
```

### Reference

See `~/.paf/docs/GITHUB_WORKFLOW.md` for complete documentation.

---

## 🔧 Troubleshooting

### "I can't find my section"

COMMS.md must exist with `<!-- AGENT:[NAME]:START/END -->` markers.
Check case sensitivity (ALEX not Alex).

### "My writing doesn't work"

Check: Has the CTO set `allowWrite: true`?

### "I don't know who to hand off to"

When in doubt always: `@ORCHESTRATOR` - the CTO decides then.

### "I need info from another agent"

Set status to `BLOCKED` and specify which agent you need.
The CTO will coordinate.

---

## 📚 Reference: The 38 Agents

### Perspective Agents (10)

| Name | Emoji | Role |
|------|-------|------|
| alex | 🔒 | Security Analyst |
| emma | ⚡ | Performance Engineer |
| sam | 🎨 | UX Designer |
| david | 🔀 | Solutions Architect |
| max | 🔧 | Senior Dev (Maintainability) |
| luna | ♿ | Accessibility Expert |
| tom | 💰 | FinOps Engineer |
| nina | 🎯 | Technical PM (Triage) |
| leo | 📚 | Technical Writer |
| ava | 💡 | Innovation Lead |

### SDLC Teams

| Team | Agents |
|------|--------|
| Discovery | ben, maya, iris |
| Planning | sophia, michael, kai |
| Implementation | anna, chris, dan, sarah, tina |
| Review | rachel, stan, scanner, perf |
| Deployment | tony, rel, miggy |
| Operations | inci, monitor, feedback |
| Retrospective | george, otto, docu |
| Utility | bug-fixer, validator, gideon |

---

## 🐙 GitHub Integration

From PAF v4.2, agents automatically create GitHub Issues for their findings.

### Setup

On first run, the CTO checks if `.paf/GITHUB_SYSTEM.md` exists.
If not, **Gideon** (Setup Agent) is spawned to:
- Create labels (91)
- Create project boards (7)
- Copy issue templates
- Set up GitHub Actions
- Generate `.paf/GITHUB_SYSTEM.md`

### Issue Creation

Every agent that generates findings:

1. **Determine next number:**
```bash
LAST=$(gh issue list --label "{AGENT_LABEL}" --json title -q '.[].title' | \
  grep -oP '{PREFIX}-\K\d+' | sort -n | tail -1)
NEXT=$((${LAST:-0} + 1))
```

2. **Create issue:**
```bash
gh issue create \
  --title "[{PREFIX}-$NEXT] {FINDING_TITLE}" \
  --body "## Finding\n{DESC}\n\n## Recommendation\n{REC}" \
  --label "finding,🤖 agent,{AGENT_LABEL},{PRIORITY},{CATEGORY}"
```

3. **Add to board:**
```bash
ISSUE_URL=$(gh issue view --json url -q .url)
gh project item-add {BOARD_NUM} --owner {OWNER} --url $ISSUE_URL
```

### Agent Prefixes

| Agent | Prefix | Board |
|-------|--------|-------|
| Alex 🔒 | SEC | Security |
| Emma ⚡ | PERF | Sprint |
| Sam 🎨 | UX | Sprint |
| David 🔀 | SCALE | Architecture |
| Max 🔧 | MAINT | Tech Debt |
| Luna ♿ | A11Y | Sprint |
| Tom 💰 | COST | Sprint |
| Nina 🎯 | TRIAGE | All |
| Leo 📚 | DOC | Sprint |
| Ava 💡 | IDEA | Backlog |

### Reference

- **System Config:** `.paf/GITHUB_SYSTEM.md` (repo-specific)
- **Labels:** `~/.paf/config/labels.yaml`
- **Boards:** `~/.paf/config/projects.yaml`
- **Workflow:** `~/.paf/docs/GITHUB_WORKFLOW.md`
