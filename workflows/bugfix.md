# Workflow: Bugfix

> Fast bug-fix workflow - from report to deploy

## When to use?
- Bug reported
- Not critical (otherwise Hotfix)
- Normal sprint cycle

## Process

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           BUGFIX WORKFLOW                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. TRIAGE (Nina + Alex)                                                │
│  └── Analyze bug, reproduce, determine severity, security check        │
│           │                                                             │
│           ▼                                                             │
│  2. FIX (Bug-Fixer + Anna)                                             │
│  └── Fix bug, write test that covers the bug                           │
│           │                                                             │
│           ▼                                                             │
│  3. TEST (Tina)                                                         │
│  └── Verify fix, test coverage                                          │
│           │                                                             │
│           ▼                                                             │
│  4. REVIEW (Rachel + Max)                                               │
│  └── Code Review, Regression Check, Maintainability                     │
│           │                                                             │
│           ▼                                                             │
│  5. DEPLOY (Tony)                                                       │
│  └── Staging → Production                                               │
│           │                                                             │
│           ▼                                                             │
│  6. AGGREGATION (George)                                                │
│  └── Summary and retrospective                                          │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Claude Code Prompt

```
I want to run the PAF Bugfix Workflow for bug [BUG_ID/DESCRIPTION].

**Phase 1: Triage (Nina + Alex)**
- Reproduce the bug (Nina)
- Determine root cause (Nina)
- Set severity (P1-P4) (Nina)
- Security impact check (Alex)

**Phase 2: Fix (Bug-Fixer + Anna)**
- Implement fix (Bug-Fixer)
- Write test that covers the bug (Bug-Fixer)
- Support and review (Anna)

**Phase 3: Test (Tina)**
- Verify fix works
- Test coverage check
- Regression testing

**Phase 4: Review (Rachel + Max)**
- Code Review (Rachel)
- Regression Check (Rachel)
- Maintainability Check (Max)

**Phase 5: Deploy (Tony)**
- Deploy to Staging
- Verify fix
- Deploy to Production

**Phase 6: Aggregation (George)**
- Summary and retrospective

Document in .paf/COMMS.md.
```

## Severity Guide

| Severity | Description | Response Time |
|----------|--------------|---------------|
| P1 | Critical - System down | Immediately (→ Hotfix) |
| P2 | High - Major feature broken | Today |
| P3 | Medium - Feature degraded | This week |
| P4 | Low - Minor issue | Next sprint |