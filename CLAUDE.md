# CLAUDE.md - PAF Framework

This file provides context for Claude Code and AI assistants working with PAF.

## Project Overview

PAF (Perspective Agent Framework) is an enterprise-grade multi-agent orchestration system with **38 specialized AI agents** implementing a complete Software Development Life Cycle (SDLC) with full **GitHub Integration**.

## Architecture

```
                         ┌─────────────┐
                         │    CTO      │
                         │ Orchestrator│
                         └──────┬──────┘
                                │
   ┌──────────┬──────────┬──────┼──────┬──────────┬──────────┐
   ▼          ▼          ▼      ▼      ▼          ▼          ▼
Discovery  Planning  Implement Review  Deploy  Operations  Retro
  (3)        (3)       (5)     (4)     (3)       (3)        (3)
                                │
                    ┌───────────┴───────────┐
                    ▼                       ▼
             Perspectives              Utility
                (10)                    (3)
```

## The 38 Agents

### By Category

| Category | Count | Agents |
|----------|-------|--------|
| Orchestration | 1 | CTO |
| Discovery | 3 | Ben, Maya, Iris |
| Planning | 3 | Sophia, Michael, Kai |
| Implementation | 5 | Anna, Chris, Dan, Sarah, Tina |
| Review | 4 | Rachel, Stan, Scanner, Perf |
| Deployment | 3 | Tony, Rel, Miggy |
| Operations | 3 | Inci, Monitor, Feedback |
| Perspectives | 10 | Alex, Emma, Sam, David, Max, Luna, Tom, Nina, Leo, Ava |
| Retrospective | 3 | George, Otto, Docu |
| Utility | 3 | Bug-Fixer, Validator, **Gideon** |

### The 10 Perspectives (Cross-Cutting Reviewers)

| Agent | Emoji | Specialty | GitHub Prefix |
|-------|-------|-----------|---------------|
| alex | 🔒 | Security | SEC |
| emma | ⚡ | Performance | PERF |
| sam | 🎨 | UX | UX |
| david | 🔀 | Scalability | SCALE |
| max | 🔧 | Maintainability | MAINT |
| luna | ♿ | Accessibility | A11Y |
| tom | 💰 | Cost | COST |
| nina | 🎯 | Triage | TRIAGE |
| leo | 📚 | Documentation | DOC |
| ava | 💡 | Innovation | IDEA |

## 🐙 GitHub Integration

PAF automatically manages GitHub issues, labels, and project boards.

### First Run Bootstrap

On first run, CTO checks for `.paf/GITHUB_SYSTEM.md`:
- **Missing** → Spawns **Gideon** (Setup Agent) to configure GitHub
- **Present** → Proceeds with normal workflow

### What Gideon Sets Up

- **91 Labels** - Type, priority, phase, agent, category
- **7 Project Boards** - Sprint, Security, Backlog, Architecture, Bug, Tech Debt, Release
- **Issue Templates** - Agent Finding, Bug, Feature, Incident, ADR, Task, Retro, Config
- **GitHub Actions (6)** - Auto-triage, auto-label, PR checks, sprint metrics, release notes, stale issues

### Agent Issue Creation

Each agent creates GitHub issues with their prefix:
```bash
gh issue create --title "[SEC-001] Finding" --label "finding,🔒 alex,security"
```

## Key Files

| File | Purpose |
|------|---------|
| `agents/orchestration/cto.md` | Main orchestrator with bootstrap logic |
| `agents/utility/gideon.md` | GitHub Setup Agent (runs once) |
| `agents/perspectives/*.md` | 10 cross-cutting reviewers |
| `agents/[phase]/*.md` | SDLC phase agents |
| `config/builds.yaml` | Build preset definitions |
| `config/signals.yaml` | Build and workflow documentation |
| `config/labels.yaml` | GitHub label definitions |
| `config/projects.yaml` | GitHub project board definitions |
| `workflows/*.yaml` | Workflow definitions |
| `.paf/GITHUB_SYSTEM.md` | Generated per-repo with board IDs |

## Build Presets

| Build | Time | Agents | Use Case |
|-------|------|--------|----------|
| quick | 2-3 min | 5-8 | PR reviews |
| standard | 8-12 min | 15-20 | Feature reviews |
| comprehensive | 20-30 min | 30-38 | Audits |

## Common Tasks

### Adding a New Agent

1. Create `agents/[category]/newagent.md` using existing template
2. Add to `config/builds.yaml` in appropriate builds
3. Add to `config/ai-success-profiles.yaml`
4. Add COMMS.md section in `templates/COMMS.md`
5. Add spawn template in `agents/orchestration/spawn-templates.md`
6. Add GitHub prefix if agent creates findings

### Creating a Workflow

1. Create `workflows/new-workflow.yaml` defining phases
2. Add signal patterns to `config/signals.yaml`
3. Ensure all agents in workflow have spawn templates

### Agent Hierarchy (Spawning)

```
CTO (can spawn all)
 ├── Perspective Agents (10) - parallel review
 ├── Discovery Team (ben, maya, iris) - CTO spawns directly
 ├── Planning Team
 │    └── Sophia → can spawn: Michael, Kai
 ├── Implementation Team (sarah, chris, dan, anna, tina) - CTO spawns directly
 │    └── Sarah coordinates but does NOT spawn (flat structure for speed)
 ├── Review Team
 │    └── Rachel → can spawn: Stan, Scanner, Perf
 ├── Deployment Team
 │    └── Tony → can spawn: Miggy, Rel
 ├── Operations Team
 │    └── Inci → can spawn: Monitor, Feedback
 ├── Retrospective Team
 │    └── George → can spawn: Otto, Docu
 └── Utility (gideon, bug-fixer, validator)
```

## Communication

Agents communicate via `.paf/COMMS.md`:

```markdown
<!-- AGENT:ALEX:START -->
### Status: IN_PROGRESS
### Timestamp: [NOW]

**Task:** Security Review
**Findings:**
- ✅ OK: Authentication solid
- ❌ Critical: SQL injection in login.ts

### Status: COMPLETED
**Handoff:** @ORCHESTRATOR
<!-- AGENT:ALEX:END -->
```

### Status Values

| Status | Meaning |
|--------|---------|
| `IDLE` | Waiting |
| `IN_PROGRESS` | Working |
| `BLOCKED` | Needs input |
| `COMPLETED` | Done |
| `ERROR` | Failed |

## Plugin Dependency

Requires **nested-subagent** MCP plugin for hierarchical agent spawning.

## Testing

```bash
# Verify all agents
bash scripts/verify-paf.sh

# Quick test
/paf-cto "Quick test" --build=quick

# Full test with GitHub
/paf-cto "Full review" --build=comprehensive

# Manual GitHub setup
/paf-setup-github
```

## Code Conventions

- Agent names: lowercase (alex, emma, sophia)
- Emojis: consistent per agent
- COMMS.md sections: `<!-- AGENT:NAME:START/END -->`
- GitHub prefixes: UPPERCASE (SEC, PERF, UX)
- Configs reference agents by name

## Versioning

**Single Source of Truth:** `VERSION` file in repository root.

```
VERSION          # Contains: 4.4.0 (or current version)
```

### Rules

1. **Only update VERSION** - Never hardcode versions elsewhere
2. **Scripts read dynamically** - install.sh, update.sh read from VERSION
3. **Docker build** - Pass version as build arg: `docker build --build-arg PAF_VERSION=$(cat VERSION) .`
4. **CHANGELOG.md** - Only file with historical version references (intended)

### Version Check

CTO and other agents read version from `~/.paf/VERSION` (installed) or repo `VERSION` file.

### Updating Version

```bash
echo "4.4.0" > VERSION
# That's it - no other files need changing
```
