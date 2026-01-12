# PAF Agent Dependency & Handoff Matrix

> Shows which agent needs which input and to whom they hand off

---

## 📊 Dependency Matrix

### Discovery Phase → Planning Phase

| From | To | Handoff |
|------|-----|---------|
| **Maya** (Research) | Sophia, Michael | Research Report, Best Practices |
| **Iris** (Innovation) | Sophia, Michael | Innovation Ideas, Alternatives |
| **Ben** (Data) | Kai, Michael | Metrics, Analytics |

### Planning Phase → Perspectives

| From | To | Handoff |
|------|-----|---------|
| **Michael** (Feature Arch) | All 10 Perspectives | Feature Spec with A/B/C/D |
| **Sophia** (Architect) | David, Tom | Architecture Design |
| **Kai** (PO) | All 10 Perspectives | Scope, Priorities |

### Perspectives → Implementation

| From | To | Handoff |
|------|-----|---------|
| **George** (aggregates) | Sarah | Prioritized Findings |
| **Alex** (Security) | Sarah, Anna | Security Requirements |
| **Sam** (UX) | Chris | UX Requirements |
| **David** (Scalability) | Sarah | Code Recommendations |
| **Nina** (Triage) | Tina | Test Requirements |

### Implementation Phase

| From | To | Handoff |
|------|-----|---------|
| **Michael** | **Sarah** | Feature Spec |
| **Sarah** | **Chris** | Component Requirements |
| **Sarah** | **Anna** | API Requirements |
| **Sarah** | **Dan** | DB Requirements |
| **Sarah** | **Tina** | Test Scope |
| **Tina** | **Sarah** | Test Results |

### Implementation → Review

| From | To | Handoff |
|------|-----|---------|
| **Sarah** | **Rachel** | Pull Request |
| **Sarah** | **Scanner** | Code for Scan |
| **Sarah** | **Stan** | Code for Standards |
| **Sarah** | **Perf** | Code for Performance |

### Review → Deployment

| From | To | Handoff |
|------|-----|---------|
| **Rachel** | **Tony** | Approved PR |
| **Scanner** | **Tony** | Security Clearance |
| **Dan** | **Miggy** | Migration Scripts |
| **Miggy** | **Tony** | Migration Ready |

### Deployment → Operations

| From | To | Handoff |
|------|-----|---------|
| **Tony** | **Monitor** | Deployed Version |
| **Tony** | **Rel** | Release for Notes |
| **Rel** | **Feedback** | Release Announcement |

### Operations → Retrospective

| From | To | Handoff |
|------|-----|---------|
| **Monitor** | **George** | Metrics, Incidents |
| **Feedback** | **George** | User Feedback |
| **Inci** | **George** | Incident Reports |

### Retrospective → Continuous

| From | To | Handoff |
|------|-----|---------|
| **George** | **Otto** | Process Issues |
| **George** | **Docu** | Doc Gaps |
| **Otto** | **All** | Process Improvements |
| **Docu** | **All** | Updated Docs |

---

## 🔄 Workflow-specific Handoffs

### Full Feature Workflow
```
Maya/Iris/Ben → Michael/Sophia/Kai → 10 Perspectives → Sarah+Team → Rachel+Team → Tony+Team → Monitor+Feedback → George
```

### Bugfix Workflow
```
Nina (Triage) → Sarah (Fix) → Tina (Test) → Rachel (Review) → Tony (Deploy)
```

### Hotfix Workflow
```
Inci (Declare) → Sarah (Fix) → Rachel (Quick Review) → Tony (Deploy) → Monitor (Verify)
```

### Security Audit
```
Max + Kai (Scope) → Scanner (Auto) → Max (Manual) → Sarah (Fix) → Max (Verify)
```

---

## 📝 Handoff Format in COMMS.md

When an agent hands off to another:

```markdown
## 🛠️ Sarah (Implementer)
<!-- AGENT:SARAH:START -->
### Last Activity: 2026-01-09 10:00

**Handoff to Rachel:**
- PR #45 ready for review
- Main changes: Auth-Flow
- Tests: 15 new, all green
- Docs: API.md updated

**Handoff to Tony:**
- After Merge: Ready for staging
- Migration: Yes, see .paf/migrations/
- Rollback: Documented
<!-- AGENT:SARAH:END -->
```

---

## 🚦 Blocker Escalation

When an agent is blocked:

| Blocker Type | Escalate to | Example |
|--------------|-------------|---------|
| Unclear Spec | Michael | "Part C not defined" |
| Architecture Question | Sophia | "Doesn't fit the design" |
| Scope Question | Kai | "Out of scope?" |
| Security Concern | Max | "Potential vulnerability" |
| Tech Blocker | David | "Dependency conflict" |
| Process Blocker | George | "Waiting for approval" |

---

## 📋 George's Aggregation Role

George coordinates all handoffs:

1. **Collects** outputs from all agents in COMMS.md
2. **Prioritizes** findings by impact
3. **Creates** action items with owner
4. **Tracks** progress
5. **Escalates** blockers

```markdown
## 📋 George (Aggregation)
<!-- AGENT:GEORGE:START -->
### Handoff Summary: [DATE]

**Ready for Implementation:**
- [Feature X] - Spec complete, reviewed

**Blocked:**
- [Feature Y] - Waiting for Security Review

**Action Items:**
| Action | Owner | Status |
|--------|-------|--------|
| Fix SEC-001 | Sarah | In Progress |
| Update Docs | Docu | Pending |
<!-- AGENT:GEORGE:END -->
```
