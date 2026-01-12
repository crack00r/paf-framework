# Workflow: Perspective Review

> Launches 10 agents in parallel to evaluate a feature/spec from different perspectives

## When to use?
- Before implementing a new feature
- After major spec changes
- When uncertain about design decisions

## Process

```
┌─────────────────────────────────────────────────────────────────┐
│                    PERSPECTIVE REVIEW                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  INPUT: Feature-Spec / Plan Document                           │
│                        │                                        │
│                        ▼                                        │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              PARALLEL REVIEW (10 Agents)                  │  │
│  │                                                           │  │
│  │  [Alex]   [Emma]   [Sam]    [David]   [Max]              │  │
│  │  Security Perform  UX       Scale     Maintain           │  │
│  │                                                           │  │
│  │  [Luna]   [Tom]    [Nina]   [Leo]     [Ava]              │  │
│  │  A11y     FinOps   Triage   Docs      Innovate           │  │
│  │                                                           │  │
│  └──────────────────────────────────────────────────────────┘  │
│                        │                                        │
│                        ▼                                        │
│               COMMS.md (all write)                             │
│                        │                                        │
│                        ▼                                        │
│               George aggregates                                 │
│                        │                                        │
│                        ▼                                        │
│               OUTPUT: Review-Report                             │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Starting

```bash
# In project folder
paf review perspective --spec="docs/feature-spec.md"

# Or manually in Claude Code:
# "Start PAF Perspective Review for [FEATURE]"
```

## Claude Code Prompt

```
I want to run a PAF Perspective Review for [FEATURE/SPEC].

1. First read the spec: [PATH_TO_SPEC]
2. Read the agent definitions: ~/.paf/agents/perspectives/*.md
3. Run each of the 10 agents and write the feedback in COMMS.md
4. Each agent writes in its own section
5. At the end: George aggregates the findings

Agents (in this order):
1. Alex (🔒 Security) - GDPR, Security
2. Emma (⚡ Performance) - Latency, Throughput
3. Sam (🎨 UX) - Usability, User Experience
4. David (🔀 Scalability) - Scalability, Architecture
5. Max (🔧 Maintainability) - Code Quality, Maintainability
6. Luna (♿ Accessibility) - WCAG, Accessibility
7. Tom (💰 Cost/FinOps) - Costs, Resources
8. Nina (🎯 Triage) - Prioritization, Testing
9. Leo (📚 Documentation) - Documentation
10. Ava (💡 Innovation) - New Ideas, Improvements

Write all findings directly in .paf/COMMS.md in the respective agent section.
```

## Output

After the review, COMMS.md contains:
- 10 sections with agent feedback
- George's Aggregation with:
  - Critical Findings (Must Fix)
  - Important Findings (Should Fix)
  - Nice-to-Haves
  - Action Items

## Example Output

```markdown
## 📋 Aggregated Review (George)

### Critical (Blocker for Go-Live)
| ID | Finding | Agent | Action |
|----|---------|-------|--------|
| SEC-001 | Token too short | Alex | Increase token to 256-bit |
| A11Y-001 | Missing alt texts | Luna | Add alt texts |

### Important (Should Fix)
| ID | Finding | Agent | Action |
|----|---------|-------|--------|
| UX-001 | Unclear CTA | Sam | Change button text |
| TRIAGE-001 | Edge case missing | Nina | Add test |

### Nice-to-Have
- [MOB-001] Better camera rotation (Leo)
- [DEV-001] Refactoring recommended (David)

### Next Steps
1. [ ] Fix SEC-001 (@Sarah)
2. [ ] Fix A11Y-001 (@Sarah)
3. [ ] Discuss UX-001 with Kai
```
