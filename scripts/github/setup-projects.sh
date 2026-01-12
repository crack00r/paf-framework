#!/bin/bash
# PAF GitHub Setup - Project Boards
# Creates all PAF Project Boards and links them to the repository
# Usage: ./setup-projects.sh [--repo owner/repo]

# Determine repository
if [ -n "$1" ] && [ "$1" == "--repo" ]; then
    REPO="$2"
else
    REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
fi

if [ -z "$REPO" ]; then
    echo "❌ No repository found. Use --repo owner/repo"
    exit 1
fi

# Extract owner from repo
OWNER=$(echo "$REPO" | cut -d'/' -f1)
REPO_NAME=$(echo "$REPO" | cut -d'/' -f2)

echo "📋 Creating PAF Project Boards for: $REPO"
echo "   Owner: $OWNER"
echo ""

# Output file for IDs
OUTPUT_FILE=".paf/GITHUB_PROJECTS.json"
mkdir -p .paf
echo "{}" > "$OUTPUT_FILE"

create_project() {
    local title="$1"
    local key="$2"

    echo "Creating: $title"

    # Check if project already exists
    EXISTING=$(gh project list --owner "$OWNER" --format json 2>/dev/null | jq -r ".projects[] | select(.title == \"$title\") | .number" 2>/dev/null || echo "")

    if [ -n "$EXISTING" ] && [ "$EXISTING" != "null" ]; then
        echo "  ℹ️  Project already exists: #$EXISTING"
        PROJECT_NUM="$EXISTING"
    else
        # Create new project
        PROJECT_NUM=$(gh project create --owner "$OWNER" --title "$title" --format json 2>/dev/null | jq -r '.number')
        if [ -z "$PROJECT_NUM" ] || [ "$PROJECT_NUM" == "null" ]; then
            echo "  ⚠️  Could not create project (possibly no permission)"
            return
        fi
        echo "  ✓ Created: #$PROJECT_NUM"
    fi

    # Link project with repository
    echo "  🔗 Linking with repository..."
    if gh project link "$PROJECT_NUM" --owner "$OWNER" --repo "$REPO" 2>/dev/null; then
        echo "  ✓ Linked with $REPO"
    else
        echo "  ℹ️  Already linked or linking not possible"
    fi

    # Generate URL (Repository-View)
    PROJECT_URL="https://github.com/$REPO/projects"
    USER_PROJECT_URL="https://github.com/users/$OWNER/projects/$PROJECT_NUM"

    # Get ID
    PROJECT_ID=$(gh project list --owner "$OWNER" --format json 2>/dev/null | jq -r ".projects[] | select(.number == $PROJECT_NUM) | .id")

    # Save to output file
    jq --arg key "$key" \
       --arg num "$PROJECT_NUM" \
       --arg id "$PROJECT_ID" \
       --arg url "$USER_PROJECT_URL" \
       --arg repo_url "$PROJECT_URL" \
       '.[$key] = {"number": $num, "id": $id, "url": $url, "repo_url": $repo_url}' "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"

    echo "  📊 Project #$PROJECT_NUM"
    echo ""
}

echo "=== Creating Project Boards ==="
echo ""

create_project "📋 $REPO_NAME Sprint" "sprint"
create_project "🔒 $REPO_NAME Security" "security"
create_project "📊 $REPO_NAME Backlog" "backlog"
create_project "🏗️ $REPO_NAME Architecture" "architecture"
create_project "🐛 $REPO_NAME Bugs" "bugs"
create_project "🔧 $REPO_NAME Tech Debt" "techdebt"
create_project "🚀 $REPO_NAME Releases" "release"

echo "════════════════════════════════════════════"
echo "✅ Project Boards created and linked"
echo ""
echo "📄 Project IDs saved in: $OUTPUT_FILE"
echo ""
echo "🔗 Repository Projects: https://github.com/$REPO/projects"
echo ""
cat "$OUTPUT_FILE" | jq . 2>/dev/null || cat "$OUTPUT_FILE"
echo "════════════════════════════════════════════"
