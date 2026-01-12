# /paf-status - PAF Project Status

Shows the current project status and PAF configuration.

## Usage

```
/paf-status              # Full Status
/paf-status --project    # Project Info only
/paf-status --config     # PAF Configuration only
/paf-status --history    # Recent Analyses
```

## Process

### Default Output

```
╔══════════════════════════════════════════════════════════════════╗
║                    📊 PAF STATUS                                 ║
╚══════════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────────┐
│ 📦 PROJECT                                                      │
├─────────────────────────────────────────────────────────────────┤
│ Name:          my-awesome-app                                   │
│ Path:          /Users/user/projects/my-awesome-app              │
│ Type:          Node.js/TypeScript                               │
│ Package:       package.json ✅                                  │
│ Git:           main branch, 3 uncommitted changes               │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 🔧 BUILD STATUS                                                 │
├─────────────────────────────────────────────────────────────────┤
│ TypeScript:    ✅ Clean (0 errors)                              │
│ ESLint:        ⚠️ 3 warnings                                    │
│ Build:         ✅ Passing                                       │
│ Tests:         ✅ 42/42 passing                                 │
│ Coverage:      78%                                              │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ ⚡ PAF CONFIGURATION                                             │
├─────────────────────────────────────────────────────────────────┤
│ PAF Version:   (dynamic)                                          │
│ Install:       ~/.paf/ ✅                                       │
│ Config:        ~/.paf/config/ ✅                                │
│ Plugins:       nested-subagent ✅                               │
│                                                                 │
│ Default Build: standard                                         │
│ Language:      en                                               │
│ Parallel:      enabled                                          │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 📜 RECENT ANALYSES                                              │
├─────────────────────────────────────────────────────────────────┤
│ 1. 2026-01-09 14:32  security-audit     comprehensive  ✅      │
│ 2. 2026-01-09 10:15  perspective-review standard       ✅      │
│ 3. 2026-01-08 16:45  quick-check        quick          ✅      │
└─────────────────────────────────────────────────────────────────┘

💡 Quick Actions:
   /paf-cto "Continue review"     # Resume analysis
   /paf-validate                  # Full validation
   /paf-fix                       # Fix any issues
```

### Project Detection

```bash
#!/bin/bash

echo "📦 PROJECT DETECTION"
echo "===================="

# Detect project name
if [ -f "package.json" ]; then
    PROJECT_NAME=$(grep '"name"' package.json | head -1 | sed 's/.*": "\([^"]*\)".*/\1/')
    PROJECT_TYPE="Node.js"
    echo "Name: $PROJECT_NAME"
    echo "Type: $PROJECT_TYPE"
    
    # Check for TypeScript
    if [ -f "tsconfig.json" ]; then
        echo "Language: TypeScript"
    else
        echo "Language: JavaScript"
    fi
    
    # Check for frameworks
    if grep -q "next" package.json; then
        echo "Framework: Next.js"
    elif grep -q "react" package.json; then
        echo "Framework: React"
    elif grep -q "vue" package.json; then
        echo "Framework: Vue"
    fi
fi

# Git status
if [ -d ".git" ]; then
    BRANCH=$(git branch --show-current)
    CHANGES=$(git status --porcelain | wc -l | tr -d ' ')
    echo "Git: $BRANCH branch, $CHANGES uncommitted changes"
fi
```

### PAF Configuration Check

```bash
#!/bin/bash

echo "⚡ PAF CONFIGURATION"
echo "===================="

PAF_DIR="$HOME/.paf"

if [ -d "$PAF_DIR" ]; then
    echo "Install: $PAF_DIR ✅"
    
    # Check config files
    if [ -d "$PAF_DIR/config" ]; then
        echo "Config: $PAF_DIR/config/ ✅"
        
        # List config files
        echo "  - builds.yaml $([ -f "$PAF_DIR/config/builds.yaml" ] && echo "✅" || echo "❌")"
        echo "  - signals.yaml $([ -f "$PAF_DIR/config/signals.yaml" ] && echo "✅" || echo "❌")"
        echo "  - preferences.yaml $([ -f "$PAF_DIR/config/preferences.yaml" ] && echo "✅" || echo "❌")"
        echo "  - ai-success-profiles.yaml $([ -f "$PAF_DIR/config/ai-success-profiles.yaml" ] && echo "✅" || echo "❌")"
    else
        echo "Config: Missing ❌"
    fi
    
    # Check plugins
    if [ -d "$PAF_DIR/plugins" ]; then
        PLUGINS=$(ls "$PAF_DIR/plugins" 2>/dev/null | wc -l | tr -d ' ')
        echo "Plugins: $PLUGINS installed"
        ls "$PAF_DIR/plugins" 2>/dev/null | sed 's/^/  - /'
    fi
    
    # Check agents
    if [ -d "$PAF_DIR/agents" ]; then
        AGENTS=$(find "$PAF_DIR/agents" -name "*.md" | wc -l | tr -d ' ')
        echo "Agents: $AGENTS defined"
    fi
    
    # Check workflows
    if [ -d "$PAF_DIR/workflows" ]; then
        WORKFLOWS=$(ls "$PAF_DIR/workflows"/*.yaml 2>/dev/null | wc -l | tr -d ' ')
        echo "Workflows: $WORKFLOWS defined"
    fi
else
    echo "PAF not installed at $PAF_DIR ❌"
    echo ""
    echo "Install PAF:"
    echo "  mkdir -p ~/.paf"
    echo "  # Copy PAF files to ~/.paf/"
fi
```

### Quick Build Status

```bash
#!/bin/bash

echo "🔧 BUILD STATUS"
echo "==============="

# TypeScript
if [ -f "tsconfig.json" ]; then
    TS_ERRORS=$(npx tsc --noEmit 2>&1 | grep -c "error TS" || echo "0")
    if [ "$TS_ERRORS" -eq 0 ]; then
        echo "TypeScript: ✅ Clean"
    else
        echo "TypeScript: ❌ $TS_ERRORS errors"
    fi
fi

# ESLint
if [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || [ -f "eslint.config.js" ]; then
    LINT_ERRORS=$(npm run lint 2>&1 | grep -c "error" || echo "0")
    LINT_WARNINGS=$(npm run lint 2>&1 | grep -c "warning" || echo "0")
    if [ "$LINT_ERRORS" -eq 0 ]; then
        if [ "$LINT_WARNINGS" -gt 0 ]; then
            echo "ESLint: ⚠️ $LINT_WARNINGS warnings"
        else
            echo "ESLint: ✅ Clean"
        fi
    else
        echo "ESLint: ❌ $LINT_ERRORS errors"
    fi
fi

# Build
npm run build 2>&1 > /dev/null
if [ $? -eq 0 ]; then
    echo "Build: ✅ Passing"
else
    echo "Build: ❌ Failing"
fi

# Tests
npm test 2>&1 > /dev/null
if [ $? -eq 0 ]; then
    echo "Tests: ✅ Passing"
else
    echo "Tests: ❌ Failing"
fi
```

### History Display

Shows the recent PAF analyses (if History is enabled):

```
┌─────────────────────────────────────────────────────────────────┐
│ 📜 ANALYSIS HISTORY                                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ #1  2026-01-09 14:32:15                                        │
│     Workflow:  security-audit                                   │
│     Build:     comprehensive                                    │
│     Duration:  24 minutes                                       │
│     Agents:    12 (all completed)                               │
│     Findings:  2 critical, 5 high, 12 medium                    │
│     Status:    ✅ Complete                                      │
│                                                                 │
│ #2  2026-01-09 10:15:42                                        │
│     Workflow:  perspective-review                               │
│     Build:     standard                                         │
│     Duration:  9 minutes                                        │
│     Agents:    8 (all completed)                                │
│     Findings:  0 critical, 3 high, 8 medium                     │
│     Status:    ✅ Complete                                      │
│                                                                 │
│ #3  2026-01-08 16:45:03                                        │
│     Workflow:  perspective-review                               │
│     Build:     quick                                            │
│     Duration:  2 minutes                                        │
│     Agents:    4 (all completed)                                │
│     Findings:  0 critical, 1 high, 3 medium                     │
│     Status:    ✅ Complete                                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

💡 View details: /paf-history #1
```

## Suggested Next Actions

Based on status, suggest appropriate actions:

```
💡 SUGGESTED ACTIONS:
─────────────────────────────────────────────────────────────────

Based on current status:

• TypeScript errors found:
  → /paf-fix typescript

• Build failing:
  → /paf-fix
  → /paf-validate

• No recent analysis:
  → /paf-cto "Review current state"

• Uncommitted changes:
  → /paf-cto "Quick review before commit" --build=quick
  → /paf-validate quick

• All green:
  → Ready for commit/push! 🚀
```
