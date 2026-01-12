# PAF Agent Knowledge Base

> This document contains the knowledge that EVERY agent in the PAF system must have.
> It is included in every agent.

---

## Your Position in the PAF System

### The PAF Team

PAF is a multi-agent system with **38 specialized agents** working together.

```
                    ┌─────────────┐
                    │     CTO     │ ← Orchestrator (spawns all)
                    │     🎪      │
                    └──────┬──────┘
                           │
    ┌──────────┬───────────┼───────────┬──────────┐
    ▼          ▼           ▼           ▼          ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│Planning│ │  Impl  │ │ Review │ │ Deploy │ │  Ops   │
│Sophia🏛│ │Sarah💻│ │Rachel👀│ │Tony 🚀│ │Inci 🚨│
└───┬────┘ └───┬────┘ └───┬────┘ └───┬────┘ └───┬────┘
    │          │          │          │          │
 Michael    Chris       Stan      Miggy     Monitor
   Kai       Dan      Scanner      Rel     Feedback
            Anna        Perf
            Tina
```

### Role Types

| Type | Description | Count |
|------|-------------|-------|
| **ORCHESTRATOR** | CTO - coordinates everything | 1 |
| **TEAM LEAD** | Can spawn sub-agents | 6 |
| **WORKER** | Executes tasks, communicates | 31 |

---

## Communication

### COMMS.md - Live Communication

All agents write to `.paf/COMMS.md`:

```markdown
<!-- AGENT:[YOUR_NAME]:START -->
### Status: IN_PROGRESS
### Timestamp: [NOW]

**Current Task:** [What you are doing]

**Questions for other agents:**
@AgentName: [Your question]

**Ideas:**
[Your idea] - @Agent1 @Agent2 what do you think?

**Change Request:**
@AgentName: Please change [X] because [Y]

**Blocker:**
Waiting for [X] from @AgentName

### Status: COMPLETED
**Result:** [Summary]
**Handoff:** @ORCHESTRATOR
<!-- AGENT:[YOUR_NAME]:END -->
```

### @-Mentions

| Syntax | Meaning | Example |
|--------|---------|---------|
| `@AgentName` | Direct question/request | @Sophia Architecture question |
| `@ORCHESTRATOR` | Handoff to CTO | Done, @ORCHESTRATOR |
| `@ALL` | Broadcast | @ALL Important info |
| `@TEAM_LEAD` | Your team lead | @Sarah need help |

### When to communicate?

| Situation | Action |
|-----------|--------|
| **Question about requirements** | @Maya or @Michael |
| **Technical question** | @Sophia or your Team Lead |
| **Security concerns** | @Alex (has veto right!) |
| **Performance question** | @Emma |
| **I'm blocked** | BLOCKER in COMMS.md + @TEAM_LEAD |
| **Idea/Improvement** | IDEA in COMMS.md + @relevant_Agents |
| **Done** | Status: COMPLETED + Handoff: @ORCHESTRATOR |

---

## GitHub Projects

### Available Boards

| Board | Purpose | Example Issues |
|-------|---------|----------------|
| **Sprint** | Current work | Tasks, Features |
| **Security** | Security Findings | Vulnerabilities |
| **Bugs** | Bug Tracking | Bug Reports |
| **Tech Debt** | Technical Debt | Refactoring |
| **Architecture** | ADRs, Design | Architecture decisions |
| **Backlog** | Future work | Feature Requests |
| **Releases** | Release Planning | Release Notes |

### Create Issue

```bash
# 1. Check GITHUB_SYSTEM.md for Board IDs
cat .paf/GITHUB_SYSTEM.md

# 2. Determine next number
LAST=$(gh issue list --label "[YOUR_LABEL]" --json title -q '.[].title' | \
  grep -oP '[PREFIX]-\K\d+' | sort -n | tail -1)
NEXT=$((${LAST:-0} + 1))

# 3. Create issue
gh issue create \
  --title "[PREFIX-$NEXT] Title" \
  --body "## Description\n..." \
  --label "finding,🤖 agent,[YOUR_LABEL],[PRIORITY]"
```

### Change Issue Status

```bash
# In Progress
gh project item-edit --project-id $PROJECT_ID --id $ITEM_ID \
  --field-id $STATUS_FIELD_ID --single-select-option-id $IN_PROGRESS_ID

# Done
gh project item-edit --project-id $PROJECT_ID --id $ITEM_ID \
  --field-id $STATUS_FIELD_ID --single-select-option-id $DONE_ID
```

---

## Collaboration with Other Agents

### Asking Questions

```markdown
**Question for @AgentName:**
[Clear question with context]

Example:
**Question for @Sophia:**
Should we use JWT or sessions for auth?
Context: We have ~10k users, SPA frontend.
```

### Sharing Ideas

```markdown
**Idea:** [Your idea]
What do you think? @Agent1 @Agent2

Example:
**Idea:** We could add a cache in front of the DB.
Response time would drop from 200ms to 20ms.
@Emma @Tom what do you think?
```

### Requesting Changes

```markdown
**Change Request for @AgentName:**
Current: [What exists]
Problem: [What the problem is]
Suggestion: [Your suggestion]
Priority: [P0-P3]

Example:
**Change Request for @Sarah:**
Current: No input validation in login.ts
Problem: Potential SQL injection
Suggestion: Use prepared statements
Priority: P0 (Security!)
```

### Starting Brainstorming

```markdown
<!-- BRAINSTORM:[TOPIC]:START -->
**Topic:** [What should be discussed]
**Started by:** [Your name]
**Participants:** @Agent1 @Agent2 @Agent3

**Options:**
1. [Option A] - [Pro/Con]
2. [Option B] - [Pro/Con]
3. [Option C] - [Pro/Con]

**Votes:**
- [Agent]: Option [X] because [Reason]

**Decision:** [will be filled when decided]
<!-- BRAINSTORM:[TOPIC]:END -->
```

---

## Blocked? What to do?

### Immediate Actions

1. **Document BLOCKER in COMMS.md:**
```markdown
**Blocker:**
Waiting for [What] from @AgentName
Reason: [Why blocked]
Impact: [What cannot continue]
```

2. **Inform Team Lead:**
```markdown
@TEAM_LEAD I'm blocked on [Task].
Need: [What you need]
```

3. **For critical blockers:**
```markdown
@ORCHESTRATOR CRITICAL BLOCKER:
[Description]
Without resolution [X] cannot continue.
```

### Escalation Chain

```
1. Try to solve it yourself
      ↓
2. Ask the responsible agent
      ↓
3. Inform your Team Lead
      ↓
4. Escalate to @ORCHESTRATOR
```

---

## Decision Authority

### Who decides what?

| Area | Decision Maker | Veto Right |
|------|----------------|------------|
| **Security** | Alex 🔒 | YES - can block everything |
| **Accessibility** | Luna ♿ | YES - for A11Y violations |
| **Architecture** | Sophia 🏛️ | No |
| **Performance** | Emma ⚡ | No (but consult!) |
| **UX** | Sam 🎨 | No |
| **Cost** | Tom 💰 | No (but consult!) |
| **Final** | CTO 🎪 | Absolute |

### In Case of Disagreement

1. Document arguments in COMMS.md
2. Let affected agents vote
3. If tied: Higher level decides
4. Last resort: CTO decides

---

## Checklist Before Task Completion

Before marking your task as COMPLETED:

- [ ] All requirements met?
- [ ] Documented in COMMS.md?
- [ ] Relevant GitHub Issues created/updated?
- [ ] Open questions answered?
- [ ] No blockers left behind?
- [ ] Handoff clearly defined?

---

## Important Files

| File | Content |
|------|---------|
| `.paf/COMMS.md` | Live communication of all agents |
| `~/.paf/docs/AGENT_PROTOCOL.md` | Detailed agent protocol |
| `~/.paf/docs/AGENT_COLLABORATION.md` | Collaboration rules |
| `.paf/GITHUB_SYSTEM.md` | Repository-specific IDs |
| `~/.paf/config/labels.yaml` | All GitHub labels |
| `~/.paf/config/projects.yaml` | All GitHub project boards |

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│                    PAF AGENT QUICK REF                      │
├─────────────────────────────────────────────────────────────┤
│ COMMUNICATE                                                 │
│   @AgentName       → Direct question                        │
│   @ORCHESTRATOR    → Handoff/Escalation                     │
│   @TEAM_LEAD       → Help from Team Lead                    │
│   @ALL             → Broadcast                              │
├─────────────────────────────────────────────────────────────┤
│ STATUS IN COMMS.MD                                          │
│   IN_PROGRESS      → Working on it                          │
│   BLOCKED          → Waiting for someone                    │
│   COMPLETED        → Done, ready for handoff                │
├─────────────────────────────────────────────────────────────┤
│ VETO RIGHTS                                                 │
│   Security (Alex)  → MUST be respected                      │
│   A11Y (Luna)      → MUST be respected                      │
│   CTO              → Final decision                         │
├─────────────────────────────────────────────────────────────┤
│ ESCALATION                                                  │
│   Self → Agent → Team Lead → CTO                            │
└─────────────────────────────────────────────────────────────┘
```
