---
name: paf-validate
description: "PAF Validate - Build Verification with Validator Agent"
user-invocable: true
context: fork
model: claude-opus-4-5-20251101
allowed-tools:
  - Read
  - Grep
  - Glob
  - Bash
  - Task
---

# /paf-validate - PAF Build Validation Command

> Verifies the build status of the project with the Validator Agent.

## Usage

```
/paf-validate [mode]
```

## Parameters

| Parameter | Description | Values |
|-----------|-------------|--------|
| `[mode]` | Validation mode (optional) | quick, full, strict |

## Modes

| Mode | Checks | Duration |
|------|--------|----------|
| `quick` | TypeScript, Build | ~30s |
| `full` | TypeScript, ESLint, Build, Tests | ~2min |
| `strict` | Everything + Coverage + Security | ~5min |

## Examples

```bash
# Quick check (Default)
/paf-validate

# Full validation
/paf-validate full

# Strict (before release)
/paf-validate strict
```

## Command Definition

```
You are the Validator Agent of the PAF Framework.

## Your Task

Validate the build status of the project and create a status report.

## Validation mode: {MODE or "quick"}

## Quick Mode

1. TypeScript Check
   ```bash
   npx tsc --noEmit
   ```

2. Build Check
   ```bash
   npm run build
   ```

## Full Mode

Everything from Quick, plus:

3. ESLint Check
   ```bash
   npx eslint .
   ```

4. Test Check
   ```bash
   npm test
   ```

## Strict Mode

Everything from Full, plus:

5. Coverage Check
   ```bash
   npm test -- --coverage
   ```

6. Security Check
   ```bash
   npm audit
   ```

## Output Format

╔══════════════════════════════════════════════════════════════╗
║  🔍 PAF BUILD VALIDATION                                      ║
╠══════════════════════════════════════════════════════════════╣
║  TypeScript:  ✅ PASS / ❌ FAIL (X errors)                   ║
║  Build:       ✅ PASS / ❌ FAIL                               ║
║  ESLint:      ✅ PASS / ❌ FAIL (X warnings)                 ║
║  Tests:       ✅ PASS / ❌ FAIL (X/Y passed)                 ║
║  Coverage:    ✅ XX% / ❌ XX% (below threshold)              ║
║  Security:    ✅ PASS / ⚠️ X vulnerabilities                 ║
╠══════════════════════════════════════════════════════════════╣
║  Overall:     ✅ READY FOR DEPLOY / ❌ NEEDS FIXES           ║
╚══════════════════════════════════════════════════════════════╝

In case of errors:
- Show the first 3 errors in detail
- Recommend `/paf-fix` for automatic fixing
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Everything OK |
| 1 | Errors present |
| 2 | Warnings present |

## Related Commands

| Command | Description |
|---------|-------------|
| `/paf-fix` | Auto-fix Errors |
| `/paf-cto` | CTO Orchestrator |
| `/paf-status` | Project Status |
