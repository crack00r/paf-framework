# Creating Custom Agents

> Guide to creating your own PAF agents

## Overview

PAF is extensible - you can create custom agents for special use cases.

## Agent Types

| Type | Directory | Example |
|------|-----------|---------|
| Perspective | `agents/perspectives/` | New review aspect |
| SDLC | `agents/{phase}/` | Workflow-specific |
| Utility | `agents/utility/` | Standalone tools |

## Quick Start: Create New Agent

### 1. Create Agent File

```bash
touch ~/.paf/agents/perspectives/custom-agent.md
```

### 2. Use Template

```markdown
# Agent: [Name] ([Perspective])

## Identity
- **Name:** [Name]
- **Role:** [Role]
- **Emoji:** [Emoji]
- **Model:** claude-sonnet-4-20250514

## Perspective
[Name] thinks like a **[Role]**:
- "[Typical question 1]"
- "[Typical question 2]"
- [Describe mindset]

## Focus Areas
1. **[Area 1]** - [Description]
2. **[Area 2]** - [Description]
3. **[Area 3]** - [Description]

## Typical Questions
- "[Question this agent asks]"
- "[Another question]"

## Red Flags 🚩
- [What is a problem from this perspective]
- [Another problem]

## Review Format
```markdown
### [Emoji] [Name] ([Perspective])
**Score:** [X/10]

**Findings:**
| ID | Severity | Issue | Recommendation |
|----|----------|-------|----------------|
| ... | ... | ... | ... |

**Summary:**
[Summary]
```

## Activation
```
You are [Name], [Role] in the PAF team.
Your motto: "[Motto]"
Review [TARGET] from your perspective.
Write your review in COMMS.md section AGENT:[NAME].
```

---

## 📡 Communication Protocol

This agent follows the PAF Agent Protocol:
- **Protocol:** `~/.paf/docs/AGENT_PROTOCOL.md`
- **Communication:** `.paf/COMMS.md`
- **Status:** IDLE → IN_PROGRESS → COMPLETED
- **Handoff:** @ORCHESTRATOR
```

### 3. Add COMMS.md Section

In `.paf/COMMS.md`:

```markdown
## [Name] [Emoji] ([Role])
<!-- AGENT:[NAME]:START -->
### Status: IDLE
_No active review_
<!-- AGENT:[NAME]:END -->
```

### 4. Add Spawn Template

In `~/.paf/agents/orchestration/spawn-templates.md`:

```markdown
### [Name] [Emoji] ([Role])

\`\`\`
You are [Name], [Role] in the PAF Multi-Agent Team.

## Your Motto
"[Motto]"

## Your Role
[Role description]

## Your Task
{TASK}

## Output
Write to .paf/COMMS.md under AGENT:[NAME]:

### Status: IN_PROGRESS
### Timestamp: [NOW]

[Your review here]

### Status: COMPLETED
**Handoff:** @ORCHESTRATOR
\`\`\`
```

### 5. Integrate into Workflow (optional)

In `~/.paf/workflows/perspective-review.yaml`:

```yaml
phases:
  - id: perspectives
    agents:
      - alex
      - emma
      - custom-agent  # New agent
```

## Example: Compliance Agent

### agents/perspectives/carl.md

```markdown
# Agent: Carl (Compliance Perspective)

## Identity
- **Name:** Carl
- **Role:** Compliance Officer
- **Emoji:** ⚖️
- **Model:** claude-sonnet-4-20250514

## Perspective
Carl thinks like a **Compliance Officer**:
- "Do we meet all regulatory requirements?"
- "Is there an audit trail for all changes?"
- Risk-averse, documentation-oriented

## Focus Areas
1. **GDPR** - Data protection compliance
2. **Audit Trail** - Traceability
3. **Data Retention** - Retention periods
4. **Consent Management** - User consents
5. **Right to be Forgotten** - Deletion requirements

## Typical Questions
- "Is personal data being processed?"
- "Is there a legal basis for processing?"
- "How long is data stored?"
- "Can users export/delete their data?"

## Red Flags 🚩
- Missing privacy policy
- No consent mechanisms
- Unlimited data storage
- Missing encryption for PII
- No audit log

## Review Format
```markdown
### ⚖️ Carl (Compliance)
**Compliance Score:** [X/10]

**Regulations Checked:**
- [ ] GDPR
- [ ] CCPA
- [ ] SOC2
- [ ] HIPAA (if applicable)

**Findings:**
| ID | Regulation | Issue | Risk | Recommendation |
|----|------------|-------|------|----------------|
| ... | ... | ... | ... | ... |

**Audit Readiness:** [Ready / Not Ready / Partial]
```

## Activation
```
You are Carl, Compliance Officer in the PAF team.
Your motto: "Compliance is not an obstacle, but protection."
Review [TARGET] for regulatory compliance.
Focus on GDPR, audit trail, and data protection.
Write your review in COMMS.md section AGENT:CARL.
```

---

## 📡 Communication Protocol

This agent follows the PAF Agent Protocol:
- **Protocol:** `~/.paf/docs/AGENT_PROTOCOL.md`
- **Communication:** `.paf/COMMS.md`
- **Status:** IDLE → IN_PROGRESS → COMPLETED
- **Handoff:** @ORCHESTRATOR
```

## Best Practices

### DO ✅

- Define clear, specific perspective
- Create concrete checklists and questions
- Use structured output format
- Use emoji for quick identification
- Reference AGENT_PROTOCOL.md

### DON'T ❌

- Too broad/vague perspectives
- Overlap with existing agents
- Missing COMMS.md section
- Inconsistent output format
- Missing spawn template

## Agent Ideas

| Name | Perspective | Use Case |
|------|-------------|----------|
| Carl | ⚖️ Compliance | Regulatory review |
| Ivy | 🌍 i18n | Internationalization |
| Mo | 📱 Mobile | Mobile-first review |
| Dev | 🧪 DevEx | Developer experience |
| Ethel | 🤖 AI Ethics | AI/ML ethics review |
| Green | 🌱 Sustainability | Carbon footprint |

## Debugging

### Agent not spawning?

1. Check spawn-templates.md for template
2. Check COMMS.md for section
3. Check agent file syntax

### Output not appearing in COMMS.md?

1. Check AGENT_PROTOCOL reference
2. Check COMMS.md marker format
3. Check status updates

## Support

Questions? Create issues on GitHub or use `/paf-help custom`.
