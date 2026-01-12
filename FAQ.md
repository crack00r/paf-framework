# PAF Framework - Frequently Asked Questions

## General

### What is PAF?

PAF (Perspective Agent Framework) is a multi-agent orchestration system for Claude AI that enables comprehensive code reviews from 10 different expert perspectives simultaneously.

### Who is PAF for?

- **Developers** who want thorough code reviews
- **Teams** that need consistent review quality
- **Enterprises** that require audit-grade analysis
- **Solo developers** who lack senior reviewers

### What makes PAF different from normal code reviews?

PAF delivers 10 specialized perspectives in parallel:
- A security expert finds vulnerabilities
- A performance engineer identifies bottlenecks
- A UX designer evaluates usability
- ...and 7 more specialists

All work simultaneously and deliver insights that would take a single reviewer hours.

---

## Prerequisites

### What do I need to use PAF?

1. **Claude Code** installed (with Pro/Team subscription)
2. **Node.js v18+** for the plugin
3. ~50MB storage space

### Does PAF work with Claude.ai Free?

Limited. The integrated plugin requires Claude Pro/Team features for full multi-agent functionality.

### What is the nested-subagent plugin?

It's an integrated component of PAF that allows Claude to spawn sub-agents with unlimited nesting depth. Essential for PAF's hierarchical agent architecture.

Installation happens automatically with:
```bash
./install.sh
```

### Does PAF work on Windows/Mac/Linux?

Yes, PAF works on all platforms that support Claude Code:
- macOS
- Windows
- Linux

### What do I need for GitHub integration?

For full GitHub integration (`/paf-setup-github`), PAF requires:

1. **GitHub CLI installed:**
   ```bash
   # macOS
   brew install gh

   # Windows
   winget install GitHub.cli

   # Linux
   sudo apt install gh
   ```

2. **GitHub CLI authenticated:**
   ```bash
   gh auth login
   ```

3. **Extended permissions (if Projects don't work):**
   ```bash
   gh auth refresh -s project,repo,write:org
   ```

4. **Repository with write access** (admin rights for labels/projects)

---

## Usage

### How do I start a review?

Simply enter:
```
/paf-cto "Review my authentication implementation"
```

The CTO agent analyzes your request, selects appropriate agents, and orchestrates the review.

### What are build presets?

Build presets control depth and speed of analysis:

| Preset | Time | Agents | Suitable for |
|--------|------|--------|--------------|
| `quick` | 2-3 min | 5-8 | Quick checks, PRs |
| `standard` | 8-12 min | 15-20 | Normal reviews |
| `comprehensive` | 20-30 min | 30-38 | Audits, releases |

### How does semantic understanding work?

Claude understands your intention naturally from context:

- "quick check" → `quick` build
- "review this feature" → `standard` build
- "thorough security audit" → `comprehensive` build + `security-audit` workflow

No keyword matching needed - just describe what you need in natural language.

### Can I force a specific build/workflow?

Yes, with flags:
```
/paf-cto "Review this" --build=comprehensive
/paf-cto "Check security" --workflow=security-audit
/paf-cto "Full audit" --build=comprehensive --workflow=full-feature
```

### What is Autonomous Mode?

The `--autonomous` mode (short form: `--auto`) activates fully autonomous operation:

- **CTO decides everything** - No questions to the user
- **Works until finished product** - All phases from discovery to deployment
- **Spawns agents as needed** - Independently selects appropriate agents
- **Writes and implements code** - Complete implementation

```bash
# Fully autonomous feature development
/paf-cto "Build login system with OAuth" --autonomous

# Combined with build
/paf-cto "Complete enterprise app" --autonomous --build=comprehensive
```

**Note:** The CTO only orchestrates - implementation agents (Anna, Chris, etc.) write the code.

### How long does a review take?

- **Quick:** 2-3 minutes
- **Standard:** 8-12 minutes
- **Comprehensive:** 20-30 minutes

Actual time depends on code complexity and context size.

---

## Agents

### Can I customize agent behavior?

Yes! Each agent is defined in `~/.paf/agents/perspectives/`. You can:
- Change focus areas
- Adjust checklists
- Modify output formats
- Add domain-specific concerns

### Can I add new agents?

Yes! Create a new `.md` file in `agents/perspectives/` following the existing format. Then add the agent to:
- `config/builds.yaml` (which builds include it)
- `config/ai-success-profiles.yaml` (success metrics)
- Relevant workflow files

### What is George?

George is the aggregator agent. He:
- Collects findings from all perspective agents
- Deduplicates issues
- Creates prioritized summary
- Provides go/no-go recommendations

### Can agents communicate with each other?

Yes, via `COMMS.md`. Agents write their status and findings there, and the CTO monitors completion and blockers.

---

## Troubleshooting

### "Plugin not found" error

The plugin is not installed or configured. See [docs/PLUGIN_SETUP.md](docs/PLUGIN_SETUP.md).

### Agents don't spawn

1. Check plugin build: `ls ~/.paf/plugins/nested-subagent/mcp-server/dist/`
2. Verify MCP registration: `claude mcp list`
3. Restart Claude Code session

### Review takes too long

- `--build=quick` for faster results
- Check internet connection
- Large contexts slow down processing

### Inconsistent results

- Ensure code context is complete
- Use specific, clear requests
- `comprehensive` build for thorough analysis

### How do I reset PAF?

```bash
# Complete reset (removes all configs)
rm -rf ~/.paf

# Reinstall
git clone https://github.com/crack00r/paf-framework.git
cd paf-framework && ./install.sh

# Verify
bash ~/.paf/scripts/verify-paf.sh
```

---

## Customization

### Can I change the default language?

Yes, edit `config/preferences.yaml`:
```yaml
general:
  language: en  # or 'de'
```

### Can I change the default build?

Yes, edit `config/preferences.yaml`:
```yaml
build:
  default_build: quick  # or 'standard', 'comprehensive'
```

### Can I disable certain agents?

Yes, edit `config/builds.yaml` and add agents to the `excluded` list for each build preset.

### Can I create custom workflows?

Yes! Create a new `.yaml` and `.md` file in `workflows/`. Use existing workflows as templates.

---

## Enterprise

### Is PAF suitable for enterprise?

Yes, PAF is designed for enterprise:
- 10 professional perspectives
- Audit-grade comprehensive analysis
- Risk matrices and go/no-go recommendations
- Consistent, reproducible reviews

### Can PAF be used in CI/CD?

Yes, PAF can be used with Claude Code in headless mode (`claude -p`) in CI/CD pipelines:

```bash
# Example: PAF review in CI/CD
claude -p "Run PAF security audit on this PR" --output-format json
```

For advanced CI/CD integration, see Claude Code documentation.

### Is my code sent to external servers?

PAF runs locally with Claude. Your code is processed according to Anthropic's Privacy Policies. No additional external services are involved.

### Can I use PAF offline?

No, PAF requires Claude, which needs internet connectivity.

---

## Contributing

### How can I contribute?

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines. We welcome:
- Bug reports
- Feature requests
- New agent perspectives
- Workflow templates
- Documentation improvements

### Where do I report bugs?

Open an issue on GitHub with:
- PAF version
- Reproduction steps
- Expected vs. actual behavior
- Relevant logs

---

## More Questions?

- Check [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- Open a GitHub issue
- Join community discussions
