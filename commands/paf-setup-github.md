# /paf-setup-github

> Manual trigger for GitHub Infrastructure Setup

---

## Syntax

```
/paf-setup-github
```

---

## Description

Starts the **Gideon** Setup Agent, which sets up the complete GitHub integration for the current repository.

### What is set up?

1. **91 Labels**
   - Type (9): bug, feature, finding, task, adr, incident, epic, research, retrospective
   - Priority (4): P0, P1, P2, P3
   - Phase (6): discovery, planning, implementation, review, deployment, operations
   - Agent (39): 🔒 alex, ⚡ emma, 🎨 sam, etc. (all 38 agents + 🤖 agent)
   - Category (15): security, performance, ux, etc.
   - Status (7): blocked, needs-review, ready, etc.
   - Size (5): XS, S, M, L, XL
   - Labeler (6): api, frontend, backend, database, configuration, paf

2. **7 Project Boards**
   - 📋 PAF Sprint Board
   - 🔒 PAF Security Board
   - 📊 PAF Product Backlog
   - 🏗️ PAF Architecture
   - 🐛 PAF Bug Tracker
   - 🔧 PAF Tech Debt
   - 🚀 PAF Release Pipeline

3. **Issue Templates**
   - Agent Finding
   - Bug Report
   - Feature Request
   - Incident
   - ADR
   - Task
   - Retrospective

4. **GitHub Actions**
   - Auto-Triage
   - Auto-Label
   - Stale Issues
   - Sprint Metrics
   - Release Notes
   - PR Checks

5. **Milestones**
   - Sprint 1
   - Backlog
   - Next Release

6. **Documentation**
   - `.paf/GITHUB_SYSTEM.md` with all IDs

---

## When to use?

### Automatic
The CTO runs this setup automatically when no `.paf/GITHUB_SYSTEM.md` is found on the first `/paf-cto` call.

### Manual
Use `/paf-setup-github` when:
- The automatic setup has failed
- You want to run the setup again
- You want to configure an existing repository afterwards

---

## Prerequisites

1. **GitHub CLI installed and authenticated**
   ```bash
   gh auth status
   ```
   If not: `gh auth login`

2. **Git repository initialized**
   ```bash
   git status
   ```

3. **GitHub repository created**
   ```bash
   gh repo view
   ```

4. **Write permissions on repository**
   - Owner or Collaborator with write permissions

---

## Error Handling

### "GitHub CLI not authenticated"
```bash
gh auth login
```

### "No Git repository"
```bash
git init
gh repo create
```

### "No write permissions"
```bash
gh auth refresh -s project,repo,write:org
```
Or: Contact the repository owner

---

## Output

After successful setup, the following is created:

```
.paf/
└── GITHUB_SYSTEM.md    # Contains all Board IDs, URLs, etc.
```

This file is read by all agents to know:
- Which Project Boards exist
- What IDs the boards have
- Which prefix they should use
- Which labels are available

---

## Example

```
User: /paf-setup-github

CTO: Starting GitHub Setup with Gideon...

Gideon 🛠️:
✅ GitHub CLI authenticated
✅ Repository: your-username/your-project
✅ 91 labels created
✅ 7 Project Boards created
✅ Issue Templates copied
✅ GitHub Actions copied
✅ 3 Milestones created
✅ .paf/GITHUB_SYSTEM.md generated

GitHub Integration fully set up!
Details in .paf/GITHUB_SYSTEM.md
```

---

## Note

Gideon is **only needed once** per repository. After successful setup, it is never called again since `.paf/GITHUB_SYSTEM.md` exists.
