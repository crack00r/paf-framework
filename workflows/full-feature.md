# Workflow: Full Feature Lifecycle

> Complete lifecycle from idea to production

## When to use?
- New major feature
- New component/module
- Significant changes

## Phases

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        FULL FEATURE WORKFLOW                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────┐                                                       │
│  │   1. DISCOVERY   │  Maya, Iris, Ben                                      │
│  │   Research &     │  → Research Report                                    │
│  │   Analysis       │                                                       │
│  └────────┬─────────┘                                                       │
│           │                                                                 │
│           ▼                                                                 │
│  ┌──────────────────┐                                                       │
│  │   2. PLANNING    │  Michael, Sophia, Kai                                 │
│  │   Architecture & │  → Feature Spec                                       │
│  │   Breakdown      │  → Task Breakdown (A/B/C/D)                           │
│  └────────┬─────────┘                                                       │
│           │                                                                 │
│           ▼                                                                 │
│  ┌──────────────────┐                                                       │
│  │ 3. PERSPECTIVES  │  10 Agents (parallel)                                 │
│  │   Multi-Stake-   │  Alex, Emma, Sam, David, Max,                         │
│  │   holder Review  │  Luna, Tom, Nina, Leo, Ava                            │
│  └────────┬─────────┘  → Review Report                                      │
│           │                                                                 │
│           ▼                                                                 │
│  ┌──────────────────┐                                                       │
│  │ 4. IMPLEMENTATION│  Sarah (lead), Chris, Anna, Dan, Tina                 │
│  │   Code, Tests,   │  → Pull Request                                       │
│  │   Components     │  → Tests                                              │
│  └────────┬─────────┘                                                       │
│           │                                                                 │
│           ▼                                                                 │
│  ┌──────────────────┐                                                       │
│  │   5. REVIEW      │  Rachel, Scanner, Stan, Perf                          │
│  │   Code Quality   │  → Review Report                                      │
│  │   & Security     │  → Approved PR                                        │
│  └────────┬─────────┘                                                       │
│           │                                                                 │
│           ▼                                                                 │
│  ┌──────────────────┐                                                       │
│  │  6. DEPLOYMENT   │  Tony, Miggy, Rel                                     │
│  │   Staging →      │  → Staging Deploy                                     │
│  │   Production     │  → Production Deploy                                  │
│  └────────┬─────────┘  → Release Notes                                      │
│           │                                                                 │
│           ▼                                                                 │
│  ┌──────────────────┐                                                       │
│  │  7. OPERATIONS   │  Inci, Monitor, Feedback                              │
│  │   Monitoring &   │  → Health Report                                      │
│  │   Feedback       │  → Feedback Summary                                   │
│  └────────┬─────────┘                                                       │
│           │                                                                 │
│           ▼                                                                 │
│  ┌──────────────────┐                                                       │
│  │ 8. RETROSPECTIVE │  George, Otto, Docu                                   │
│  │   Learnings &    │  → Sprint Report                                      │
│  │   Improvements   │  → Process Improvements                               │
│  └──────────────────┘                                                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Claude Code Prompt

```
I want to run the PAF Full Feature Workflow for [FEATURE].

**Feature:** [FEATURE_DESCRIPTION]

**Instructions:**
1. Read ~/.paf/SKILL.md for framework overview
2. Execute all phases sequentially
3. Document everything in .paf/COMMS.md
4. After each phase: Brief summary

**Phase 1: Discovery** (Maya, Iris, Ben)
- Maya: Research Best Practices
- Iris: Innovation Scout - what's new?
- Ben: Relevant Metrics

**Phase 2: Planning** (Michael, Sophia, Kai)
- Michael: Feature Breakdown (A/B/C/D Tasks)
- Sophia: Architecture Design
- Kai: Prioritization & Acceptance Criteria

**Phase 3: Perspective Review** (10 Agents)
- All 10 stakeholder perspectives
- → Stop here and show me the review

**Phase 4: Implementation** (Sarah lead)
- After review approval: Implementation
- Tests with Tina

**Phase 5: Code Review** (Rachel, Scanner, Stan, Perf)
- Quality gates must pass

**Phase 6: Deployment** (Tony, Rel)
- Staging → Production
- Release Notes

**Phase 7: Operations** (Monitor)
- 24h monitoring after deploy

**Phase 8: Retro** (George)
- What did we learn?

Start with Phase 1.
```

## Gate Checks

Between phases must be checked:

| Gate | From → To | Criterion |
|------|------------|-----------|
| G1 | Discovery → Planning | Research complete, clear direction |
| G2 | Planning → Perspectives | Spec complete, tasks defined |
| G3 | Perspectives → Implementation | No blockers from review |
| G4 | Implementation → Review | All tests passing, PR ready |
| G5 | Review → Deployment | All checks green, approved |
| G6 | Deployment → Operations | Staging verified |
| G7 | Operations → Retro | Production stable 24h |

## Outputs

| Phase | Output | Location |
|-------|--------|----------|
| Discovery | Research Report | COMMS.md |
| Planning | Feature Spec | docs/features/[feature].md |
| Perspectives | Review Report | .paf/reviews/[date]-[feature].md |
| Implementation | Pull Request | GitHub PR |
| Review | Review Comments | PR Comments |
| Deployment | Release | GitHub Release |
| Operations | Health Report | COMMS.md |
| Retro | Sprint Report | .paf/reviews/sprint-[n].md |
