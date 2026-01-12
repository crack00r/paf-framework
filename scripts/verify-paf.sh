#!/usr/bin/env bash
# =============================================================================
# PAF Framework - Installation Verification Script
# =============================================================================
# Validates all 38 agents across 8 categories
# Reads version from VERSION file (Single Source of Truth)
# =============================================================================

PAF_HOME="${PAF_HOME:-$HOME/.paf}"

# Get version from VERSION file
if [ -f "$PAF_HOME/VERSION" ]; then
    PAF_VERSION=$(cat "$PAF_HOME/VERSION" | tr -d '\n\r ')
else
    PAF_VERSION="unknown"
fi

echo "+=================================================================+"
echo "|        PAF Framework v${PAF_VERSION} - Installation Verification        |"
echo "|                    38 Enterprise Agents                        |"
echo "+=================================================================+"
echo ""

PASSED=0
FAILED=0
WARNINGS=0

check() {
    if [ "$1" = "true" ]; then
        echo "  [OK] $2"
        ((PASSED++))
    else
        echo "  [FAIL] $2"
        ((FAILED++))
    fi
}

check_warn() {
    if [ "$1" = "true" ]; then
        echo "  [OK] $2"
        ((PASSED++))
    else
        echo "  [WARN] $2"
        ((WARNINGS++))
    fi
}

# =============================================================================
# 1. Directory Structure
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 1. DIRECTORY STRUCTURE                                        |"
echo "+---------------------------------------------------------------+"

check "$([ -d "$PAF_HOME" ] && echo true)" "$PAF_HOME exists"
check "$([ -f "$PAF_HOME/VERSION" ] && echo true)" "VERSION file (v${PAF_VERSION})"
check "$([ -d "$PAF_HOME/agents" ] && echo true)" "agents/ exists"
check "$([ -d "$PAF_HOME/config" ] && echo true)" "config/ exists"
check "$([ -d "$PAF_HOME/workflows" ] && echo true)" "workflows/ exists"
check "$([ -d "$PAF_HOME/commands" ] && echo true)" "commands/ exists"
check_warn "$([ -d "$PAF_HOME/plugins" ] && echo true)" "plugins/ exists"
check "$([ -d "$PAF_HOME/docs" ] && echo true)" "docs/ exists"
check "$([ -d "$PAF_HOME/scripts" ] && echo true)" "scripts/ exists"

echo ""

# =============================================================================
# 2. Configuration Files
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 2. CONFIGURATION FILES                                        |"
echo "+---------------------------------------------------------------+"

check "$([ -f "$PAF_HOME/config/builds.yaml" ] && echo true)" "builds.yaml"
check "$([ -f "$PAF_HOME/config/signals.yaml" ] && echo true)" "signals.yaml"
check "$([ -f "$PAF_HOME/config/preferences.yaml" ] && echo true)" "preferences.yaml"
check "$([ -f "$PAF_HOME/config/ai-success-profiles.yaml" ] && echo true)" "ai-success-profiles.yaml"
check "$([ -f "$PAF_HOME/config/github.yaml" ] && echo true)" "github.yaml"
check "$([ -f "$PAF_HOME/config/labels.yaml" ] && echo true)" "labels.yaml"
check "$([ -f "$PAF_HOME/config/projects.yaml" ] && echo true)" "projects.yaml"

echo ""

# =============================================================================
# 3. Orchestration (1)
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 3. ORCHESTRATION (1 agent)                                    |"
echo "+---------------------------------------------------------------+"

check "$([ -f "$PAF_HOME/agents/orchestration/cto.md" ] && echo true)" "CTO (Orchestrator)"

echo ""

# =============================================================================
# 4. Discovery Phase (3)
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 4. DISCOVERY PHASE (3 agents)                                 |"
echo "+---------------------------------------------------------------+"

check "$([ -f "$PAF_HOME/agents/discovery/ben.md" ] && echo true)" "Ben (Data Analyst)"
check "$([ -f "$PAF_HOME/agents/discovery/maya.md" ] && echo true)" "Maya (Product Manager)"
check "$([ -f "$PAF_HOME/agents/discovery/iris.md" ] && echo true)" "Iris (Innovation Scout)"

echo ""

# =============================================================================
# 5. Planning Phase (3)
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 5. PLANNING PHASE (3 agents)                                  |"
echo "+---------------------------------------------------------------+"

check "$([ -f "$PAF_HOME/agents/planning/sophia.md" ] && echo true)" "Sophia (Architect)"
check "$([ -f "$PAF_HOME/agents/planning/michael.md" ] && echo true)" "Michael (Tech Lead)"
check "$([ -f "$PAF_HOME/agents/planning/kai.md" ] && echo true)" "Kai (Project Manager)"

echo ""

# =============================================================================
# 6. Implementation Phase (5)
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 6. IMPLEMENTATION PHASE (5 agents)                            |"
echo "+---------------------------------------------------------------+"

check "$([ -f "$PAF_HOME/agents/implementation/sarah.md" ] && echo true)" "Sarah (Lead Developer)"
check "$([ -f "$PAF_HOME/agents/implementation/anna.md" ] && echo true)" "Anna (API Developer)"
check "$([ -f "$PAF_HOME/agents/implementation/chris.md" ] && echo true)" "Chris (Frontend Developer)"
check "$([ -f "$PAF_HOME/agents/implementation/dan.md" ] && echo true)" "Dan (Backend Developer)"
check "$([ -f "$PAF_HOME/agents/implementation/tina.md" ] && echo true)" "Tina (QA Engineer)"

echo ""

# =============================================================================
# 7. Review Phase (4)
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 7. REVIEW PHASE (4 agents)                                    |"
echo "+---------------------------------------------------------------+"

check "$([ -f "$PAF_HOME/agents/review/rachel.md" ] && echo true)" "Rachel (Review Lead)"
check "$([ -f "$PAF_HOME/agents/review/stan.md" ] && echo true)" "Stan (Standards)"
check "$([ -f "$PAF_HOME/agents/review/scanner.md" ] && echo true)" "Scanner (Security)"
check "$([ -f "$PAF_HOME/agents/review/perf.md" ] && echo true)" "Perf (Performance)"

echo ""

# =============================================================================
# 8. Deployment Phase (3)
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 8. DEPLOYMENT PHASE (3 agents)                                |"
echo "+---------------------------------------------------------------+"

check "$([ -f "$PAF_HOME/agents/deployment/tony.md" ] && echo true)" "Tony (DevOps)"
check "$([ -f "$PAF_HOME/agents/deployment/rel.md" ] && echo true)" "Rel (Release Manager)"
check "$([ -f "$PAF_HOME/agents/deployment/miggy.md" ] && echo true)" "Miggy (Migration)"

echo ""

# =============================================================================
# 9. Operations Phase (3)
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 9. OPERATIONS PHASE (3 agents)                                |"
echo "+---------------------------------------------------------------+"

check "$([ -f "$PAF_HOME/agents/operations/inci.md" ] && echo true)" "Inci (Incidents)"
check "$([ -f "$PAF_HOME/agents/operations/monitor.md" ] && echo true)" "Monitor (Monitoring)"
check "$([ -f "$PAF_HOME/agents/operations/feedback.md" ] && echo true)" "Feedback (User Feedback)"

echo ""

# =============================================================================
# 10. Perspective Agents (10)
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 10. PERSPECTIVE AGENTS (10 agents)                            |"
echo "+---------------------------------------------------------------+"

check "$([ -f "$PAF_HOME/agents/perspectives/alex.md" ] && echo true)" "Alex (Security)"
check "$([ -f "$PAF_HOME/agents/perspectives/emma.md" ] && echo true)" "Emma (Performance)"
check "$([ -f "$PAF_HOME/agents/perspectives/sam.md" ] && echo true)" "Sam (UX)"
check "$([ -f "$PAF_HOME/agents/perspectives/david.md" ] && echo true)" "David (Scalability)"
check "$([ -f "$PAF_HOME/agents/perspectives/max.md" ] && echo true)" "Max (Maintainability)"
check "$([ -f "$PAF_HOME/agents/perspectives/luna.md" ] && echo true)" "Luna (Accessibility)"
check "$([ -f "$PAF_HOME/agents/perspectives/tom.md" ] && echo true)" "Tom (Cost)"
check "$([ -f "$PAF_HOME/agents/perspectives/nina.md" ] && echo true)" "Nina (Triage)"
check "$([ -f "$PAF_HOME/agents/perspectives/leo.md" ] && echo true)" "Leo (Documentation)"
check "$([ -f "$PAF_HOME/agents/perspectives/ava.md" ] && echo true)" "Ava (Innovation)"

echo ""

# =============================================================================
# 11. Retrospective & Aggregation (3)
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 11. RETROSPECTIVE (3 agents)                                  |"
echo "+---------------------------------------------------------------+"

check "$([ -f "$PAF_HOME/agents/retrospective/george.md" ] && echo true)" "George (Aggregator)"
check "$([ -f "$PAF_HOME/agents/retrospective/otto.md" ] && echo true)" "Otto (Optimizer)"
check "$([ -f "$PAF_HOME/agents/retrospective/docu.md" ] && echo true)" "Docu (Documentation)"

echo ""

# =============================================================================
# 12. Utility Agents (3)
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 12. UTILITY AGENTS (3 agents)                                 |"
echo "+---------------------------------------------------------------+"

check "$([ -f "$PAF_HOME/agents/utility/gideon.md" ] && echo true)" "Gideon (GitHub Setup)"
check "$([ -f "$PAF_HOME/agents/utility/bug-fixer.md" ] && echo true)" "Bug-Fixer"
check "$([ -f "$PAF_HOME/agents/utility/validator.md" ] && echo true)" "Validator"

echo ""

# =============================================================================
# 13. Workflows
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 13. WORKFLOWS                                                 |"
echo "+---------------------------------------------------------------+"

WORKFLOW_COUNT=$(find "$PAF_HOME/workflows" -name "*.yaml" 2>/dev/null | wc -l | tr -d ' ')
check "$([ "$WORKFLOW_COUNT" -gt 0 ] && echo true)" "Found $WORKFLOW_COUNT workflow(s)"

echo ""

# =============================================================================
# 14. Commands
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 14. COMMANDS                                                  |"
echo "+---------------------------------------------------------------+"

check "$([ -f "$PAF_HOME/commands/paf-cto.md" ] && echo true)" "paf-cto"
check "$([ -f "$PAF_HOME/commands/paf-help.md" ] && echo true)" "paf-help"
check "$([ -f "$PAF_HOME/commands/paf-quickref.md" ] && echo true)" "paf-quickref"
check "$([ -f "$PAF_HOME/commands/paf-status.md" ] && echo true)" "paf-status"
check "$([ -f "$PAF_HOME/commands/paf-fix.md" ] && echo true)" "paf-fix"
check "$([ -f "$PAF_HOME/commands/paf-validate.md" ] && echo true)" "paf-validate"
check "$([ -f "$PAF_HOME/commands/paf-init.md" ] && echo true)" "paf-init"

echo ""

# =============================================================================
# 15. Plugins
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 15. PLUGINS                                                   |"
echo "+---------------------------------------------------------------+"

PLUGIN_DIR="$PAF_HOME/plugins/nested-subagent"

if [ -d "$PLUGIN_DIR" ]; then
    check "true" "nested-subagent plugin directory"

    if [ -f "$PLUGIN_DIR/mcp-server/dist/index.mjs" ]; then
        check "true" "Plugin built (mcp-server/dist/index.mjs)"
    else
        check_warn "false" "Plugin built (run: cd $PLUGIN_DIR && npm install && npm run build)"
    fi
else
    check_warn "false" "nested-subagent plugin (required for agent spawning)"
fi

echo ""

# =============================================================================
# 16. Core Files
# =============================================================================
echo "+---------------------------------------------------------------+"
echo "| 16. CORE FILES                                                |"
echo "+---------------------------------------------------------------+"

check "$([ -f "$PAF_HOME/SKILL.md" ] && echo true)" "SKILL.md"
check "$([ -f "$PAF_HOME/install.sh" ] && echo true)" "install.sh"
check "$([ -f "$PAF_HOME/update.sh" ] && echo true)" "update.sh"
check_warn "$([ -f "$PAF_HOME/COMMS.md" ] && echo true)" "COMMS.md (created per project)"

echo ""

# =============================================================================
# Count total agents (exclude helper files like AGENT_PROLOGUE.md, spawn-templates.md)
# =============================================================================
AGENT_COUNT=$(find "$PAF_HOME/agents" -name "*.md" -type f ! -name "AGENT_PROLOGUE.md" ! -name "spawn-templates.md" 2>/dev/null | wc -l | tr -d ' ')

# =============================================================================
# Summary
# =============================================================================
echo "+=================================================================+"
echo "|                         SUMMARY                                |"
echo "+=================================================================+"
echo ""
echo "  Version:   v${PAF_VERSION}"
echo "  Agents:    $AGENT_COUNT"
echo ""
echo "  [OK]:      $PASSED"
echo "  [FAIL]:    $FAILED"
echo "  [WARN]:    $WARNINGS"
echo ""

if [ $FAILED -eq 0 ]; then
    echo "+---------------------------------------------------------------+"
    echo "| [OK] PAF v${PAF_VERSION} VERIFIED - $AGENT_COUNT Enterprise Agents Ready    |"
    echo "+---------------------------------------------------------------+"
    echo ""
    echo "Quick Start:"
    echo "  /paf-cto \"Review my code\""
    echo "  /paf-cto \"Quick check\" --build=quick"
    echo "  /paf-cto \"Full audit\" --build=comprehensive"
    echo "  /paf-help"
    echo ""
    echo "Update PAF:"
    echo "  cd ~/.paf && git pull && ./update.sh"
else
    echo "+---------------------------------------------------------------+"
    echo "| [FAIL] PAF INSTALLATION INCOMPLETE                            |"
    echo "+---------------------------------------------------------------+"
    echo ""
    echo "Please fix the failed checks above."
    echo "See docs/INSTALLATION.md for help."
    echo ""
    echo "Re-install:"
    echo "  rm -rf ~/.paf && cd /path/to/paf-framework && ./install.sh"
fi

echo ""
