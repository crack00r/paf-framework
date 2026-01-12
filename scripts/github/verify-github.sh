#!/bin/bash
# PAF GitHub Setup - Verification
# Checks if all GitHub components are correctly set up
# Usage: ./verify-github.sh [--repo owner/repo]

set -e

# Determine repository
if [ -n "$1" ] && [ "$1" == "--repo" ]; then
    REPO="$2"
else
    REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
fi

OWNER=$(echo "$REPO" | cut -d'/' -f1)

echo "════════════════════════════════════════════"
echo "🔍 PAF GitHub Verification"
echo "   Repository: $REPO"
echo "   Owner: $OWNER"
echo "════════════════════════════════════════════"
echo ""

PASSED=0
FAILED=0
WARNINGS=0

check_pass() {
    echo "  ✅ $1"
    ((PASSED++))
}

check_fail() {
    echo "  ❌ $1"
    ((FAILED++))
}

check_warn() {
    echo "  ⚠️  $1"
    ((WARNINGS++))
}

# 1. GitHub CLI
echo "=== 1. GitHub CLI ==="
if gh auth status &>/dev/null; then
    check_pass "GitHub CLI authenticated"
else
    check_fail "GitHub CLI not authenticated"
fi

# 2. Repository
echo ""
echo "=== 2. Repository ==="
if gh repo view "$REPO" &>/dev/null; then
    check_pass "Repository accessible: $REPO"
else
    check_fail "Repository not accessible"
fi

# 3. Labels
echo ""
echo "=== 3. Labels ==="
LABEL_COUNT=$(gh label list --repo "$REPO" --json name -q 'length' 2>/dev/null || echo "0")

if [ "$LABEL_COUNT" -ge 50 ]; then
    check_pass "Labels present: $LABEL_COUNT (expected: ≥50)"
elif [ "$LABEL_COUNT" -ge 30 ]; then
    check_warn "Labels partially present: $LABEL_COUNT (expected: ≥50)"
else
    check_fail "Labels missing: $LABEL_COUNT (expected: ≥50)"
fi

# Check important labels
IMPORTANT_LABELS=("finding" "P0" "P1" "P2" "P3" "🤖 agent" "🔒 alex" "⚡ emma")
for label in "${IMPORTANT_LABELS[@]}"; do
    if gh label list --repo "$REPO" --json name -q '.[].name' | grep -q "^$label$"; then
        check_pass "Label: $label"
    else
        check_fail "Label missing: $label"
    fi
done

# 4. Project Boards
echo ""
echo "=== 4. Project Boards ==="
PROJECT_COUNT=$(gh project list --owner "$OWNER" --format json 2>/dev/null | jq '.projects | length' || echo "0")

if [ "$PROJECT_COUNT" -ge 7 ]; then
    check_pass "Project Boards: $PROJECT_COUNT (expected: ≥7)"
elif [ "$PROJECT_COUNT" -ge 1 ]; then
    check_warn "Project Boards partial: $PROJECT_COUNT (expected: ≥7)"
else
    check_fail "No Project Boards found"
fi

# Check important boards (dynamically based on repo name)
REPO_NAME=$(echo "$REPO" | cut -d'/' -f2)
IMPORTANT_BOARDS=("$REPO_NAME Sprint" "$REPO_NAME Security" "$REPO_NAME Backlog")
for board in "${IMPORTANT_BOARDS[@]}"; do
    if gh project list --owner "$OWNER" --format json | jq -r '.projects[].title' | grep -q "$board"; then
        check_pass "Board: $board"
    else
        check_fail "Board missing: $board"
    fi
done

# 5. Issue Templates
echo ""
echo "=== 5. Issue Templates ==="
if [ -d ".github/ISSUE_TEMPLATE" ]; then
    TEMPLATE_COUNT=$(ls -1 .github/ISSUE_TEMPLATE/*.yml 2>/dev/null | wc -l)
    if [ "$TEMPLATE_COUNT" -ge 5 ]; then
        check_pass "Issue Templates: $TEMPLATE_COUNT (expected: ≥5)"
    else
        check_warn "Issue Templates partial: $TEMPLATE_COUNT (expected: ≥5)"
    fi
else
    check_fail "Issue Templates directory missing"
fi

# 6. GitHub Actions
echo ""
echo "=== 6. GitHub Actions ==="
if [ -d ".github/workflows" ]; then
    WORKFLOW_COUNT=$(ls -1 .github/workflows/paf-*.yml 2>/dev/null | wc -l)
    if [ "$WORKFLOW_COUNT" -ge 4 ]; then
        check_pass "PAF Workflows: $WORKFLOW_COUNT (expected: ≥4)"
    elif [ "$WORKFLOW_COUNT" -ge 1 ]; then
        check_warn "PAF Workflows partial: $WORKFLOW_COUNT (expected: ≥4)"
    else
        check_warn "No PAF Workflows found"
    fi
else
    check_warn "Workflows directory missing"
fi

# 7. GITHUB_SYSTEM.md
echo ""
echo "=== 7. PAF Configuration ==="
if [ -f ".paf/GITHUB_SYSTEM.md" ]; then
    check_pass "GITHUB_SYSTEM.md present"

    # Check if IDs are included
    if grep -q "PROJECT_ID\|Project.*ID" .paf/GITHUB_SYSTEM.md 2>/dev/null; then
        check_pass "Project IDs documented"
    else
        check_warn "Project IDs missing in GITHUB_SYSTEM.md"
    fi
else
    check_fail "GITHUB_SYSTEM.md missing"
fi

# 8. Milestones
echo ""
echo "=== 8. Milestones ==="
MILESTONE_COUNT=$(gh api "repos/$REPO/milestones" --jq 'length' 2>/dev/null || echo "0")
if [ "$MILESTONE_COUNT" -ge 1 ]; then
    check_pass "Milestones: $MILESTONE_COUNT"
else
    check_warn "No Milestones found"
fi

# 9. Write permissions test
echo ""
echo "=== 9. Permissions ==="
# Try to create and delete a test label
if gh label create "paf-verify-test" --repo "$REPO" --color "000000" --force &>/dev/null; then
    gh label delete "paf-verify-test" --repo "$REPO" --yes &>/dev/null
    check_pass "Write permissions available"
else
    check_fail "No write permissions"
fi

# Summary
echo ""
echo "════════════════════════════════════════════"
echo "📊 SUMMARY"
echo "════════════════════════════════════════════"
echo "  ✅ Passed:   $PASSED"
echo "  ❌ Failed:   $FAILED"
echo "  ⚠️  Warnings: $WARNINGS"
echo ""

if [ "$FAILED" -eq 0 ]; then
    echo "🎉 GitHub Setup is complete!"
    exit 0
elif [ "$FAILED" -le 3 ]; then
    echo "⚠️  GitHub Setup is incomplete. Run setup again."
    exit 1
else
    echo "❌ GitHub Setup is missing. Run /paf-setup-github."
    exit 2
fi
