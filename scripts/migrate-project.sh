#!/bin/bash

# =============================================================================
# PAF Framework - Project Migration Script
# =============================================================================
# Usage: bash ~/.paf/scripts/migrate-project.sh [project_path]
#
# This script updates a project's .paf/ directory to match the global
# PAF installation. It preserves project-specific files.
#
# Called by: CTO when detecting version mismatch
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PAF_HOME="${HOME}/.paf"
PROJECT_DIR="${1:-.}"
PROJECT_PAF="$PROJECT_DIR/.paf"

# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

log_info() {
    echo -e "${BLUE}[PAF]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PAF]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[PAF]${NC} $1"
}

log_error() {
    echo -e "${RED}[PAF]${NC} $1"
}

# Cross-platform sed in-place edit
sed_inplace() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

get_version() {
    local version_file="$1/VERSION"
    if [ -f "$version_file" ]; then
        cat "$version_file" | tr -d '\n\r '
    else
        echo "0.0.0"
    fi
}

# =============================================================================
# CHECKS
# =============================================================================

# Check global installation
if [ ! -d "$PAF_HOME" ]; then
    log_error "PAF not installed globally at ${PAF_HOME}"
    exit 1
fi

GLOBAL_VERSION=$(get_version "$PAF_HOME")

# Check project directory
if [ ! -d "$PROJECT_DIR" ]; then
    log_error "Project directory not found: $PROJECT_DIR"
    exit 1
fi

# Get project version
if [ -d "$PROJECT_PAF" ]; then
    PROJECT_VERSION=$(get_version "$PROJECT_PAF")
    log_info "Project PAF version: ${PROJECT_VERSION}"
else
    PROJECT_VERSION="0.0.0"
    log_info "No .paf directory found - will initialize"
fi

log_info "Global PAF version: ${GLOBAL_VERSION}"

# =============================================================================
# VERSION COMPARISON
# =============================================================================

if [ "$PROJECT_VERSION" = "$GLOBAL_VERSION" ]; then
    log_success "Project is already up to date (v${PROJECT_VERSION})"
    exit 0
fi

log_info "Updating project from v${PROJECT_VERSION} to v${GLOBAL_VERSION}..."

# =============================================================================
# BACKUP PROJECT-SPECIFIC FILES
# =============================================================================

BACKUP_DIR="$PROJECT_PAF/.backup_$(date +%Y%m%d_%H%M%S)"

# Files that should NOT be overwritten
PROJECT_SPECIFIC=(
    "COMMS.md"
    "project.yaml"
    "GITHUB_SYSTEM.md"
    "reviews"
)

if [ -d "$PROJECT_PAF" ]; then
    mkdir -p "$BACKUP_DIR"

    for item in "${PROJECT_SPECIFIC[@]}"; do
        if [ -e "$PROJECT_PAF/$item" ]; then
            cp -R "$PROJECT_PAF/$item" "$BACKUP_DIR/"
            log_info "Backed up: $item"
        fi
    done
fi

# =============================================================================
# CREATE/UPDATE .paf STRUCTURE
# =============================================================================

mkdir -p "$PROJECT_PAF"
mkdir -p "$PROJECT_PAF/reviews"

# Copy templates from global
if [ -d "$PAF_HOME/templates" ]; then
    # Only copy if not exists (don't overwrite)
    if [ ! -f "$PROJECT_PAF/COMMS.md" ] && [ -f "$PAF_HOME/templates/COMMS.md" ]; then
        cp "$PAF_HOME/templates/COMMS.md" "$PROJECT_PAF/COMMS.md"
        log_success "Created COMMS.md from template"
    fi

    if [ ! -f "$PROJECT_PAF/PROCESS.md" ] && [ -f "$PAF_HOME/templates/PROCESS.md" ]; then
        cp "$PAF_HOME/templates/PROCESS.md" "$PROJECT_PAF/PROCESS.md"
        log_success "Created PROCESS.md from template"
    fi
fi

# =============================================================================
# RESTORE PROJECT-SPECIFIC FILES
# =============================================================================

if [ -d "$BACKUP_DIR" ]; then
    for item in "${PROJECT_SPECIFIC[@]}"; do
        if [ -e "$BACKUP_DIR/$item" ]; then
            cp -R "$BACKUP_DIR/$item" "$PROJECT_PAF/"
            log_success "Restored: $item"
        fi
    done
fi

# =============================================================================
# UPDATE VERSION FILE
# =============================================================================

echo "$GLOBAL_VERSION" > "$PROJECT_PAF/VERSION"
log_success "Updated VERSION to ${GLOBAL_VERSION}"

# =============================================================================
# UPDATE project.yaml WITH VERSION
# =============================================================================

if [ -f "$PROJECT_PAF/project.yaml" ]; then
    # Check if paf_version exists
    if grep -q "paf_version:" "$PROJECT_PAF/project.yaml"; then
        # Update existing version
        sed_inplace "s/paf_version:.*/paf_version: \"${GLOBAL_VERSION}\"/" "$PROJECT_PAF/project.yaml"
        rm -f "$PROJECT_PAF/project.yaml.bak"
    else
        # Add paf_version after first line
        sed_inplace "1a\\
paf_version: \"${GLOBAL_VERSION}\"
" "$PROJECT_PAF/project.yaml"
        rm -f "$PROJECT_PAF/project.yaml.bak"
    fi
    log_success "Updated project.yaml with PAF version"
else
    # Create minimal project.yaml
    cat > "$PROJECT_PAF/project.yaml" << EOF
# PAF Project Configuration
# Generated by PAF v${GLOBAL_VERSION}

project:
  name: "$(basename $PROJECT_DIR)"
  paf_version: "${GLOBAL_VERSION}"
  created: "$(date +%Y-%m-%d)"

# GitHub Integration (set by Gideon)
github:
  initialized: false

# Project Preferences (override global)
preferences:
  language: "auto"
  default_build: "standard"
EOF
    log_success "Created project.yaml"
fi

# =============================================================================
# CLEANUP OLD BACKUPS (keep last 3)
# =============================================================================

if [ -d "$PROJECT_PAF" ]; then
    cd "$PROJECT_PAF"
    ls -dt .backup_* 2>/dev/null | tail -n +4 | xargs rm -rf 2>/dev/null || true
    cd - > /dev/null
fi

# =============================================================================
# SUCCESS
# =============================================================================

echo ""
log_success "Project updated to PAF v${GLOBAL_VERSION}"
echo ""
echo "  Updated files:"
echo "    - .paf/VERSION"
echo "    - .paf/project.yaml"
echo ""
echo "  Preserved files:"
echo "    - .paf/COMMS.md (if existed)"
echo "    - .paf/GITHUB_SYSTEM.md (if existed)"
echo "    - .paf/reviews/ (if existed)"
echo ""
