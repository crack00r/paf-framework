# PAF GitHub Integration

> Guide for integrating PAF with GitHub Projects

---

## Prerequisites

### 1. Install GitHub CLI

```bash
# macOS
brew install gh

# After installation: Authenticate
gh auth login
```

### 2. Check if authenticated

```bash
gh auth status
```

---

## Automatic Setup with `/paf-init`

During initialization, PAF automatically creates:

### GitHub Labels

```bash
gh label create "🤖 agent" --color "7057ff" --description "Agent-generated"
gh label create "🔬 discovery" --color "0e8a16" --description "Discovery Phase"
gh label create "📋 planning" --color "1d76db" --description "Planning Phase"
gh label create "🛠️ implementation" --color "fbca04" --description "Implementation"
gh label create "👀 review" --color "d93f0b" --description "Review Phase"
gh label create "🚀 deployment" --color "0052cc" --description "Deployment"
gh label create "📈 operations" --color "006b75" --description "Operations"
gh label create "📊 retrospective" --color "5319e7" --description "Retrospective"
gh label create "🚨 blocker" --color "b60205" --description "Blocker"
```

---

## Agents Use GitHub

### Create Issues (Agent Findings)

```bash
gh issue create \
  --title "[SEC-001] Token length too short" \
  --body "## Finding\nToken uses only 128-bit.\n\n## Recommendation\nUse 256-bit.\n\n## Agent\nAlex (Security)" \
  --label "🤖 agent,🚨 blocker"
```

### Create PRs

```bash
gh pr create \
  --title "feat: Increase token to 256-bit" \
  --body "Fixes #123" \
  --label "🛠️ implementation"
```

---

## Collect Metrics

George automatically collects:

```bash
# Open issues
gh issue list --state open --json number | jq length

# Merged PRs this week
gh pr list --state merged --search "merged:>$(date -v-7d +%Y-%m-%d)" --json number | jq length

# Blockers
gh issue list --label "🚨 blocker" --state open
```

---

## Best Practices

1. **One issue per finding**
2. **Use labels consistently**
3. **COMMS.md is master** - GitHub is sync
4. **Link PRs to issues** - "Fixes #123"
