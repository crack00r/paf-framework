# /paf-validate - Build Verification Command

Invokes the Validator Agent to perform systematic build verification and quality gate checks.

## Usage

```
/paf-validate              # Full validation
/paf-validate build        # Build check only
/paf-validate types        # TypeScript check only
/paf-validate lint         # Linting check only
/paf-validate test         # Test check only
/paf-validate security     # Security audit (npm audit)
/paf-validate quick        # Quick check (Build + Types)
```

## Trigger

Invokes: `~/.paf/agents/utility/validator.md`

## Quick Reference

| Mode | Checks | Time |
|------|--------|------|
| (default) | Everything | ~30s |
| quick | Build + Types | ~10s |
| build | npm build only | ~5s |
| types | tsc --noEmit only | ~5s |
| lint | ESLint only | ~5s |
| test | npm test only | varies |
| security | npm audit | ~10s |

## Validation Checks

### Full Validation (Default)

```
┌─────────────────────────────────────────────────────────────────┐
│ ✅ FULL VALIDATION                                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ 1. Dependencies                                                 │
│    ✓ node_modules exists                                       │
│    ✓ No outdated critical packages                             │
│    ✓ No high/critical vulnerabilities                          │
│                                                                 │
│ 2. TypeScript                                                   │
│    ✓ npx tsc --noEmit passes                                   │
│    ✓ No type errors                                            │
│                                                                 │
│ 3. Linting                                                      │
│    ✓ npm run lint passes                                       │
│    ✓ No errors (warnings acceptable)                           │
│                                                                 │
│ 4. Build                                                        │
│    ✓ npm run build passes                                      │
│    ✓ Build artifacts created                                   │
│                                                                 │
│ 5. Tests                                                        │
│    ✓ npm test passes                                           │
│    ✓ All tests passing                                         │
│                                                                 │
│ 6. Coverage (optional)                                          │
│    ✓ Coverage >= 80% (if configured)                           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Output Format

### All Passed

```
╔══════════════════════════════════════════════════════════════════╗
║                    ✅ PAF VALIDATOR                              ║
╚══════════════════════════════════════════════════════════════════╝

📦 Project: my-awesome-app

┌─────────────────────────────────────────────────────────────────┐
│ VALIDATION RESULTS                                              │
├─────────────────────────────────────────────────────────────────┤
│ Dependencies:  ✅ OK                                            │
│ TypeScript:    ✅ 0 errors                                      │
│ ESLint:        ✅ Clean                                         │
│ Build:         ✅ Successful                                    │
│ Tests:         ✅ 42/42 passing                                 │
│ Coverage:      ✅ 85%                                           │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ STATUS: ✅ ALL CHECKS PASSED                                    │
└─────────────────────────────────────────────────────────────────┘

Ready for: commit, push, deploy 🚀
```

### With Failures

```
╔══════════════════════════════════════════════════════════════════╗
║                    ✅ PAF VALIDATOR                              ║
╚══════════════════════════════════════════════════════════════════╝

📦 Project: my-awesome-app

┌─────────────────────────────────────────────────────────────────┐
│ VALIDATION RESULTS                                              │
├─────────────────────────────────────────────────────────────────┤
│ Dependencies:  ✅ OK                                            │
│ TypeScript:    ❌ 5 errors                                      │
│ ESLint:        ⚠️ 3 warnings                                    │
│ Build:         ❌ Failed                                        │
│ Tests:         ⏭️ Skipped (build failed)                        │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ ERRORS                                                          │
├─────────────────────────────────────────────────────────────────┤
│ TypeScript:                                                     │
│   src/auth.ts:42 - TS2322: Type mismatch                       │
│   src/api.ts:15 - TS2339: Property doesn't exist               │
│   ... 3 more                                                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ STATUS: ❌ VALIDATION FAILED                                    │
└─────────────────────────────────────────────────────────────────┘

💡 Next Steps:
   /paf-fix              # Auto-fix common issues
   /paf-fix typescript   # Fix TypeScript errors
```

## Quality Gates

### Quick Gate (`/paf-validate quick`)

Minimal checks for fast iteration:

- ✅ TypeScript compiles
- ✅ Build successful

### Standard Gate (`/paf-validate`)

Full checks for commits:

- ✅ Dependencies OK
- ✅ TypeScript compiles
- ✅ No lint errors
- ✅ Build successful
- ✅ Tests pass

### Production Gate

For production releases (manual):

- ✅ All standard gates
- ✅ Coverage >= 80%
- ✅ No security vulnerabilities
- ✅ No hardcoded secrets

## Integration

### Pre-Commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run quick validation
/paf-validate quick
if [ $? -ne 0 ]; then
    echo "❌ Validation failed. Run /paf-fix to resolve."
    exit 1
fi
```

### CI/CD

```yaml
# .github/workflows/validate.yml
name: PAF Validation
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npx tsc --noEmit
      - run: npm run lint
      - run: npm run build
      - run: npm test
```

### With PAF Review

```
/paf-validate              # First validate
    ↓
/paf-cto "Review..."       # Then review (only if green)
```

## Security Mode

`/paf-validate security` runs additional security checks:

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔐 SECURITY VALIDATION                                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ npm audit:                                                      │
│   ✅ No critical vulnerabilities                                │
│   ✅ No high vulnerabilities                                    │
│   ⚠️ 3 moderate vulnerabilities                                 │
│                                                                 │
│ Secret Scan:                                                    │
│   ✅ No hardcoded secrets found                                 │
│                                                                 │
│ .env Check:                                                     │
│   ✅ .env not tracked in git                                   │
│   ✅ .env in .gitignore                                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Best Practices

1. **Before every commit**: `/paf-validate quick`
2. **Before every push**: `/paf-validate`
3. **Before release**: `/paf-validate security`
4. **After fixes**: `/paf-validate` to confirm success
5. **In CI/CD**: Automatic validation on every push
