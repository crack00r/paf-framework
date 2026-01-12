---
name: paf-help
description: "PAF Help - Interactive help system for all PAF Commands"
user-invocable: true
context: fork
model: claude-opus-4-5-20251101
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
---

# /paf-help - PAF Help System

> Interactive help system for all PAF commands and features.

## Usage

```
/paf-help [topic]
```

## Parameters

| Parameter | Description | Values |
|-----------|-------------|--------|
| `[topic]` | Topic (optional) | commands, agents, workflows, builds, all |

## Examples

```bash
# Show all commands (Default)
/paf-help

# Help on agents
/paf-help agents

# Help on workflows
/paf-help workflows

# Help on build presets
/paf-help builds

# Complete help
/paf-help all
```

## Command Definition

```
You are the PAF help system.

## Your Task

Show context-specific help for the PAF Framework.

## Topic: {TOPIC or "commands"}

## Commands Help (Default)

╔══════════════════════════════════════════════════════════════════╗
║  🆘 PAF FRAMEWORK - COMMAND HELP                                 ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  🎯 ORCHESTRATION                                                ║
║     /paf-cto              Start CTO Orchestrator                 ║
║     /paf-cto --build=X    With build preset                      ║
║     /paf-cto --workflow=Y With specific workflow                 ║
║     /paf-cto --autonomous Fully autonomous mode                  ║
║                                                                  ║
║  📊 WORKFLOWS (7 available)                                      ║
║     perspective-review    Multi-perspective review               ║
║     security-audit        Security deep dive (Alex 🔒)           ║
║     performance-review    Performance analysis (Emma ⚡)          ║
║     full-feature          All perspectives                       ║
║     bugfix                Bug investigation                      ║
║     hotfix                Emergency fix                          ║
║     retrospective         Sprint retrospective                   ║
║                                                                  ║
║  🔧 UTILITIES                                                    ║
║     /paf-init             Initialize project                     ║
║     /paf-fix [type]       Auto-fix errors                        ║
║     /paf-validate [mode]  Build verification                     ║
║     /paf-status           Project status                         ║
║     /paf-setup-github     GitHub integration                     ║
║                                                                  ║
║  📚 REFERENCE                                                    ║
║     /paf-help             This help system                       ║
║     /paf-quickref         Quick reference card                   ║
║                                                                  ║
║  ⚡ BUILD PRESETS                                                 ║
║     quick                 2-3 min, 5-8 Agents                    ║
║     standard (default)    8-12 min, 15-20 Agents                 ║
║     comprehensive         20-30 min, 30-38 Agents                ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

## Agents Help

╔══════════════════════════════════════════════════════════════════╗
║  👥 PAF AGENTS (38)                                              ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  🎪 ORCHESTRATION (1)                                            ║
║     CTO - Chief Technology Officer (Orchestrator)                ║
║                                                                  ║
║  🔍 DISCOVERY (3)                                                ║
║     Ben - Data Analyst | Maya - Product Manager                  ║
║     Iris - Innovation Scout                                      ║
║                                                                  ║
║  📋 PLANNING (3)                                                 ║
║     Sophia - Software Architect (Lead)                           ║
║     Michael - Tech Lead | Kai - Project Manager                  ║
║                                                                  ║
║  💻 IMPLEMENTATION (5)                                           ║
║     Sarah - Lead Developer | Anna - Senior Developer             ║
║     Chris - Frontend | Dan - Backend | Tina - QA                 ║
║                                                                  ║
║  🔍 REVIEW (4)                                                   ║
║     Rachel - Code Review Lead | Stan - Standards                 ║
║     Scanner - Security | Perf - Performance                      ║
║                                                                  ║
║  🚀 DEPLOYMENT (3)                                               ║
║     Tony - DevOps Lead | Rel - Release Manager                   ║
║     Miggy - Migration Specialist                                 ║
║                                                                  ║
║  🔧 OPERATIONS (3)                                               ║
║     Inci - Incident Manager | Monitor - Monitoring               ║
║     Feedback - User Feedback                                     ║
║                                                                  ║
║  👁️ PERSPECTIVES (10)                                            ║
║     Alex 🔒 Security    | Emma ⚡ Performance                     ║
║     Sam 🎨 UX           | David 🔀 Scalability                   ║
║     Max 🔧 Maintainability | Luna ♿ Accessibility                ║
║     Tom 💰 Cost         | Nina 🎯 Triage                         ║
║     Leo 📚 Documentation | Ava 💡 Innovation                     ║
║                                                                  ║
║  📊 RETROSPECTIVE (3)                                            ║
║     George - Scrum Master | Otto - Process Optimizer             ║
║     Docu - Documentation                                         ║
║                                                                  ║
║  🛠️ UTILITY (3)                                                  ║
║     Bug-Fixer | Validator | Gideon (Setup)                       ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

## Workflows Help

╔══════════════════════════════════════════════════════════════════╗
║  📊 PAF WORKFLOWS                                                ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  perspective-review (Default)                                    ║
║     Multi-perspective code review with 10 agents                 ║
║                                                                  ║
║  security-audit                                                  ║
║     Security-focused deep dive                                   ║
║     Lead: Alex 🔒                                                ║
║                                                                  ║
║  performance-review                                              ║
║     Performance-focused analysis                                 ║
║     Lead: Emma ⚡                                                ║
║                                                                  ║
║  full-feature                                                    ║
║     Complete feature development cycle                           ║
║     All teams                                                   ║
║                                                                  ║
║  bugfix                                                          ║
║     Bug investigation and fix                                    ║
║                                                                  ║
║  hotfix                                                          ║
║     Emergency production fix                                     ║
║                                                                  ║
║  retrospective                                                   ║
║     Sprint retrospective                                         ║
║     Lead: George                                                ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝

## Builds Help

╔══════════════════════════════════════════════════════════════════╗
║  ⚡ PAF BUILD PRESETS                                             ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  quick                                                           ║
║  ─────────────────────────────────────────────────────────────── ║
║  ⏱️  Time:    2-3 Minutes                                        ║
║  👥 Agents:  5-8 (Core Perspectives)                             ║
║  📊 Depth:   Superficial, only critical issues                   ║
║  📝 Output:  Compact summary (~500 words)                        ║
║  🎯 Use:     PR reviews, quick checks                            ║
║                                                                  ║
║  standard (Default)                                              ║
║  ─────────────────────────────────────────────────────────────── ║
║  ⏱️  Time:    8-12 Minutes                                       ║
║  👥 Agents:  15-20 (Core + Extended)                             ║
║  📊 Depth:   Thorough, all important areas                       ║
║  📝 Output:  Structured report (~2000 words)                     ║
║  🎯 Use:     Feature reviews, normal analysis                    ║
║                                                                  ║
║  comprehensive                                                   ║
║  ─────────────────────────────────────────────────────────────── ║
║  ⏱️  Time:    20-30 Minutes                                      ║
║  👥 Agents:  30-38 (All available)                               ║
║  📊 Depth:   Exhaustive, deep dive                               ║
║  📝 Output:  Enterprise report (~5000 words)                     ║
║  🎯 Use:     Audits, production releases                         ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

## Related Commands

| Command | Description |
|---------|-------------|
| `/paf-quickref` | Quick Reference Card |
| `/paf-cto` | CTO Orchestrator |
| `/paf-status` | Project Status |
