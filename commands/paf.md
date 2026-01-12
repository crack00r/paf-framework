---
name: paf
description: "PAF - Perspective Agent Framework: Multi-agent orchestration system with 38 specialized AI agents"
user-invocable: true
context: fork
model: claude-opus-4-5-20251101
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Task
  - WebFetch
  - Write
  - Edit
---

# PAF - Perspective Agent Framework

> **Agents:** 38 | **Architecture:** Full SDLC with GitHub Integration

## Quick Start

### Basic Usage

```
/paf-cto "Review my authentication implementation"
```

### With Build Preset

```
/paf-cto "Quick check" --build=quick           # 2-3 min, 5-8 agents
/paf-cto "Review feature" --build=standard     # 8-12 min, 15-20 agents
/paf-cto "Full audit" --build=comprehensive    # 20-30 min, all 38 agents
```

### With Specific Workflow

```
/paf-cto "Security review" --workflow=security-audit
/paf-cto "Performance check" --workflow=performance-review
/paf-cto "Full feature" --workflow=full-feature
```

## Build Presets

| Build | Time | Agents | Use Case |
|-------|------|--------|----------|
| `quick` | 2-3 min | 5-8 | PR reviews, quick checks |
| `standard` | 8-12 min | 15-20 | Feature reviews (default) |
| `comprehensive` | 20-30 min | 30-38 | Audits, major releases |

## The 38 Agents

### Orchestration (1)
- **CTO** - Central orchestrator, spawns and coordinates all agents

### Discovery (3)
- **Ben** - Data Analyst: Analytics, metrics, KPIs
- **Maya** - Product Manager: Requirements, user stories
- **Iris** - Innovation Scout: Tech trends, emerging solutions

### Planning (3)
- **Sophia** - Software Architect: System design, ADRs
- **Michael** - Tech Lead: Technical planning
- **Kai** - Project Manager: Timeline, resources

### Implementation (5)
- **Anna** - Senior Developer: Complex implementations
- **Chris** - Full-Stack Developer: Feature development
- **Dan** - Backend Developer: APIs, databases
- **Sarah** - Lead Implementer: Team coordination, full-stack
- **Tina** - QA Engineer: Testing, automation

### Review (4)
- **Rachel** - Code Review Lead: Code quality
- **Stan** - Standards Checker: Best practices
- **Scanner** - Security Scanner: Automated scanning
- **Perf** - Performance Analyzer: Benchmarks

### Deployment (3)
- **Tony** - DevOps Engineer: CI/CD, infrastructure
- **Rel** - Release Manager: Versioning
- **Miggy** - Migration Specialist: Data migrations

### Operations (3)
- **Inci** - Incident Manager: Root cause analysis
- **Monitor** - Monitoring Agent: Observability
- **Feedback** - Feedback Collector: User feedback

### Perspective Agents (10) - Cross-Cutting Reviewers

| Agent | Specialty | GitHub Prefix |
|-------|-----------|---------------|
| **Alex** | Security | SEC |
| **Emma** | Performance | PERF |
| **Sam** | UX | UX |
| **David** | Scalability | SCALE |
| **Max** | Maintainability | MAINT |
| **Luna** | Accessibility | A11Y |
| **Tom** | Cost | COST |
| **Nina** | Triage | TRIAGE |
| **Leo** | Documentation | DOC |
| **Ava** | Innovation | IDEA |

### Retrospective (3)
- **George** - Scrum Master: Summary reports
- **Otto** - Process Optimizer: Efficiency
- **Docu** - Documentation: Auto-generated docs

### Utility (3)
- **Gideon** - GitHub Setup: One-time configuration
- **Bug Fixer** - Auto-Fix: Build errors
- **Validator** - Verification: Build validation

## Available Workflows

| Workflow | Description | Teams Involved |
|----------|-------------|----------------|
| `perspective-review` | Multi-perspective code review | CTO + Perspectives + George |
| `security-audit` | Security deep dive | CTO + Alex + Scanner + Review Team |
| `performance-review` | Performance analysis | CTO + Emma + Perf + Implementation |
| `full-feature` | Complete feature development | All SDLC phases |
| `bugfix` | Bug investigation and fix | Discovery + Implementation + Review |
| `hotfix` | Emergency production fix | Implementation + Deployment + Ops |
| `retrospective` | Sprint retrospective | Retrospective Team + Perspectives |

## GitHub Integration

PAF automatically manages GitHub issues, labels, and project boards.

### First Run Bootstrap

On first run, CTO checks for `.paf/GITHUB_SYSTEM.md`:
- **Missing** -> Spawns **Gideon** (Setup Agent) to configure GitHub
- **Present** -> Proceeds with normal workflow

### Project Boards

| Board | Purpose |
|-------|---------|
| Sprint | Main development |
| Security | Security findings |
| Backlog | Feature ideas |
| Architecture | ADRs |
| Bug Tracker | Bugs, incidents |
| Tech Debt | Code quality |
| Release | Deployments |

## Utility Commands

| Command | Description |
|---------|-------------|
| `/paf-cto` | Main orchestrator command |
| `/paf-fix` | Auto-fix build errors |
| `/paf-validate` | Build verification |
| `/paf-status` | Show project status |
| `/paf-init` | Initialize PAF in project |
| `/paf-setup-github` | Setup GitHub integration |
| `/paf-help` | PAF help system |
| `/paf-quickref` | Quick reference card |

## Required Plugin

PAF requires the **nested-subagent** MCP plugin for hierarchical agent spawning.

```bash
# Verify installation
bash ~/.paf/scripts/verify-paf.sh
```

Expected: 38 agents verified
