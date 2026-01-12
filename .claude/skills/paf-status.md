---
name: paf-status
description: "PAF Status - Shows current project status"
user-invocable: true
context: fork
model: claude-opus-4-5-20251101
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
---

# /paf-status - PAF Project Status Command

> Shows the current status of the project and PAF integration.

## Usage

```
/paf-status [section]
```

## Parameters

| Parameter | Description | Values |
|-----------|-------------|--------|
| `[section]` | Section (optional) | agents, github, build, all |

## Examples

```bash
# Full status (Default)
/paf-status

# Only agent status
/paf-status agents

# Only GitHub status
/paf-status github

# Only build status
/paf-status build
```

## Command Definition

```
You are a status reporter for the PAF Framework.

## Your Task

Collect and present the current project status.

## Section: {SECTION or "all"}

## Collect Status

### 1. PAF Installation
- Check if ~/.paf/ exists
- Check VERSION file
- Count available agents

### 2. GitHub Integration
- Check if .paf/GITHUB_SYSTEM.md exists
- Count labels (gh label list)
- Count project boards (gh project list)
- Show open issues (gh issue list)

### 3. Build Status
- Git status (changes?)
- Last commit
- Branch info
- npm/package.json present?

### 4. Agent Status
- Read .paf/COMMS.md
- Show status of each agent
- Highlight active agents

## Output Format

╔══════════════════════════════════════════════════════════════╗
║  📊 PAF PROJECT STATUS                                        ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  📁 PROJECT                                                  ║
║     Name:     {project-name}                                 ║
║     Path:     {current-path}                                 ║
║     Branch:   {current-branch}                               ║
║     Status:   {clean/modified}                               ║
║                                                              ║
║  🤖 PAF FRAMEWORK                                            ║
║     Version:  (dynamic from VERSION file)                    ║
║     Agents:   38 available                                   ║
║     Plugin:   nested-subagent ✅                             ║
║                                                              ║
║  🐙 GITHUB INTEGRATION                                       ║
║     Status:   ✅ Configured / ⚠️ Not set up                  ║
║     Labels:   XX present                                     ║
║     Boards:   X active                                       ║
║     Issues:   X open                                         ║
║                                                              ║
║  🔧 BUILD STATUS                                             ║
║     TypeScript: ✅ / ❌                                       ║
║     Tests:      ✅ / ❌                                       ║
║     Last Build: {timestamp}                                  ║
║                                                              ║
║  👥 ACTIVE AGENTS                                            ║
║     {agent}: {status}                                        ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

## Quick Checks

```bash
# PAF Version
cat ~/.paf/VERSION

# Agent Count
ls ~/.paf/agents/**/*.md | wc -l

# GitHub Status
gh repo view --json name,owner

# Git Status
git status --short
```

## Related Commands

| Command | Description |
|---------|-------------|
| `/paf-cto` | CTO Orchestrator |
| `/paf-fix` | Auto-fix Errors |
| `/paf-validate` | Build Verification |
| `/paf-help` | Interactive Help |
