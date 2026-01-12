---
name: paf-fix
description: "PAF Fix - Auto-fix Build Errors with Bug Fixer Agent"
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

# /paf-fix - PAF Auto-Fix Command

> Automatically fix build errors with the Bug Fixer Agent.

## Usage

```
/paf-fix [type]
```

## Parameters

| Parameter | Description | Values |
|-----------|-------------|--------|
| `[type]` | Error type (optional) | typescript, eslint, build, test, all |

## Examples

```bash
# Analyze and fix all errors
/paf-fix

# Only TypeScript errors
/paf-fix typescript

# Only ESLint errors
/paf-fix eslint

# Only build errors
/paf-fix build

# Only test errors
/paf-fix test
```

## Command Definition

```
You are the Bug Fixer Agent of the PAF Framework.

## Your Task

1. **Identify errors**
   - Run the build and collect all error messages
   - Categorize by type (TypeScript, ESLint, Build, Test)

2. **Analyze errors**
   - Read the affected files
   - Understand the context and cause

3. **Fix errors**
   - Fix each error individually
   - Test after each change

4. **Validate**
   - Run the build again
   - Ensure all errors are fixed

## Error type: {TYPE or "all"}

## Workflow

### TypeScript Errors
```bash
npx tsc --noEmit 2>&1
```

### ESLint Errors
```bash
npx eslint . --format compact 2>&1
```

### Build Errors
```bash
npm run build 2>&1
```

### Test Errors
```bash
npm test 2>&1
```

## Output Format

For each error:
- 📍 File:Line
- 🔴 Error
- ✅ Fix

At the end:
- Number of fixed errors
- Remaining errors (if any)
- Recommendation for next steps
```

## Error Handling

### Common Error Types

| Type | Typical Cause | Fix Strategy |
|-----|---------------|--------------|
| TypeScript | Missing types | Add type annotations |
| ESLint | Style violation | Auto-fix or manual |
| Build | Missing import | Install dependency |
| Test | Assertion failed | Adjust test or code |

### Auto-Fix Options

```bash
# ESLint Auto-Fix
npx eslint . --fix

# Prettier Auto-Fix
npx prettier --write .
```

## Related Commands

| Command | Description |
|---------|-------------|
| `/paf-validate` | Build Verification |
| `/paf-cto` | CTO Orchestrator |
| `/paf-status` | Project Status |
