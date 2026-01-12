# PAF Language Policy

**Version:** 2.0
**Last Updated:** 2026-01-12
**Status:** Active

## Overview

This document defines the language consistency policy for the PAF Framework. **All content is English-only.**

## Language Rules by Context

### 1. Configuration Files (English Only)

**Files:** `*.yaml`, `*.json` in `/config`

**Rule:** All configuration files MUST use English for:
- Keys and property names
- Enum values
- Schema definitions
- Technical identifiers
- Comments

**Rationale:**
- Configuration files are parsed programmatically
- English ensures cross-platform compatibility
- Industry standard for config files
- Easier for international contributors

**Example:**
```yaml
github:
  enabled: true
  auto_create_issues: true
  default_project: "Sprint Board"
```

### 2. Agent Output (English)

**Files:** Agent-generated findings, reports, COMMS.md updates

**Rule:** Agents output in English:
- All findings and reports
- COMMS.md updates
- GitHub issue content

**Rationale:**
- Consistency across all outputs
- International accessibility
- Easier collaboration

**Example:**
```markdown
<!-- AGENT:ALEX:START -->
**Findings:**
- ❌ Critical: SQL-Injection in login.ts:42
- ⚠️  Warning: Missing input validation
<!-- AGENT:ALEX:END -->
```

### 3. Documentation (English)

**Files:** `*.md` in root, `/docs`, `/agents`

**Rule:** All documentation uses English:
- README.md
- CLAUDE.md
- Agent instructions
- User guides

**Rationale:**
- READMEs reach international audiences
- Consistency across documentation
- Easier maintenance

**Example Structure:**
```
docs/
  user-guide.md
  architecture.md
  api-reference.md
  getting-started.md
```

### 4. Code Comments (English)

**Files:** Agent spawn templates, scripts

**Rule:** Code comments MUST use English:
- Function/class documentation → English
- Inline comments → English
- TODOs → English

**Rationale:**
- Code may be shared/forked internationally
- English is lingua franca of programming
- Consistency with industry standards

## Summary Matrix

| Context | Language | Enforcement |
|---------|----------|-------------|
| Config files (keys) | English | MUST |
| Config comments | English | MUST |
| Agent output | English | MUST |
| README.md | English | MUST |
| CLAUDE.md | English | MUST |
| Agent instructions | English | MUST |
| User-facing docs | English | MUST |
| Code comments | English | MUST |
| COMMS.md updates | English | MUST |
| GitHub issues | English | SHOULD |

## Exceptions

1. **Proper Nouns:** Agent names (Alex, Emma, etc.) always remain as defined
2. **Technical Terms:** Industry terms (Sprint, Backlog, CI/CD) stay English
3. **Error Messages:** All errors in English
4. **Logs:** Always English for debugging

## Migration Strategy

**All content has been migrated to English.** Future contributions must follow English-only policy.

### For New Files

1. Use English for all content
2. Follow existing file patterns
3. Check documentation standards

### For Existing Files

- All files are English
- Maintain consistency within files
- Update if any non-English content found

## Enforcement

- **Automated:** None (trust-based approach)
- **Code Review:** Reviewers ensure English content
- **Documentation:** This policy is mandatory

## Rationale

PAF uses English exclusively for:

1. **Config = English** → Ensures tool compatibility
2. **Output = English** → International accessibility
3. **Docs = English** → Consistent documentation

## Questions?

- **"What language for new agent instructions?"** → English
- **"What about GitHub issue titles?"** → English preferred

---

**See Also:**
- [PAF Versioning](../CLAUDE.md#versioning)
- [Agent Conventions](../CLAUDE.md#code-conventions)
