# 🏭 PAF - Perspective Agent Framework

> **Version:** (see VERSION)
> **Model:** claude-sonnet-4-20250514 / claude-opus-4-5-20251101
> **Agents:** 38 specialized AI agents across 8 categories
> **Architecture:** Full SDLC coverage with nested hierarchies
> **Updated:** 2026-01-12

---

## 🆕 What's New?

| Feature | Description |
|---------|-------------|
| **🐙 GitHub Integration** | Automatic issue tracking, project boards, labels |
| **Gideon Setup Agent** | One-time GitHub configuration per repository |
| **Issue Prefixes** | SEC, PERF, UX, SCALE, MAINT, A11Y, COST, TRIAGE, DOC, IDEA per agent |
| **7 Project Boards** | Sprint, Security, Backlog, Architecture, Bug, Tech Debt, Release |
| **91 Labels** | Type, priority, phase, agent, category labels |
| **GitHub Actions** | Auto-triage, stale issues, sprint metrics |

## 🆕 What's New in v4.4?

| Feature | Description |
|---------|-------------|
| **Option B: Flat Implementation** | CTO spawns all Implementation Agents directly, Sarah coordinates only |
| **Config Consistency** | All configs now have consistent schema versions and last_updated fields |
| **Version Alignment** | All prompts and templates aligned to v4.4 |

## 🆕 What's New in v4.2?

| Feature | Description |
|---------|-------------|
| **Mandatory Gideon Bootstrap** | CTO blocks until GITHUB_SYSTEM.md exists - Gideon runs first |
| **GitHub Integration in Prologue** | Each agent receives their prefix, label, and board in spawn prompt |
| **TaskList Auto-Cleanup** | Automatic purge of tasks older than 24h, filtered display |
| **MCP Debug Logging** | Comprehensive diagnostics to /tmp/paf-nested-subagent-debug.log |
| **20-Minute Timeout** | Increased from 10 minutes for complex tasks |
| **Plugin Cache Clearing** | Prevents stale code after updates |

### v4.0 Features

| Feature | Description |
|---------|-------------|
| **Build Presets** | quick (2-3 min), standard (8-12 min), comprehensive (20-30 min) |
| **Semantic Understanding** | Automatic workflow and build selection from natural language |
| **38 Enterprise Agents** | Full SDLC coverage with team hierarchies |
| **Nested Subagent Plugin** | Unlimited agent spawning depth for complex workflows |
| **10 Perspective Agents** | Cross-cutting reviewers (Security, Performance, UX, etc.) |
| **AI Success Profiles** | Agent performance metrics for optimization |

---

## 🏗️ Enterprise Architecture

PAF implements a complete Software Development Life Cycle (SDLC) with hierarchical agent teams:

```
                              ┌─────────────┐
                              │    CTO      │
                              │ Orchestrator│
                              └──────┬──────┘
                                     │
        ┌────────────┬───────────┬───┴───┬───────────┬────────────┐
        ▼            ▼           ▼       ▼           ▼            ▼
   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
   │Discovery│ │Planning │ │  Impl   │ │ Review  │ │ Deploy  │ │  Ops    │
   │  Team   │ │  Team   │ │  Team   │ │  Team   │ │  Team   │ │  Team   │
   └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘
        │           │           │           │           │           │
   ┌────┴────┐ ┌────┴────┐ ┌────┴────┐ ┌────┴────┐ ┌────┴────┐ ┌────┴────┐
   │Ben      │ │Sophia   │ │Anna     │ │Rachel   │ │Tony     │ │Inci     │
   │Maya     │ │Michael  │ │Chris    │ │Stan     │ │Rel      │ │Monitor  │
   │Iris     │ │Kai      │ │Dan      │ │Scanner  │ │Miggy    │ │Feedback │
   └─────────┘ └─────────┘ │Sarah    │ │Perf     │ └─────────┘ └─────────┘
                          │Tina     │ └─────────┘
                          └─────────┘
                                │
                    ┌───────────┴───────────┐
                    ▼                       ▼
            ┌─────────────┐         ┌─────────────┐
            │ Perspective │         │Retrospective│
            │  Agents(10) │         │   Team      │
            └─────────────┘         └─────────────┘
```

---

## 👥 All 38 Agents

### 🎪 Orchestration (1)
| Agent | Role | Description |
|-------|------|-------------|
| **CTO** | Chief Technology Officer | Central orchestrator, spawns and coordinates all agents |

### 🔍 Discovery Phase (3)
| Agent | Role | Focus |
|-------|------|-------|
| **Ben** | Data Analyst | Analytics, metrics, KPIs, data patterns |
| **Maya** | Product Manager | Requirements, user stories, prioritization |
| **Iris** | Innovation Scout | Tech trends, emerging solutions, alternatives |

### 📐 Planning Phase (3)
| Agent | Role | Focus |
|-------|------|-------|
| **Sophia** | Software Architect | System design, ADRs, architecture patterns |
| **Michael** | Tech Lead | Technical planning, task breakdown |
| **Kai** | Project Manager | Timeline, resources, dependencies |

### 💻 Implementation Phase (5)
| Agent | Role | Focus |
|-------|------|-------|
| **Anna** | Senior Developer | Complex implementations, code standards |
| **Chris** | Full-Stack Developer | Feature development, integration |
| **Dan** | Backend Developer | APIs, databases, services |
| **Sarah** | Lead Implementer | Full-stack development, team coordination |
| **Tina** | QA Engineer | Testing, test automation, quality |

### 🔎 Review Phase (4)
| Agent | Role | Focus |
|-------|------|-------|
| **Rachel** | Code Review Lead | Code quality, review coordination |
| **Stan** | Standards Checker | Coding standards, best practices |
| **Scanner** | Security Scanner | Automated security scanning |
| **Perf** | Performance Analyzer | Performance testing, benchmarks |

### 🚀 Deployment Phase (3)
| Agent | Role | Focus |
|-------|------|-------|
| **Tony** | DevOps Engineer | CI/CD, infrastructure, automation |
| **Rel** | Release Manager | Release coordination, versioning |
| **Miggy** | Migration Specialist | Database migrations, data integrity |

### 📡 Operations Phase (3)
| Agent | Role | Focus |
|-------|------|-------|
| **Inci** | Incident Manager | Incident response, root cause analysis |
| **Monitor** | Monitoring Agent | System health, alerting, observability |
| **Feedback** | Feedback Collector | User feedback, feature requests |

### 🎭 Perspective Agents (10) - Cross-Cutting Reviewers
| Agent | Emoji | Specialty | Focus |
|-------|-------|-----------|-------|
| **Alex** | 🔒 | Security | OWASP, Auth, Vulnerabilities, Input Validation |
| **Emma** | ⚡ | Performance | Latency, N+1 Queries, Caching, Memory |
| **Sam** | 🎨 | UX | Usability, User Flows, States, Feedback |
| **David** | 🔀 | Scalability | Architecture, Load Balancing, Microservices |
| **Max** | 🔧 | Maintainability | SOLID, Code Quality, Tech Debt, Refactoring |
| **Luna** | ♿ | Accessibility | WCAG 2.1, Screen Reader, Keyboard Navigation |
| **Tom** | 💰 | Cost | FinOps, Cloud Costs, Resource Optimization |
| **Nina** | 🎯 | Triage | Prioritization, Risk Assessment, Go/No-Go |
| **Leo** | 📚 | Documentation | README, API Docs, Code Comments |
| **Ava** | 💡 | Innovation | Emerging Tech, Alternatives, Future-proofing |

### 📊 Retrospective & Aggregation (3)
| Agent | Role | Focus |
|-------|------|-------|
| **George** | Scrum Master | Findings aggregation, summary reports |
| **Otto** | Process Optimizer | Process improvements, efficiency |
| **Docu** | Documentation | Auto-generated documentation |

### 🔧 Utility Agents (3)
| Agent | Role | Focus |
|-------|------|-------|
| **Gideon** 🛠️ | GitHub Setup | One-time GitHub configuration per repository |
| **Bug Fixer** 🐛 | Auto-Fix | Automatically fixes build errors |
| **Validator** ✅ | Verification | Validates builds and configurations |

---

## 🚀 Quick Start

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

---

## ⚡ Build Presets

| Build | Time | Agents | Use Case |
|-------|------|--------|----------|
| `quick` | 2-3 min | 5-8 | PR reviews, quick checks |
| `standard` | 8-12 min | 15-20 | Feature reviews (default) |
| `comprehensive` | 20-30 min | 30-38 | Audits, major releases |

### Agent Selection by Build

**Quick Build:**
- CTO + 3-5 Perspective Agents + Nina (Triage)

**Standard Build:**
- CTO + All Perspective Agents + Review Team + George

**Comprehensive Build:**
- All 38 agents across all phases

---

## 📊 Available Workflows

| Workflow | Description | Teams Involved |
|----------|-------------|----------------|
| `perspective-review` | Multi-perspective code review | CTO + Perspectives + George |
| `security-audit` | Security deep dive | CTO + Alex + Scanner + Review Team |
| `performance-review` | Performance analysis | CTO + Emma + Perf + Implementation |
| `full-feature` | Complete feature development | All SDLC phases |
| `bugfix` | Bug investigation and fix | Discovery + Implementation + Review |
| `hotfix` | Emergency production fix | Implementation + Deployment + Ops |
| `retrospective` | Sprint retrospective | Retrospective Team + Perspectives |

---

## 🔧 Utility Commands

| Command | Description |
|---------|-------------|
| `/paf-cto` | Main orchestrator command |
| `/paf-fix` | Auto-fix build errors |
| `/paf-validate` | Build verification |
| `/paf-status` | Show project status |
| `/paf-help` | Interactive help system |
| `/paf-quickref` | Quick reference card |

---

## 📁 Directory Structure

```
~/.paf/
├── agents/
│   ├── orchestration/      # CTO
│   ├── discovery/          # Ben, Maya, Iris
│   ├── planning/           # Sophia, Michael, Kai
│   ├── implementation/     # Anna, Chris, Dan, Sarah, Tina
│   ├── review/             # Rachel, Stan, Scanner, Perf
│   ├── deployment/         # Tony, Rel, Miggy
│   ├── operations/         # Inci, Monitor, Feedback
│   ├── perspectives/       # 10 cross-cutting reviewers
│   ├── retrospective/      # George, Otto, Docu
│   └── utility/            # Gideon, Bug Fixer, Validator
├── config/
│   ├── builds.yaml         # Build presets
│   ├── signals.yaml        # Signal detection
│   ├── preferences.yaml    # User settings
│   └── ai-success-profiles.yaml
├── workflows/              # Workflow definitions
├── commands/               # Command definitions
└── scripts/verify-paf.sh   # Installation check
```

---

## 🔌 Required Plugin

PAF requires the **nested-subagent** MCP plugin for hierarchical agent spawning.

See [docs/PLUGIN_SETUP.md](docs/PLUGIN_SETUP.md) for installation.

---

## ✅ Verify Installation

```bash
bash ~/.paf/scripts/verify-paf.sh
```

Expected: 38 agents verified ✅

---

## 🐙 GitHub Integration

PAF includes full GitHub integration for issue tracking and project management.

### First Run Setup

When you first run `/paf-cto`, the system checks for `.paf/GITHUB_SYSTEM.md`.
If missing, **Gideon** (Setup Agent) automatically:

- Creates 91 Labels (type, priority, agent, category)
- Creates 7 project boards (Sprint, Security, Backlog, etc.)
- Copies issue templates to `.github/ISSUE_TEMPLATE/`
- Sets up GitHub Actions for automation
- Generates `.paf/GITHUB_SYSTEM.md` with all IDs

### What Agents Do

Every agent that finds issues:
1. Creates a GitHub Issue with proper labels
2. Adds it to the appropriate project board
3. Sets priority and category

### Project Boards

| Board | Purpose | Agents |
|-------|---------|--------|
| 📋 Sprint | Main development | Most agents |
| 🔒 Security | Security findings | Alex, Scanner |
| 📊 Backlog | Feature ideas | Maya, Iris, Ava |
| 🏗️ Architecture | ADRs | Sophia, David |
| 🐛 Bug Tracker | Bugs, incidents | Tina, Inci, Feedback |
| 🔧 Tech Debt | Code quality | Max, Otto, Stan |
| 🚀 Release | Deployments | Tony, Rel |

### Manual Setup

If automatic setup fails:
```bash
# Check GitHub CLI
gh auth status

# Manual setup
/paf-setup-github
```

See [docs/GITHUB_WORKFLOW.md](docs/GITHUB_WORKFLOW.md) for details.

---

## 📄 License

MIT License - Free for commercial and personal use.
