# /paf-quickref - PAF Quick Reference Card

Compact quick reference for PAF Framework.

## Usage

```
/paf-quickref              # Full Quick Reference
/paf-quickref --compact    # Ultra-compact (one line)
```

## Quick Reference Card

```
┌──────────────────────────────────────────────────────────────────────┐
│                    PAF FRAMEWORK - QUICK REFERENCE                     │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│ 🎪  START           /paf-cto "<request>"                            │
│                     /paf-cto "<request>" --build=quick|standard|comp│
│                     /paf-cto "<request>" --workflow=<workflow>      │
│                     /paf-cto "<request>" --autonomous (no prompts)  │
│                                                                      │
│ ⚡  BUILD PRESETS    quick         2-3 min    5-8 Agents            │
│                     standard      8-12 min   15-20 Agents (Default) │
│                     comprehensive 20-30 min  30-38 Agents           │
│                                                                      │
│ 📊  WORKFLOWS       perspective-review    Multi-Perspective         │
│                     security-audit        Alex 🔒 Security          │
│                     performance-review    Emma ⚡ Performance        │
│                     full-feature          All Agents                │
│                                                                      │
│ 👥  AGENTS          Alex 🔒 Security       Emma ⚡ Performance       │
│                     Sam 🎨 UX              David 🔀 Scalability      │
│                     Max 🔧 Maintainability Luna ♿ Accessibility     │
│                     Tom 💰 Cost            Nina 🎯 Triage           │
│                     Leo 📚 Documentation   Ava 💡 Innovation        │
│                                                                      │
│ 🔧  UTILITIES       /paf-init             Initialize project        │
│                     /paf-fix [type]       Auto-fix Errors           │
│                     /paf-validate [mode]  Build Verification        │
│                     /paf-status           Project Status            │
│                     /paf-help             Interactive Help          │
│                                                                      │
│ 💡  EXAMPLES                                                         │
│     /paf-cto "Review my auth"                                       │
│     /paf-cto "Quick check" --build=quick                            │
│     /paf-cto "Security audit" --workflow=security-audit             │
│     /paf-cto "Full review" --autonomous                             │
│     /paf-fix typescript                                             │
│     /paf-validate                                                   │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

## Compact Mode (`--compact`)

```
PAF: /paf-cto "<req>" [--build=quick|standard|comprehensive] [--workflow=X] [--autonomous] | /paf-fix | /paf-validate | /paf-help
```

## Build & Workflow Guide

```
┌─────────────────────────────────────────────────────────────────┐
│ 🎯 WHEN TO USE EACH BUILD/WORKFLOW                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ BUILDS:                                                         │
│ quick          → Fast feedback, PR reviews, urgent checks      │
│ standard       → Normal reviews, feature development           │
│ comprehensive  → Pre-release audits, deep analysis             │
│                                                                 │
│ WORKFLOWS:                                                      │
│ security-audit       → Security concerns, vulnerabilities      │
│ performance-review   → Performance bottlenecks, optimization   │
│ perspective-review   → Multi-stakeholder code review           │
│ full-feature         → Complete feature development            │
│                                                                 │
│ Note: Claude understands your intent semantically -            │
│       just describe what you need in natural language          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Agent Specializations

```
┌─────────────────────────────────────────────────────────────────┐
│ 👥 AGENT FOCUS AREAS                                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Alex 🔒  Vulnerabilities, Auth, OWASP, Input Validation        │
│ Emma ⚡  Latency, N+1 Queries, Caching, Memory Leaks            │
│ Sam 🎨   User Flows, States, Feedback, Mobile UX               │
│ David 🔀 Architecture, Microservices, Load Balancing           │
│ Max 🔧   SOLID, Code Smells, Tech Debt, Refactoring            │
│ Luna ♿  WCAG 2.1, Screen Reader, Keyboard, Contrast           │
│ Tom 💰   Cloud Costs, FinOps, Right-sizing, Optimization       │
│ Nina 🎯  Priority Matrix, Risk Assessment, Go/No-Go            │
│ Leo 📚   README, API Docs, Comments, Onboarding                │
│ Ava 💡   Emerging Tech, Alternatives, Future-proofing          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Common Patterns

```
┌─────────────────────────────────────────────────────────────────┐
│ 💡 COMMON USAGE PATTERNS                                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ Quick Check before Commit:                                      │
│   /paf-cto "Quick review of my changes" --build=quick          │
│                                                                 │
│ Normal Feature Review:                                          │
│   /paf-cto "Review this new feature"                           │
│                                                                 │
│ Security Before Release:                                        │
│   /paf-cto "Security audit" --workflow=security-audit          │
│                                                                 │
│ Full Audit:                                                     │
│   /paf-cto "Complete audit" --build=comprehensive              │
│                                                                 │
│ Fix Build Errors:                                               │
│   /paf-fix                                                     │
│   /paf-fix typescript                                          │
│                                                                 │
│ Validate Before Push:                                           │
│   /paf-validate                                                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```
