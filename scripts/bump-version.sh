#!/bin/bash

# =============================================================================
# PAF Framework - Version Bump Script
# =============================================================================
# Usage:
#   ./scripts/bump-version.sh patch   # 4.1.0 -> 4.1.1 (bug fixes, typos)
#   ./scripts/bump-version.sh minor   # 4.1.0 -> 4.2.0 (new features)
#   ./scripts/bump-version.sh major   # 4.1.0 -> 5.0.0 (breaking changes)
#   ./scripts/bump-version.sh set 4.2.0  # Set specific version
#
# This script:
# 1. Updates VERSION file (Single Source of Truth)
# 2. Updates CHANGELOG.md with new entry
# 3. Updates files that MUST have static versions (Dockerfile, README badge)
# 4. Prepares commit message
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAF_ROOT="$(dirname "$SCRIPT_DIR")"
VERSION_FILE="$PAF_ROOT/VERSION"
CHANGELOG_FILE="$PAF_ROOT/CHANGELOG.md"

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Cross-platform sed in-place edit
sed_inplace() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE" | tr -d '\n\r '
    else
        echo "0.0.0"
    fi
}

# Parse version into components
parse_version() {
    local version="$1"
    IFS='.' read -r MAJOR MINOR PATCH <<< "$version"
}

# =============================================================================
# MAIN LOGIC
# =============================================================================

BUMP_TYPE="${1:-patch}"
CURRENT_VERSION=$(get_current_version)

echo ""
echo -e "${CYAN}+==================================================================+${NC}"
echo -e "${CYAN}|              PAF Framework - Version Bump                       |${NC}"
echo -e "${CYAN}+==================================================================+${NC}"
echo ""
echo -e "  Current version: ${YELLOW}${CURRENT_VERSION}${NC}"
echo ""

# Parse current version
parse_version "$CURRENT_VERSION"

# Calculate new version
case "$BUMP_TYPE" in
    major)
        NEW_MAJOR=$((MAJOR + 1))
        NEW_VERSION="${NEW_MAJOR}.0.0"
        CHANGE_TYPE="MAJOR (Breaking Changes)"
        ;;
    minor)
        NEW_MINOR=$((MINOR + 1))
        NEW_VERSION="${MAJOR}.${NEW_MINOR}.0"
        CHANGE_TYPE="MINOR (New Features)"
        ;;
    patch)
        NEW_PATCH=$((PATCH + 1))
        NEW_VERSION="${MAJOR}.${MINOR}.${NEW_PATCH}"
        CHANGE_TYPE="PATCH (Bug Fixes/Typos)"
        ;;
    set)
        if [ -z "$2" ]; then
            log_error "Usage: bump-version.sh set <version>"
            exit 1
        fi
        NEW_VERSION="$2"
        CHANGE_TYPE="SET (Manual)"
        ;;
    *)
        log_error "Unknown bump type: $BUMP_TYPE"
        echo "Usage: bump-version.sh [major|minor|patch|set <version>]"
        exit 1
        ;;
esac

echo -e "  New version:     ${GREEN}${NEW_VERSION}${NC}"
echo -e "  Change type:     ${CHANGE_TYPE}"
echo ""

# Confirm
read -p "Continue? (y/N): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Cancelled."
    exit 0
fi

# =============================================================================
# 1. UPDATE VERSION FILE
# =============================================================================

log_info "Updating VERSION file..."
echo "$NEW_VERSION" > "$VERSION_FILE"
log_success "VERSION: $NEW_VERSION"

# =============================================================================
# 2. UPDATE CHANGELOG.MD
# =============================================================================

log_info "Updating CHANGELOG.md..."

TODAY=$(date +%Y-%m-%d)

# Create new changelog entry
NEW_ENTRY="## [${NEW_VERSION}] - ${TODAY}

### Changed
- Version bump: ${CURRENT_VERSION} -> ${NEW_VERSION}

<!-- Add your changes above this line -->

"

# Insert after the first heading
if [ -f "$CHANGELOG_FILE" ]; then
    # Create temp file with new entry
    {
        head -n 7 "$CHANGELOG_FILE"
        echo ""
        echo "$NEW_ENTRY"
        tail -n +8 "$CHANGELOG_FILE"
    } > "$CHANGELOG_FILE.tmp"
    mv "$CHANGELOG_FILE.tmp" "$CHANGELOG_FILE"
    log_success "CHANGELOG.md updated"
else
    # Create new changelog
    cat > "$CHANGELOG_FILE" << EOF
# Changelog

All notable changes to PAF Framework will be documented in this file.

Format: [Semantic Versioning](https://semver.org/)

$NEW_ENTRY
## [${CURRENT_VERSION}] - Initial

- Initial release
EOF
    log_success "CHANGELOG.md created"
fi

# =============================================================================
# 3. UPDATE FILES WITH STATIC VERSIONS
# =============================================================================
# These files MUST have the version embedded (can't read from VERSION file)

log_info "Updating files with static versions..."

# Files that need static version updates
# Format: "file:old_pattern:new_pattern"

# Dockerfile
if [ -f "$PAF_ROOT/Dockerfile" ]; then
    sed_inplace "s/LABEL version=\"[0-9.]*\"/LABEL version=\"${NEW_VERSION}\"/" "$PAF_ROOT/Dockerfile"
    rm -f "$PAF_ROOT/Dockerfile.bak"
    log_success "Dockerfile"
fi

# README.md badge
if [ -f "$PAF_ROOT/README.md" ]; then
    sed_inplace "s/Version-[0-9.]*-blue/Version-${NEW_VERSION}-blue/" "$PAF_ROOT/README.md"
    rm -f "$PAF_ROOT/README.md.bak"
    log_success "README.md badge"
fi

# SKILL.md version line
if [ -f "$PAF_ROOT/SKILL.md" ]; then
    sed_inplace "s/\*\*Version:\*\* [0-9.]*/\*\*Version:\*\* ${NEW_VERSION}/" "$PAF_ROOT/SKILL.md"
    rm -f "$PAF_ROOT/SKILL.md.bak"
    log_success "SKILL.md"
fi

# CLAUDE_CODE_CONTEXT.md
if [ -f "$PAF_ROOT/CLAUDE_CODE_CONTEXT.md" ]; then
    sed_inplace "s/\*\*Version:\*\* [0-9.]*/\*\*Version:\*\* ${NEW_VERSION}/" "$PAF_ROOT/CLAUDE_CODE_CONTEXT.md"
    rm -f "$PAF_ROOT/CLAUDE_CODE_CONTEXT.md.bak"
    log_success "CLAUDE_CODE_CONTEXT.md"
fi

# .claude/skills/paf.md
if [ -f "$PAF_ROOT/.claude/skills/paf.md" ]; then
    sed_inplace "s/version: \"[0-9.]*\"/version: \"${NEW_VERSION}\"/" "$PAF_ROOT/.claude/skills/paf.md"
    sed_inplace "s/\*\*Version:\*\* [0-9.]*/\*\*Version:\*\* ${NEW_VERSION}/" "$PAF_ROOT/.claude/skills/paf.md"
    rm -f "$PAF_ROOT/.claude/skills/paf.md.bak"
    log_success ".claude/skills/paf.md"
fi

# Config files with version meta (for backwards compat, but these read VERSION)
CONFIG_FILES=(
    "config/builds.yaml"
    "config/signals.yaml"
    "config/preferences.yaml"
    "config/ai-success-profiles.yaml"
    "config/spawning.yaml"
    "config/agent-tools.yaml"
    "config/output-schemas.yaml"
    "config/hooks.yaml"
)

for config in "${CONFIG_FILES[@]}"; do
    if [ -f "$PAF_ROOT/$config" ]; then
        # Update framework version string
        sed_inplace "s/framework: \"PAF v[0-9.]*\"/framework: \"PAF v${NEW_VERSION%.*}\"/" "$PAF_ROOT/$config"
        # Update last_updated date
        sed_inplace "s/last_updated: \"[0-9-]*\"/last_updated: \"${TODAY}\"/" "$PAF_ROOT/$config"
        rm -f "$PAF_ROOT/$config.bak"
        log_success "$config"
    fi
done

# =============================================================================
# 4. SUMMARY
# =============================================================================

echo ""
echo -e "${GREEN}+==================================================================+${NC}"
echo -e "${GREEN}|              Version Bump Complete!                             |${NC}"
echo -e "${GREEN}+==================================================================+${NC}"
echo ""
echo -e "  ${CURRENT_VERSION} -> ${GREEN}${NEW_VERSION}${NC}"
echo ""
echo -e "${CYAN}Files updated:${NC}"
echo "  - VERSION"
echo "  - CHANGELOG.md"
echo "  - Dockerfile"
echo "  - README.md"
echo "  - SKILL.md"
echo "  - CLAUDE_CODE_CONTEXT.md"
echo "  - .claude/skills/paf.md"
echo "  - config/*.yaml (8 files)"
echo ""
echo -e "${CYAN}Next steps:${NC}"
echo ""
echo "  1. Edit CHANGELOG.md to add your actual changes"
echo "  2. Review changes: git diff"
echo "  3. Commit: git add -A && git commit -m \"chore: bump version to ${NEW_VERSION}\""
echo "  4. Tag: git tag v${NEW_VERSION}"
echo "  5. Push: git push && git push --tags"
echo ""
echo -e "${CYAN}Quick commit:${NC}"
echo ""
echo "  git add -A && git commit -m \"chore: bump version to ${NEW_VERSION}\" && git tag v${NEW_VERSION}"
echo ""
