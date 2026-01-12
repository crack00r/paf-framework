# Workflow: Hotfix

> Critical fix - immediate deployment without full review

## When to use?
- Production is down
- Security vulnerability
- Data loss risk
- P1 severity

## ⚠️ WARNING
This workflow skips normal gates. Only for real emergencies!

## Process

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           HOTFIX WORKFLOW                                │
│                          ⚠️ EMERGENCY ONLY ⚠️                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. INCIDENT DECLARATION (Inci + Nina)                                 │
│  └── Document problem, confirm P1 severity                             │
│           │                                                             │
│           ▼                                                             │
│  2. QUICK FIX (Bug-Fixer)                                              │
│  └── Fastest fix, workaround OK                                        │
│           │                                                             │
│           ▼                                                             │
│  3. QUICK REVIEW (Rachel + Alex - 15min max)                           │
│  └── Sanity check, security check, no breaking changes                 │
│           │                                                             │
│           ▼                                                             │
│  4. DEPLOY NOW (Tony)                                                   │
│  └── Directly to production (skip staging if necessary)                │
│           │                                                             │
│           ▼                                                             │
│  5. VERIFY & MONITOR (Monitor + Tina)                                  │
│  └── Verify fix works, intensive monitoring                            │
│           │                                                             │
│           ▼                                                             │
│  6. POST-MORTEM (George + Otto)                                        │
│  └── Incident Review, Lessons Learned, Process Improvements            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Claude Code Prompt

```
🚨 HOTFIX WORKFLOW for: [CRITICAL PROBLEM]

**Phase 1: Incident Declaration (Inci + Nina)**
- Declare P1 incident (Inci)
- Document problem (Inci)
- Priority assessment (Nina)

**Phase 2: Quick Fix (Bug-Fixer)**
- FASTEST fix
- Workaround is OK
- Perfection later

**Phase 3: Quick Review (Rachel + Alex)**
- Max 15 minutes
- Sanity check (Rachel)
- Security check (Alex)
- Only: No breaking changes? No data loss?

**Phase 4: Deploy (Tony)**
- Directly to production
- Skip staging if necessary

**Phase 5: Verify (Monitor + Tina)**
- Is the problem solved? (Monitor)
- System health check (Monitor)
- Quick verification (Tina)

**Phase 6: Post-Mortem (George + Otto)**
- What happened? (George)
- Summary (George)
- How do we prevent this? (Otto)
- Process improvements (Otto)

IMPORTANT: Speed > Perfection. Fix it, then make it right.
```

## Post-Hotfix Checklist

- [ ] Incident documented
- [ ] Proper fix as follow-up task
- [ ] Add tests
- [ ] Improve monitoring
- [ ] Post-mortem conducted
- [ ] Lessons learned documented