# PAF Configuration Reference

Complete reference for all PAF configuration files.

## 📁 Configuration Files

| File | Purpose |
|------|---------|
| `config/builds.yaml` | Build preset definitions |
| `config/signals.yaml` | Build and workflow documentation |
| `config/preferences.yaml` | User settings |
| `config/ai-success-profiles.yaml` | Agent performance metrics |

---

## builds.yaml

Defines the three build presets: quick, standard, comprehensive.

### Structure

```yaml
builds:
  quick:
    description: "Quick analysis"
    target_time: "2-3 minutes"
    target_agents: "5-8 agents"

    agents:
      core_required: [cto]
      always_included: [alex, max, nina, emma]
      conditionally_included:
        - agent: sam
          condition: "UI/UX/frontend mentioned"
        - agent: luna
          condition: "accessibility/a11y/wcag mentioned"
        - agent: david
          condition: "architecture/scalability mentioned"
      excluded: [tom, leo, ava, george, ben, maya, iris, sophia, michael, kai]

    stage_modes:
      discovery: skip
      perspectives: minimal
      aggregation: compressed
      handoff: skip
```

### Important Sections

| Section | Description |
|---------|-------------|
| `agents.core_required` | Always included (CTO) |
| `agents.always_included` | Standard agents for this build |
| `agents.conditionally_included` | Agents based on context |
| `agents.excluded` | Never used in this build |
| `stage_modes` | How each phase is executed |

### Stage Modes

The `stage_modes` values control how intensively each workflow phase is executed:

| Mode | Description | Usage |
|------|-------------|-------|
| `skip` | Phase is completely skipped | Quick builds: discovery, handoff |
| `minimal` | Only essential checks | Quick builds: perspectives |
| `compressed` | Shortened output, inline aggregation | Quick builds: aggregation |
| `standard` | Normal execution with all standard checks | Standard builds |
| `full` | Maximum depth, all features enabled | Comprehensive builds |

**Example configuration by build:**

```yaml
# Quick Build - Maximum speed
stage_modes:
  discovery: skip       # No discovery phase
  perspectives: minimal # Only core agents
  aggregation: compressed # Short summary
  handoff: skip         # No formal handoff

# Standard Build - Balanced
stage_modes:
  discovery: standard   # Normal analysis
  perspectives: full    # All perspectives
  aggregation: standard # Complete aggregation
  handoff: standard     # Formal handoff

# Comprehensive Build - Maximum depth
stage_modes:
  discovery: full       # Deep analysis
  planning: full        # Complete planning
  perspectives: full    # All perspectives with details
  review: full          # Thorough review
  aggregation: full     # Complete aggregation
  handoff: full         # Documented handoff
```

---

## signals.yaml

Documents available builds and workflows. Claude understands user intent semantically - no pattern matching required.

### Build Presets

```yaml
builds:
  quick:
    description: "Fast analysis (2-3 min)"
    when_to_use:
      - "Fast feedback needed"
      - "PR reviews"
      - "Urgent checks"
      - "Quick validation"

  standard:
    description: "Balanced analysis (8-12 min)"
    when_to_use:
      - "Normal code reviews"
      - "Feature development"
      - "General analysis"

  comprehensive:
    description: "Deep analysis (20-30 min)"
    when_to_use:
      - "Pre-release audits"
      - "Security assessments"
      - "Architecture reviews"
      - "Complete evaluations"
```

### Workflows

```yaml
workflows:
  security_audit:
    description: "Security-focused review"
    agents: [alex, scanner]
    use_cases:
      - "Security assessments"
      - "Vulnerability analysis"
      - "Auth flow reviews"

  performance_review:
    description: "Performance optimization"
    agents: [emma, perf]
    use_cases:
      - "Performance bottlenecks"
      - "Query optimization"
      - "Caching strategies"
```

Claude automatically understands user intent from natural language requests without keyword matching.

---

## preferences.yaml

User-specific settings.

```yaml
general:
  language: en              # en, de

build:
  default_build: standard   # quick, standard, comprehensive
  # semantic_understanding is always on - Claude interprets intent naturally

agents:
  max_parallel_agents: 4    # Max parallel agents (NOT higher - causes crashes!)
  default_timeout: 600      # Seconds per agent (10 minutes)

quality:
  auto_escalate_critical: true  # Escalate P0 issues
  require_human_approval: false # For critical actions

history:
  enabled: true
  max_entries: 100

output:
  default_format: markdown
  include_timestamps: true
```

### Important Settings

| Setting | Default | Description |
|---------|---------|-------------|
| `language` | `en` | Interface language |
| `default_build` | `standard` | Default build preset |
| `semantic_understanding` | `true` | Claude understands intent naturally |
| `max_parallel_agents` | `4` | Parallelism limit (not higher!) |
| `default_timeout` | `600` | Agent timeout (10 minutes) |

---

## ai-success-profiles.yaml

Agent performance metrics for optimization.

### Agent Profile

```yaml
agent_profiles:
  alex:
    name: "Alex"
    emoji: "🔒"
    specialty: "Security"
    success_rate: 0.92
    best_for:
      - "Vulnerability analysis"
      - "Auth flows"
      - "OWASP compliance"
    optimal_context:
      - "Auth implementation"
      - "Data flows"
```

### Optimal Combinations

```yaml
optimal_combinations:
  code_review:
    agents: [david, max, nina]
    combined_success_rate: 0.90
    best_for: "Pull request reviews"

  security_audit:
    agents: [alex, max, david]
    combined_success_rate: 0.91
    best_for: "Security reviews"
```

---

## Customization Examples

### Change default build to quick

```yaml
# preferences.yaml
build:
  default_build: quick
```

### Override semantic understanding

```yaml
# preferences.yaml
build:
  semantic_understanding: false
```

### Add workflow use cases

```yaml
# signals.yaml
workflows:
  custom_workflow:
    description: "Custom workflow for X"
    use_cases:
      - "When doing X"
      - "For Y scenarios"
```

### Exclude agent from standard build

```yaml
# builds.yaml
builds:
  standard:
    agents:
      excluded: [ava]  # Never use Ava in standard build
```

### Add new agent to all builds

1. Create `agents/perspectives/newagent.md`
2. Add to each build in `builds.yaml`:
   ```yaml
   always_included: [..., newagent]
   ```
3. Add profile in `ai-success-profiles.yaml`

---

## Environment Variables

PAF respects these environment variables:

| Variable | Description |
|----------|-------------|
| `PAF_HOME` | Overrides `~/.paf` path |
| `PAF_DEBUG` | Enables debug logging |
| `PAF_LANG` | Overrides language setting |

```bash
export PAF_HOME=/custom/path
export PAF_DEBUG=true
```

---

## Validation

After configuration changes, check:

```bash
bash ~/.paf/scripts/verify-paf.sh
```

This checks:
- Required files exist
- YAML syntax is valid
- Agent references are consistent
