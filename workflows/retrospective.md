# Workflow: Retrospective

> Sprint-end review and continuous improvement

## When to use?
- End of each sprint
- After major release
- After incident
- Quarterly

## Process

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        RETROSPECTIVE WORKFLOW                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. COLLECT METRICS (George + Ben)                                     │
│  └── Sprint Metrics, Agent Performance, Costs                          │
│           │                                                             │
│           ▼                                                             │
│  2. PROCESS ANALYSIS (Otto)                                            │
│  └── Bottlenecks, Waste, Automation Opportunities                      │
│           │                                                             │
│           ▼                                                             │
│  3. DOCUMENTATION CHECK (Docu)                                         │
│  └── What is outdated? What is missing?                                │
│           │                                                             │
│           ▼                                                             │
│  4. FEEDBACK REVIEW (Iris, Feedback)                                   │
│  └── User Feedback from this period                                    │
│           │                                                             │
│           ▼                                                             │
│  5. RETROSPECTIVE (George)                                             │
│  ├── What went well?                                                    │
│  ├── What could be improved?                                            │
│  └── Action Items                                                       │
│           │                                                             │
│           ▼                                                             │
│  6. ACTION ITEMS → ISSUES                                              │
│  └── Create improvements as GitHub Issues                              │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Claude Code Prompt

```
I want to run a PAF Retrospective for Sprint [X].

**Phase 1: Metrics (George + Ben)**
Collect:
- Issues closed
- PRs merged
- Deployments
- Bugs found/fixed
- Token Usage (if trackable)
- Agent Performance

**Phase 2: Process (Otto)**
- What were the bottlenecks?
- Where was waste?
- What can we automate?

**Phase 3: Documentation (Docu)**
- Which docs are outdated?
- What is missing?
- What should be updated?

**Phase 4: Feedback (Feedback)**
- User Feedback from this period
- Trends
- Pain Points

**Phase 5: Retro (George)**
Facilitate:
- 🟢 What went well?
- 🔴 What could be improved?
- 💡 Ideas & Experiments
- ✅ Action Items

**Phase 6: Create Issues**
- Create GitHub Issues for Action Items
- Prioritize
- Assign

Document everything in .paf/COMMS.md and create a Retro-Report.
```

## Retro Format

```markdown
# Sprint X Retrospective

**Date:** YYYY-MM-DD
**Participants:** [Agents that were active]

## 📊 Metrics

| Metric | Value | vs Last Sprint |
|--------|-------|----------------|
| Issues Closed | X | +Y% |
| PRs Merged | X | +Y% |
| Deployments | X | +Y% |
| Bugs | X | -Y% |

## 🟢 What Went Well
- ...

## 🔴 What Could Be Improved
- ...

## 💡 Ideas & Experiments
- ...

## ✅ Action Items

| Action | Owner | Priority | Issue |
|--------|-------|----------|-------|
| ... | ... | P1 | #123 |

## 📈 Agent Performance

| Agent | Activity | Highlights |
|-------|----------|------------|
| Sarah | 18 PRs | Auth feature complete |
| Tony | 12 deploys | Zero downtime |
| ... | ... | ... |

## 🎯 Goals for Next Sprint
1. ...
2. ...
3. ...
```