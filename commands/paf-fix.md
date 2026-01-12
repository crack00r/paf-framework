# /paf-fix - Bug Fixer Command

Invokes the Bug Fixer Agent to systematically diagnose and fix build errors.

## Usage

```
/paf-fix                    # Full diagnosis + all fixes
/paf-fix typescript         # Fix TypeScript errors only
/paf-fix dependencies       # Resolve dependency conflicts only
/paf-fix lint               # Auto-fix lint errors
/paf-fix test               # Analyze test failures
/paf-fix scan               # Diagnosis only, no changes
```

## Trigger

Invokes: `~/.paf/agents/utility/bug-fixer.md`

## Quick Reference

| Mode | Description | Modifies Code? |
|------|-------------|----------------|
| (default) | Full diagnosis + all safe fixes | ✅ Yes |
| typescript | Analyze and fix TypeScript errors | ✅ Yes |
| dependencies | npm install, peer deps, missing types | ✅ Yes |
| lint | Run ESLint --fix | ✅ Yes |
| test | Analyze test failures | ❌ No |
| scan | Show diagnosis only | ❌ No |

## Process Flow

```
/paf-fix
    │
    ├─→ 1. Environment Detection
    │      - Detect project type (Node/Python/Go/Rust)
    │      - Identify package manager
    │
    ├─→ 2. Error Scan
    │      - Count TypeScript errors
    │      - Count lint errors
    │      - Check build status
    │      - Check test status
    │
    ├─→ 3. Error Categorization
    │      - Group by error code
    │      - Sort by severity
    │      - Determine fix priority
    │
    ├─→ 4. Automatic Fixes (in safe order)
    │      a) Dependencies (npm install, @types/*)
    │      b) Lint Auto-Fix (eslint --fix)
    │      c) Simple TypeScript Fixes (if safe)
    │
    ├─→ 5. Verification
    │      - Check build again
    │      - Count remaining errors
    │
    └─→ 6. Report
           - Before/After comparison
           - Remaining issues (with recommendations)
           - Next Steps
```

## Output Examples

### Success

```
╔══════════════════════════════════════════════════════════════════╗
║                    🐛 BUG FIXER REPORT                           ║
╚══════════════════════════════════════════════════════════════════╝

BEFORE:
  TypeScript: 42 errors
  ESLint: 15 errors
  Build: ❌ FAILING

FIXES APPLIED:
  ✓ Installed @types/node, @types/react
  ✓ Applied ESLint auto-fixes (15 → 0)
  ✓ Fixed 12 duplicate member declarations
  ✓ Fixed 18 uninitialized properties

AFTER:
  TypeScript: 0 errors
  ESLint: 0 errors
  Build: ✅ PASSING

STATUS: ✅ FIXED

Next: npm run dev | /paf-validate
```

### Partial Fix

```
╔══════════════════════════════════════════════════════════════════╗
║                    🐛 BUG FIXER REPORT                           ║
╚══════════════════════════════════════════════════════════════════╝

BEFORE: 42 errors → AFTER: 8 errors

STATUS: ⚠️ PARTIALLY FIXED

REMAINING (require manual fix):
  1. src/auth/provider.ts:45
     TS2322: Type 'string | undefined' not assignable to 'string'
     → Add null check or default value

  2. src/api/handler.ts:89
     TS2339: Property 'data' does not exist on type 'Response'
     → Add proper type assertion

Next: Fix remaining errors manually, then /paf-validate
```

## Integration

### Typical Workflow

```
Change code
    ↓
/paf-fix scan          # First see what's happening
    ↓
/paf-fix               # Auto-fix everything
    ↓
/paf-validate          # Check if everything is OK
    ↓
git commit             # If green
```

### With PAF Review

```
/paf-fix               # First fix errors
    ↓
/paf-validate          # Check build
    ↓
/paf-cto "Review..."   # Then start PAF Review
```

## Common Fixes

### TypeScript

| Error | Auto-Fix? | Description |
|-------|-----------|-------------|
| TS2307 | ✅ | Missing module → npm install |
| TS2564 | ⚠️ | Uninitialized property → manual |
| TS2300 | ⚠️ | Duplicate identifier → manual |
| TS2322 | ❌ | Type mismatch → manual |

### Dependencies

| Problem | Auto-Fix? |
|---------|-----------|
| node_modules missing | ✅ npm install |
| peer deps conflict | ✅ --legacy-peer-deps |
| missing @types/* | ✅ npm install --save-dev |

### Lint

| Problem | Auto-Fix? |
|---------|-----------|
| Formatting issues | ✅ eslint --fix |
| Unused imports | ✅ eslint --fix |
| Missing semicolons | ✅ eslint --fix |
| Complex logic issues | ❌ manual |

## Best Practices

1. **Always scan first**: For unfamiliar codebases first run `/paf-fix scan`
2. **Check git status**: Before fixes run `git status` for clean diffs
3. **Step by step**: For many errors prefer `/paf-fix dependencies` then `/paf-fix lint` etc.
4. **Test after fixes**: Always run `npm test` or `/paf-validate`
