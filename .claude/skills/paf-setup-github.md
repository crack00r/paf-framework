---
name: paf-setup-github
description: "PAF Setup GitHub - Sets up GitHub Integration with Gideon Agent"
user-invocable: true
context: fork
model: claude-opus-4-5-20251101
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Task
  - Write
  - Edit
---

# /paf-setup-github - PAF GitHub Setup Command

> Sets up the complete GitHub integration for the repository.

## Usage

```
/paf-setup-github
```

## Description

Starts the **Gideon** Setup Agent, which sets up the complete GitHub infrastructure.

## What will be set up?

### 1. Labels (91 items)

| Category | Count | Examples |
|----------|-------|-----------|
| Type | 9 | bug, feature, finding, task, adr, incident, epic |
| Priority | 4 | P0 (Critical), P1 (High), P2 (Medium), P3 (Low) |
| Phase | 6 | discovery, planning, implementation, review, deployment, operations |
| Agent | 39 | 🔒 alex, ⚡ emma, 🎨 sam, 🎪 cto, 🤖 agent, etc. |
| Category | 15 | security, performance, ux, accessibility, architecture, etc. |
| Status | 7 | blocked, needs-review, ready, wontfix, duplicate, stale |
| Size | 5 | XS, S, M, L, XL |
| Labeler | 6 | api, frontend, backend, database, configuration, paf |

### 2. Project Boards (7 items)

| Board | Purpose |
|-------|---------|
| 📋 PAF Sprint | Current development |
| 🔒 PAF Security | Security findings |
| 📊 PAF Backlog | Feature ideas |
| 🏗️ PAF Architecture | ADRs |
| 🐛 PAF Bug Tracker | Bugs & Incidents |
| 🔧 PAF Tech Debt | Code quality |
| 🚀 PAF Release | Deployments |

### 3. Issue Templates

- Agent Finding
- Bug Report
- Feature Request
- Incident
- ADR (Architecture Decision Record)
- Task
- Retrospective

### 4. GitHub Actions (6 items)

| Action | Function |
|--------|----------|
| Auto-Triage | Automatic issue categorization |
| Auto-Label | Label suggestions |
| PR Checks | Build & test on PRs |
| Sprint Metrics | Weekly statistics |
| Release Notes | Automatic changelog |
| Stale Issues | Mark old issues |

### 5. Milestones

- Sprint 1
- Backlog
- Next Release

## Command Definition

```
You are the Gideon Setup Agent of the PAF Framework.

## Your Task

Set up the complete GitHub integration for this repository.

## Check prerequisites

1. GitHub CLI authenticated?
   gh auth status

2. Git repository initialized?
   git status

3. GitHub repository exists?
   gh repo view

## Execute setup

### 1. Create labels
Read ~/.paf/config/labels.yaml and create all labels:
for label in labels; do
  gh label create "$name" --color "$color" --description "$desc"
done

### 2. Create project boards
Read ~/.paf/config/projects.yaml and create all boards:
for project in projects; do
  gh project create --owner @me --title "$title"
done

### 3. Copy issue templates
cp -r ~/.paf/templates/issues/ .github/ISSUE_TEMPLATE/

### 4. Copy GitHub Actions
cp ~/.paf/templates/workflows/*.yml .github/workflows/

### 5. Create milestones
gh api repos/{owner}/{repo}/milestones --method POST -f title="Sprint 1"
gh api repos/{owner}/{repo}/milestones --method POST -f title="Backlog"
gh api repos/{owner}/{repo}/milestones --method POST -f title="Next Release"

### 6. Generate GITHUB_SYSTEM.md
Collect all IDs and URLs and write them to .paf/GITHUB_SYSTEM.md

## Output

After successful setup:
- ✅ XX labels created
- ✅ 7 project boards created
- ✅ Issue templates copied
- ✅ GitHub Actions copied
- ✅ 3 milestones created
- ✅ .paf/GITHUB_SYSTEM.md generated

GitHub integration fully set up!
```

## Prerequisites

```bash
# GitHub CLI installed and authenticated
gh auth status

# Git repository initialized
git status

# GitHub repository created
gh repo view

# Write permissions on repository
gh auth refresh -s project,repo,write:org
```

## Error Handling

| Error | Solution |
|-------|----------|
| "Not authenticated" | `gh auth login` |
| "Not a git repository" | `git init && gh repo create` |
| "Permission denied" | `gh auth refresh -s project,repo,write:org` |

## Note

Gideon is **only needed once** per repository. After successful setup, `.paf/GITHUB_SYSTEM.md` exists and the CTO will skip Gideon on future calls.

## Related Commands

| Command | Description |
|---------|-------------|
| `/paf-cto` | CTO Orchestrator |
| `/paf-status` | Project Status (incl. GitHub) |
| `/paf-init` | Initialize PAF in project |
