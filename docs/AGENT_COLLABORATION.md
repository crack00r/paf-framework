# PAF Agent Collaboration Guide

> This document defines how all 38 PAF agents work together, communicate, and coordinate with each other.

---

## Core Principles

1. **Agents are autonomous** - Each agent makes decisions in their area
2. **Communication is key** - Everything is documented (COMMS.md + GitHub)
3. **Spawning hierarchy** - Team leads can start sub-agents
4. **GitHub Projects** - Central planning and tracking platform
5. **Collaboration** - Brainstorming, ideas, change requests are welcome

---

## Spawning Authority

### Who Can Spawn Agents?

```
Level 1: CTO (Orchestrator)
├── Can spawn ALL 37 agents
├── Spawns Implementation Team DIRECTLY (flat structure)
└── Starts workflows, delegates to Team Leads

Level 2: Team Leads (with Spawning Authority)
├── Sophia (Architect) → can spawn: Michael, Kai
├── Rachel (Review Lead) → can spawn: Stan, Scanner, Perf
├── Sarah (Lead Dev) → COORDINATES only, does NOT spawn (CTO spawns team directly)
├── Tony (DevOps Lead) → can spawn: Miggy, Rel
├── George (Scrum Master) → can spawn: Otto, Docu
└── Inci (Incident Commander) → can spawn: Monitor, Feedback

Level 3: All other agents
└── Do NOT spawn agents, but communicate freely

NOTE: Implementation Team (Sarah, Chris, Dan, Anna, Tina) is spawned DIRECTLY
by CTO for maximum parallelism and to avoid 4-agent limit problems.
```

### How Does a Team Lead Spawn?

```bash
# In COMMS.md or directly
@SPAWN Chris "Implement the UI for Feature X"
@SPAWN Dan "Create backend API for Feature X"

# The spawned agent reads:
# 1. Their agent definition (~/.paf/agents/[category]/[name].md)
# 2. COMMS.md for context
# 3. GitHub Issues for details
```

---

## GitHub Projects - Usage for All Agents

### Available Boards

| Board | Purpose | Who Uses It |
|-------|---------|-------------|
| **Sprint** | Current work | All agents |
| **Backlog** | Future work | Maya, Sophia, Michael |
| **Security** | Security findings | Alex, Scanner |
| **Bugs** | Bug tracking | Nina, Tina, Sarah |
| **Tech Debt** | Technical debt | Max, Sarah, Sophia |
| **Architecture** | ADRs, Design | Sophia, David |
| **Releases** | Release planning | Tony, Rel |

### How Do Agents Use GitHub Projects?

```bash
# Create issue and assign to board
gh issue create \
  --title "[PREFIX-NUM] Title" \
  --label "labels..." \
  --project "Sprint"

# Change issue status
gh project item-edit \
  --project-id $PROJECT_ID \
  --id $ITEM_ID \
  --field-id $STATUS_FIELD_ID \
  --single-select-option-id $STATUS_ID

# Example status values:
# - "Backlog" (new)
# - "Ready" (ready for work)
# - "In Progress" (in progress)
# - "In Review" (being reviewed)
# - "Done" (done)
```

### Issue Prefixes by Agent

| Agent | Prefix | Example |
|-------|--------|---------|
| Alex (Security) | SEC | [SEC-001] SQL Injection in login.ts |
| Emma (Performance) | PERF | [PERF-012] N+1 Query in UserList |
| Sam (UX) | UX | [UX-003] Confusing button placement |
| Sophia (Architect) | ADR | [ADR-007] Use Event Sourcing |
| Sarah (Implementer) | IMPL | [IMPL-045] Add user authentication |
| Rachel (Reviewer) | REV | [REV-023] Missing error handling |
| Tony (DevOps) | OPS | [OPS-008] Setup Cloudflare Workers |

---

## Communication Between Agents

### COMMS.md - Live Communication

```markdown
<!-- AGENT:SARAH:START -->
### Status: IN_PROGRESS
### Timestamp: 2024-01-10 14:30

**Working on:** Issue #45 - User Authentication

**Question for @Sophia:**
Should we use JWT or Session Cookies?

**Idea:**
We could add a cache layer - @Emma what do you think?

**Change request for @Michael:**
The feature breakdown is missing error states - please add.

**Blocker:**
Waiting for response from @Alex regarding token storage.

### Status: COMPLETED
**Handoff:** @RACHEL for code review
<!-- AGENT:SARAH:END -->
```

### Direct Communication (@-Mentions)

Agents can address each other directly:

| Syntax | Meaning |
|--------|---------|
| `@Sophia` | Question/request to Sophia |
| `@SPAWN Chris` | Team Lead spawns Chris |
| `@ORCHESTRATOR` | Handoff to CTO |
| `@ALL` | Broadcast to all active agents |

### Communication Types

```markdown
**Question:** @Agent - What do you think about X?
**Idea:** We could do Y - @Agent1 @Agent2
**Change request:** @Agent please adjust Z
**Blocker:** Waiting for @Agent for W
**Brainstorming:** Let's discuss V - @ALL
**Feedback:** @Agent your proposal for U is good, but...
**Decision:** After discussion: We'll do T
**Escalation:** @ORCHESTRATOR must decide
```

---

## Brainstorming & Ideas

### How Does Brainstorming Work?

1. **Agent starts brainstorming in COMMS.md:**
```markdown
<!-- BRAINSTORM:AUTH-APPROACH:START -->
**Topic:** Which auth approach for Feature X?
**Started by:** Sarah
**Participants:** @Alex @Sophia @Michael

**Options:**
1. JWT Tokens - Stateless, scalable
2. Session Cookies - Simpler, more secure against XSS
3. OAuth2 - Standard, but complex

**Votes:**
- Sarah: Option 1 (JWT)
- Alex: Option 2 (Cookies - more secure)
- Sophia: Option 2 (less complexity)

**Decision:** Option 2 - Session Cookies
**Reason:** Security > Scalability for MVP
<!-- BRAINSTORM:AUTH-APPROACH:END -->
```

2. **GitHub Discussion (for larger topics):**
```bash
# Create issue with "discussion" label
gh issue create \
  --title "[DISCUSS] Auth strategy for MVP" \
  --label "discussion,architecture" \
  --body "## Topic\n...\n## Options\n..."
```

---

## Change Requests

### How to Submit Change Requests?

```markdown
<!-- CHANGE-REQUEST:START -->
**From:** Emma (Performance)
**To:** Sarah (Implementer)
**Issue:** #45

**Current state:**
The UserList loads all 10,000 users at once.

**Problem:**
Performance issue: 5s load time, 50MB response.

**Proposal:**
Implement pagination with cursor-based paging.

**Priority:** P1 (should be fixed before merge)

**Accepted by Sarah:** Yes / No / Discussion needed
<!-- CHANGE-REQUEST:END -->
```

### Change Request Workflow

```
1. Agent creates Change Request in COMMS.md
2. Recipient confirms or discusses
3. On conflict: Escalation to Team Lead
4. On architecture change: @Sophia decides
5. On security: @Alex has veto right
6. Final conflict: @ORCHESTRATOR (CTO) decides
```

---

## Decision Making

### Decision Hierarchy

```
Security decisions → Alex has veto
Performance-critical → Emma is consulted
Architecture → Sophia decides
UX questions → Sam decides
Cost impact → Tom is consulted
Accessibility → Luna has veto on A11Y issues
Conflict → CTO decides final
```

### Voting on Disagreements

```markdown
<!-- VOTE:CACHING-STRATEGY:START -->
**Question:** Redis vs In-Memory Cache?
**Options:**
1. Redis - Persistent, shared
2. In-Memory - Faster, simpler

**Votes:**
- Emma: Redis (Performance with persistence)
- Tom: In-Memory (more cost-effective)
- David: Redis (scales better)
- Sophia: Redis (fits the architecture)

**Result:** Redis (3:1)
**Decision documented in:** ADR-015
<!-- VOTE:CACHING-STRATEGY:END -->
```

---

## GitHub Issues for Communication

### Issue Labels for Communication

| Label | Meaning |
|-------|---------|
| `discussion` | Open discussion |
| `decision-needed` | Decision required |
| `blocked` | Blocked, needs help |
| `idea` | Idea/proposal |
| `change-request` | Change request |
| `question` | Question for team |

### Issue as Discussion Thread

```bash
# Create discussion issue
gh issue create \
  --title "[DISCUSS] Caching strategy" \
  --label "discussion,architecture,decision-needed" \
  --body "## Context\n...\n## Options\n...\n## Please vote"

# Add comments
gh issue comment 123 --body "@sophia I vote for Option 2 because..."

# Document decision
gh issue comment 123 --body "## Decision\nOption 2 chosen.\n\nReason: ...\n\nADR: #ADR-015"
gh issue close 123 --reason completed
```

---

## Workflow Example: Feature Implementation

```
1. CTO spawns Sophia (Planning)
   └── Sophia creates GitHub Issue in Backlog Board
   └── Sophia spawns Michael for Feature Breakdown
   └── Michael creates sub-issues, links to parent

2. CTO moves Issue to "Ready"
   └── CTO spawns Sarah, Chris, Dan DIRECTLY (flat structure)
   └── All read Issue in parallel
   └── Sarah coordinates, Chris Frontend, Dan Backend
   └── All update COMMS.md with progress

3. Sarah: "Question for @Alex: Token storage?"
   └── Alex responds in COMMS.md
   └── If concerns: Alex creates Security Issue

4. Sarah done → Issue to "In Review"
   └── CTO spawns Rachel (Review)
   └── Rachel spawns Stan + Scanner
   └── Findings are created as Issues

5. Review passed → Issue to "Done"
   └── CTO spawns Tony (Deployment)
   └── Tony deploys, spawns Rel for Release Notes

6. CTO spawns George (Retrospective)
   └── George aggregates all COMMS.md entries
   └── George creates Retro-Summary Issue
```

---

## Quick Reference

### Agent wants to ask another agent:
```markdown
**Question for @AgentName:**
[Your question here]
```

### Agent wants to share an idea:
```markdown
**Idea:** [Description]
What do you think? @Agent1 @Agent2
```

### Agent wants to propose a change:
```markdown
**Change request for @Agent:**
[What should be changed and why]
```

### Team Lead wants to spawn a sub-agent:
```markdown
@SPAWN AgentName "Describe task"
```

### Agent is blocked:
```markdown
**Blocker:**
Waiting for [What] from @Agent
```

### Agent wants to escalate:
```markdown
**Escalation to @ORCHESTRATOR:**
[Describe problem, request help]
```

---

## Important Rules

1. **Document everything** - COMMS.md + GitHub Issues
2. **@-Mention when you need a response** - Otherwise no one reads it
3. **Decisions in ADRs** - Document important decisions
4. **Update GitHub Projects** - Always keep status current
5. **Respectful communication** - Constructive, not destructive
6. **Avoid deadlocks** - On stalemate: @ORCHESTRATOR
7. **Security/A11Y have veto** - Alex and Luna can block
