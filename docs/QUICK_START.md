# PAF Framework - Quick Start Guide

Get started with PAF in 5 minutes.

## ⚡ TL;DR

```bash
# Install
cp -R paf-framework ~/.paf

# Verify
bash ~/.paf/scripts/verify-paf.sh

# Use (in Claude)
/paf-cto "Review my code"
```

## 🎯 Your First Review

### 🐙 First Run: GitHub Setup

On **first run**, PAF automatically sets up GitHub integration:

```
/paf-cto "Review my code"

⚙️ Setting up GitHub integration (one-time)...
→ Gideon spawned → Creates labels, boards, templates
→ Setup complete → Normal review starts
```

This happens **once per repository**. After that, agents can create GitHub Issues for their findings.

### 1. Simple Review

```
/paf-cto "Review my authentication implementation"
```

PAF will:
1. Analyze your request
2. Select appropriate agents
3. Run parallel reviews
4. Aggregate and present findings

### 2. Quick Check (2-3 minutes)

```
/paf-cto "Quick security check" --build=quick
```

Uses 5-8 agents for fast feedback.

### 3. Deep Audit (20-30 minutes)

```
/paf-cto "Complete audit before release" --build=comprehensive
```

Uses up to 38 agents (all 10 perspectives + SDLC teams) for thorough analysis.

## 📊 Understanding Build Presets

| Preset | Time | When to use |
|--------|------|-------------|
| `quick` | 2-3 min | PR reviews, quick checks |
| `standard` | 8-12 min | Feature reviews (default) |
| `comprehensive` | 20-30 min | Releases, audits |

## 🔄 Common Workflows

### Security Review

```
/paf-cto "Security audit of the API" --workflow=security-audit
```

Lead: Alex 🔒 (Security)

### Performance Review

```
/paf-cto "Performance analysis" --workflow=performance-review
```

Lead: Emma ⚡ (Performance)

### Full Multi-Perspective

```
/paf-cto "Complete review" --workflow=full-feature
```

All 10 perspectives + aggregation.

## 🛠️ Utility Commands

### Fix Build Errors

```
/paf-fix                 # Auto-fix all
/paf-fix typescript      # TypeScript only
/paf-fix lint            # ESLint only
```

### Validate Build

```
/paf-validate            # Full validation
/paf-validate quick      # Quick check
```

### Get Help

```
/paf-help               # All commands
/paf-help cto           # CTO command help
/paf-quickref           # Quick reference
```

## 👥 Meet the Agents

| Agent | Focus | Finds |
|-------|-------|-------|
| Alex 🔒 | Security | Vulnerabilities, auth issues |
| Emma ⚡ | Performance | N+1 queries, bottlenecks |
| Sam 🎨 | UX | Usability issues, bad flows |
| David 🔀 | Scalability | Architecture problems |
| Max 🔧 | Maintainability | Code smells, tech debt |
| Luna ♿ | Accessibility | WCAG violations |
| Tom 💰 | Cost | Cloud cost issues |
| Nina 🎯 | Triage | Prioritizes all findings |
| Leo 📚 | Documentation | Missing/poor docs |
| Ava 💡 | Innovation | Better alternatives |

## 💡 Pro Tips

### 1. GitHub Issues

PAF agents create GitHub Issues for findings:

```markdown
[SEC-001] SQL Injection in login.ts
[PERF-003] N+1 Query in user list
[A11Y-002] Missing alt text on images
```

Issues are automatically:
- Labeled by agent and priority
- Added to project boards
- Linked to the review

### 2. Use Semantic Understanding

Don't always specify `--build`. Claude understands your intent:

```
"quick look" → quick
"review this" → standard
"deep audit" → comprehensive
```

Just describe what you need in natural language.

### 3. Be Specific

More context = better reviews:

```
❌ "Review this"
✅ "Review the auth flow in /src/auth, focus on token security"
```

### 4. Use Workflows for Focus

When you know what you need:

```
/paf-cto "Security audit" --workflow=security-audit
```

### 5. Chain Commands

Before committing:
```
/paf-fix
/paf-validate quick
/paf-cto "Quick review" --build=quick
```

## 📖 Example Output

### Quick Build Output

```markdown
## Quick Review Summary

**Score:** 7/10 | **Issues:** 1 Critical, 2 High

**Top Issues:**
1. 🔒 SQL Injection in user query (Critical)
2. ⚡ Missing index on users.email (High)
3. 🔧 Duplicated code in auth handlers (High)

**Immediate Actions:**
- Parameterize SQL queries
- Add database index

**Verdict:** REVIEW REQUIRED
```

### Standard Build Output

Includes:
- Executive Summary
- Findings by perspective
- Risk assessment
- Prioritized recommendations
- Action items

## 🚀 Next Steps

1. Try different build presets
2. Explore specific workflows
3. Customize settings in `config/preferences.yaml`
4. Add custom agents (see CONTRIBUTING.md)

## ❓ Need Help?

- `/paf-help` - Interactive help
- [FAQ.md](../FAQ.md) - Frequently asked questions
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Problem solving
