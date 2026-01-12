---
name: paf-quickref
description: "PAF Quick Reference - Compact reference for PAF Framework"
user-invocable: true
context: fork
model: claude-opus-4-5-20251101
allowed-tools:
  - Read
  - Bash
---

# /paf-quickref - PAF Quick Reference Command

> Compact quick reference for all PAF commands and features.

## Your Task

Display the PAF Quick Reference Card - a compact overview of all commands, build presets, workflows, and agents.

## Execution

### 1. Standard Mode (Complete)

Display the complete Quick Reference Card:

```
┌──────────────────────────────────────────────────────────────────────┐
│                    PAF FRAMEWORK - QUICK REFERENCE                   │
├──────────────────────────────────────────────────────────────────────┤
│                                                                      │
│ 🎪  START           /paf-cto "<request>"                            │
│                     /paf-cto "<request>" --build=quick|standard|comp│
│                     /paf-cto "<request>" --workflow=<workflow>      │
│                                                                      │
│ ⚡  BUILD PRESETS    quick         2-3 min    5-8 Agents            │
│                     standard      8-12 min   15-20 Agents (Default) │
│                     comprehensive 20-30 min  30-38 Agents           │
│                                                                      │
│ 📊  WORKFLOWS       perspective-review    Multi-perspectives        │
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
│                     /paf-fix [type]       Auto-fix errors           │
│                     /paf-validate [mode]  Build verification        │
│                     /paf-status           Project status            │
│                     /paf-help             Interactive help          │
│                                                                      │
│ 💡  EXAMPLES                                                         │
│     /paf-cto "Review my auth"                                       │
│     /paf-cto "Quick check" --build=quick                            │
│     /paf-cto "Security audit" --workflow=security-audit             │
│     /paf-fix typescript                                             │
│     /paf-validate                                                   │
│                                                                      │
└──────────────────────────────────────────────────────────────────────┘
```

### 2. Compact Mode (--compact)

Display ultra-compact single-line reference:

```
PAF: /paf-cto "<req>" [--build=quick|standard|comprehensive] [--workflow=X] | /paf-fix | /paf-validate | /paf-help
```

### 3. Build & Workflow Guide

Display when to use each build and workflow:

| Build/Workflow | When to Use |
|----------------|-------------|
| quick | Fast feedback, PR reviews, urgent checks |
| standard | Normal reviews, feature development |
| comprehensive | Pre-release audits, deep analysis |
| security-audit | Security concerns, vulnerability assessment |
| performance-review | Performance bottlenecks, optimization |
| perspective-review | Multi-stakeholder code review |

Note: Claude understands your intent semantically - just describe what you need in natural language.

### 4. Agent Specializations

| Agent | Focus Areas |
|-------|---------------|
| Alex 🔒 | Vulnerabilities, Auth, OWASP, Input Validation |
| Emma ⚡ | Latency, N+1 Queries, Caching, Memory Leaks |
| Sam 🎨 | User Flows, States, Feedback, Mobile UX |
| David 🔀 | Architecture, Microservices, Load Balancing |
| Max 🔧 | SOLID, Code Smells, Tech Debt, Refactoring |
| Luna ♿ | WCAG 2.1, Screen Reader, Keyboard, Contrast |
| Tom 💰 | Cloud Costs, FinOps, Right-sizing, Optimization |
| Nina 🎯 | Priority Matrix, Risk Assessment, Go/No-Go |
| Leo 📚 | README, API Docs, Comments, Onboarding |
| Ava 💡 | Emerging Tech, Alternatives, Future-proofing |

## Optional Parameters

- **--compact**: Ultra-compact single-line output
- **--guide**: Build & Workflow Guide only
- **--agents**: Agent Specializations only

## Example Output

For `/paf-quickref`:

Display the complete Quick Reference Card with all sections.

For `/paf-quickref --compact`:

```
PAF: /paf-cto "<req>" [--build=quick|standard|comprehensive] [--workflow=X] | /paf-fix | /paf-validate | /paf-help
```
