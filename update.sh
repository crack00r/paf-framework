#!/usr/bin/env bash

# =============================================================================
# PAF Framework - Update Script
# =============================================================================
# Usage: After git pull, run ./update.sh to sync to ~/.paf/
#
# This script:
# 1. Backs up user configurations
# 2. Syncs framework files to ~/.paf/
# 3. Restores user configurations
# 4. Rebuilds plugin if needed
# 5. Verifies installation
# =============================================================================

set -e

# Clean up temp files on exit
trap 'rm -rf /tmp/paf_preserve_$$' EXIT

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
PAF_HOME="${HOME}/.paf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

get_version() {
    local version_file="$1/VERSION"
    if [ -f "$version_file" ]; then
        cat "$version_file" | tr -d '\n\r '
    else
        echo "0.0.0"
    fi
}

compare_versions() {
    # Returns: 0 if equal, 1 if $1 > $2, 2 if $1 < $2
    if [ "$1" = "$2" ]; then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i=0; i<${#ver1[@]}; i++)); do
        if [[ -z ${ver2[i]} ]]; then
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]})); then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]})); then
            return 2
        fi
    done
    return 0
}

# =============================================================================
# VERSION CHECK
# =============================================================================

REPO_VERSION=$(get_version "$SCRIPT_DIR")
INSTALLED_VERSION=$(get_version "$PAF_HOME")

echo ""
echo -e "${CYAN}+==================================================================+${NC}"
echo -e "${CYAN}|              PAF Framework - Update                             |${NC}"
echo -e "${CYAN}+==================================================================+${NC}"
echo ""
echo -e "  Repository version:  ${YELLOW}${REPO_VERSION}${NC}"
echo -e "  Installed version:   ${YELLOW}${INSTALLED_VERSION}${NC}"
echo ""

# Check if update needed
compare_versions "$REPO_VERSION" "$INSTALLED_VERSION"
VERSION_CMP=$?

if [ $VERSION_CMP -eq 0 ]; then
    log_info "Versions are identical. Forcing sync anyway..."
elif [ $VERSION_CMP -eq 2 ]; then
    log_warn "Installed version is NEWER than repository!"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Update cancelled."
        exit 0
    fi
else
    log_info "Updating from ${INSTALLED_VERSION} to ${REPO_VERSION}..."
fi

# =============================================================================
# BACKUP USER CONFIGURATIONS
# =============================================================================

echo ""
log_info "Backing up user configurations..."

BACKUP_DIR="${PAF_HOME}/.backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Files to preserve (user-specific, should not be overwritten)
PRESERVE_FILES=(
    "config/preferences.yaml"
    "COMMS.md"
)

# Files to backup but still update (for reference)
BACKUP_ONLY=(
    ".paf/GITHUB_SYSTEM.md"
)

BACKED_UP=0
for file in "${PRESERVE_FILES[@]}"; do
    if [ -f "$PAF_HOME/$file" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname $file)"
        cp "$PAF_HOME/$file" "$BACKUP_DIR/$file"
        log_success "Backed up: $file"
        BACKED_UP=$((BACKED_UP + 1))
    fi
done

if [ $BACKED_UP -eq 0 ]; then
    log_info "No user configs to backup"
    rmdir "$BACKUP_DIR" 2>/dev/null || true
fi

# =============================================================================
# SYNC FILES
# =============================================================================

echo ""
log_info "Syncing framework files..."

# Check if ~/.paf exists
if [ ! -d "$PAF_HOME" ]; then
    log_error "PAF not installed at ${PAF_HOME}. Run ./install.sh first."
    exit 1
fi

# Sync using rsync if available, otherwise cp
if command -v rsync &> /dev/null; then
    rsync -av --delete \
        --exclude='.git' \
        --exclude='.backup_*' \
        --exclude='COMMS.md' \
        --exclude='config/preferences.yaml' \
        --exclude='plugins/nested-subagent/node_modules' \
        --exclude='plugins/nested-subagent/dist' \
        "$SCRIPT_DIR/" "$PAF_HOME/" > /dev/null
    log_success "Synced with rsync"
else
    # Fallback to cp
    # First, preserve what we need
    TEMP_PRESERVE="/tmp/paf_preserve_$$"
    mkdir -p "$TEMP_PRESERVE"

    for file in "${PRESERVE_FILES[@]}"; do
        if [ -f "$PAF_HOME/$file" ]; then
            mkdir -p "$TEMP_PRESERVE/$(dirname $file)"
            cp "$PAF_HOME/$file" "$TEMP_PRESERVE/$file"
        fi
    done

    # Also preserve plugin build
    if [ -d "$PAF_HOME/plugins/nested-subagent/node_modules" ]; then
        mkdir -p "$TEMP_PRESERVE/plugins/nested-subagent"
        cp -R "$PAF_HOME/plugins/nested-subagent/node_modules" "$TEMP_PRESERVE/plugins/nested-subagent/"
    fi
    if [ -d "$PAF_HOME/plugins/nested-subagent/dist" ]; then
        mkdir -p "$TEMP_PRESERVE/plugins/nested-subagent"
        cp -R "$PAF_HOME/plugins/nested-subagent/dist" "$TEMP_PRESERVE/plugins/nested-subagent/"
    fi

    # Copy new files
    cp -R "$SCRIPT_DIR/"* "$PAF_HOME/"

    # Restore preserved files
    for file in "${PRESERVE_FILES[@]}"; do
        if [ -f "$TEMP_PRESERVE/$file" ]; then
            cp "$TEMP_PRESERVE/$file" "$PAF_HOME/$file"
        fi
    done

    # Restore plugin
    if [ -d "$TEMP_PRESERVE/plugins/nested-subagent/node_modules" ]; then
        cp -R "$TEMP_PRESERVE/plugins/nested-subagent/node_modules" "$PAF_HOME/plugins/nested-subagent/"
    fi
    if [ -d "$TEMP_PRESERVE/plugins/nested-subagent/dist" ]; then
        cp -R "$TEMP_PRESERVE/plugins/nested-subagent/dist" "$PAF_HOME/plugins/nested-subagent/"
    fi

    rm -rf "$TEMP_PRESERVE"
    log_success "Synced with cp"
fi

# =============================================================================
# RESTORE USER CONFIGURATIONS
# =============================================================================

if [ -d "$BACKUP_DIR" ] && [ "$(ls -A $BACKUP_DIR 2>/dev/null)" ]; then
    echo ""
    log_info "Restoring user configurations..."

    for file in "${PRESERVE_FILES[@]}"; do
        if [ -f "$BACKUP_DIR/$file" ]; then
            mkdir -p "$PAF_HOME/$(dirname $file)"
            cp "$BACKUP_DIR/$file" "$PAF_HOME/$file"
            log_success "Restored: $file"
        fi
    done

    # Keep backup for safety
    log_info "Backup kept at: $BACKUP_DIR"
fi

# =============================================================================
# MAKE SCRIPTS EXECUTABLE
# =============================================================================

chmod +x "$PAF_HOME/bin/"* 2>/dev/null || true
chmod +x "$PAF_HOME/scripts/"* 2>/dev/null || true
chmod +x "$PAF_HOME/install.sh" 2>/dev/null || true
chmod +x "$PAF_HOME/update.sh" 2>/dev/null || true

# =============================================================================
# CLEAN OLD PLUGIN CACHE (CRITICAL!)
# Claude Code caches plugins in ~/.claude/plugins/cache/
# Old cached versions WILL BE USED instead of new ones!
# =============================================================================

echo ""
PLUGIN_CACHE="${HOME}/.claude/plugins/cache/paf-nested-subagent"
if [ -d "$PLUGIN_CACHE" ]; then
    log_warn "Found old plugin cache at ${PLUGIN_CACHE}"
    log_info "Removing cached plugin to ensure fresh version is used..."
    rm -rf "$PLUGIN_CACHE"
    log_success "Plugin cache cleared - restart Claude Code after update!"
fi

# =============================================================================
# PLUGIN CHECK
# =============================================================================

echo ""
log_info "Checking plugin..."

PLUGIN_DIR="$PAF_HOME/plugins/nested-subagent"
PLUGIN_MCP="$PLUGIN_DIR/mcp-server"

if [ -d "$PLUGIN_MCP" ]; then
    # Check if plugin needs rebuild
    PLUGIN_NEEDS_BUILD="false"

    if [ ! -f "$PLUGIN_MCP/dist/index.mjs" ]; then
        PLUGIN_NEEDS_BUILD="true"
        log_info "Plugin not built"
    elif [ "$PLUGIN_MCP/package.json" -nt "$PLUGIN_MCP/dist/index.mjs" ]; then
        PLUGIN_NEEDS_BUILD="true"
        log_info "Plugin package.json changed"
    elif [ "$PLUGIN_MCP/src/index.ts" -nt "$PLUGIN_MCP/dist/index.mjs" ] 2>/dev/null; then
        PLUGIN_NEEDS_BUILD="true"
        log_info "Plugin source changed"
    fi

    if [ "$PLUGIN_NEEDS_BUILD" == "true" ]; then
        if command -v node &> /dev/null && command -v npm &> /dev/null; then
            log_info "Rebuilding plugin..."
            cd "$PLUGIN_MCP"

            npm install --silent 2>/dev/null || log_warn "npm install had issues"

            if npm run build --silent 2>/dev/null; then
                log_success "Plugin rebuilt"
            else
                log_warn "Plugin build failed"
            fi

            cd - > /dev/null
        else
            log_warn "Node.js not found - cannot rebuild plugin"
        fi
    else
        log_success "Plugin up to date"
    fi
else
    log_warn "Plugin directory not found"
fi

# =============================================================================
# CLAUDE CODE INTEGRATION (Skills & Commands Sync)
# =============================================================================

echo ""
log_info "Syncing Claude Code integration..."

CLAUDE_HOME="${HOME}/.claude"

# Create ~/.claude directories if needed
mkdir -p "$CLAUDE_HOME/skills"
mkdir -p "$CLAUDE_HOME/commands"

# Sync skills to global ~/.claude/skills/
if [ -d "$PAF_HOME/.claude/skills" ]; then
    cp -R "$PAF_HOME/.claude/skills/"* "$CLAUDE_HOME/skills/" 2>/dev/null || true
    log_success "Skills synced to ~/.claude/skills/"
fi

# Sync commands to global ~/.claude/commands/
if [ -d "$PAF_HOME/commands" ]; then
    cp -R "$PAF_HOME/commands/"* "$CLAUDE_HOME/commands/" 2>/dev/null || true
    log_success "Commands synced to ~/.claude/commands/"
fi

# Verify skills installed
skill_count=$(ls -1 "$CLAUDE_HOME/skills/"paf*.md 2>/dev/null | wc -l | tr -d ' ')
command_count=$(ls -1 "$CLAUDE_HOME/commands/"paf*.md 2>/dev/null | wc -l | tr -d ' ')
log_success "${skill_count} skills, ${command_count} commands synced"

# Update ~/.claude/CLAUDE.md with PAF section
CLAUDE_MD="$CLAUDE_HOME/CLAUDE.md"
PAF_VERSION=$(cat "$PAF_HOME/VERSION" 2>/dev/null || echo "4.4")

if [ -f "$CLAUDE_MD" ]; then
    # Check if PAF section already exists
    if grep -q "## PAF - Project Agent Framework" "$CLAUDE_MD" 2>/dev/null; then
        # Remove old PAF section
        sed '/^## PAF - Project Agent Framework/,/^## [^P]/{ /^## [^P]/!d; }' "$CLAUDE_MD" > "$CLAUDE_MD.tmp"
        if grep -q "## PAF - Project Agent Framework" "$CLAUDE_MD.tmp"; then
            sed '/^## PAF - Project Agent Framework/,$d' "$CLAUDE_MD" > "$CLAUDE_MD.tmp"
        fi
        mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
    fi
fi

# Append updated PAF section
cat >> "$CLAUDE_MD" << PAFSECTION

## PAF - Project Agent Framework v${PAF_VERSION}

This system has access to the **PAF Framework** - an Enterprise Multi-Agent Development System with **38 specialized AI agents** and **automatic orchestration**.

### Available Slash Commands

| Command | Description |
|---------|-------------|
| \`/paf\` | Main orchestrator - Status & options |
| \`/paf-init\` | Initialize PAF in this project |
| \`/paf-cto\` | Start CTO agent (automatic orchestration) |
| \`/paf-status\` | Show detailed project status |
| \`/paf-fix\` | Automatically fix build errors |
| \`/paf-validate\` | Verify build |
| \`/paf-setup-github\` | Set up GitHub labels/boards |
| \`/paf-help\` | Interactive help |
| \`/paf-quickref\` | Quick Reference Card |

### Quick Start

\`\`\`bash
/paf-cto "Review my code"
\`\`\`

### Important Paths

- **Framework:** \`~/.paf/\`
- **Agents:** \`~/.paf/agents/\`
- **Commands:** \`~/.claude/commands/\`
- **Skills:** \`~/.claude/skills/\`

---
PAFSECTION

log_success "CLAUDE.md updated to v${PAF_VERSION}"

# =============================================================================
# VERIFICATION
# =============================================================================

echo ""
log_info "Verifying update..."

ERRORS=0

if [ -f "$PAF_HOME/VERSION" ]; then
    NEW_VERSION=$(get_version "$PAF_HOME")
    log_success "VERSION: ${NEW_VERSION}"
else
    log_error "VERSION file missing"
    ERRORS=$((ERRORS + 1))
fi

if [ -f "$PAF_HOME/SKILL.md" ]; then
    log_success "SKILL.md present"
else
    log_error "SKILL.md missing"
    ERRORS=$((ERRORS + 1))
fi

if [ -f "$PAF_HOME/agents/orchestration/cto.md" ]; then
    log_success "CTO agent present"
else
    log_error "CTO agent missing"
    ERRORS=$((ERRORS + 1))
fi

agent_count=$(find "$PAF_HOME/agents" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
log_success "${agent_count} agents installed"

# =============================================================================
# MIGRATION CHECK
# =============================================================================

echo ""
log_info "Checking for migrations..."

MIGRATIONS_DIR="$PAF_HOME/scripts/migrations"
MIGRATION_LOG="$PAF_HOME/.migrations_applied"

if [ -d "$MIGRATIONS_DIR" ]; then
    touch "$MIGRATION_LOG"

    for migration in "$MIGRATIONS_DIR"/*.sh; do
        if [ -f "$migration" ]; then
            migration_name=$(basename "$migration")
            if ! grep -q "$migration_name" "$MIGRATION_LOG" 2>/dev/null; then
                log_info "Running migration: $migration_name"
                if bash "$migration"; then
                    echo "$migration_name" >> "$MIGRATION_LOG"
                    log_success "Migration complete: $migration_name"
                else
                    log_warn "Migration failed: $migration_name"
                fi
            fi
        fi
    done
else
    log_info "No migrations directory"
fi

# =============================================================================
# SUCCESS
# =============================================================================

echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}+==================================================================+${NC}"
    echo -e "${GREEN}|       PAF Framework updated to v${NEW_VERSION} successfully!         |${NC}"
    echo -e "${GREEN}+==================================================================+${NC}"
else
    echo -e "${YELLOW}+==================================================================+${NC}"
    echo -e "${YELLOW}|       Update completed with ${ERRORS} error(s)                         |${NC}"
    echo -e "${YELLOW}+==================================================================+${NC}"
fi

echo ""
echo -e "${CYAN}What's new in v${NEW_VERSION}:${NC}"
echo ""
if [ -f "$PAF_HOME/CHANGELOG.md" ]; then
    # Show first few lines of latest changelog entry
    head -30 "$PAF_HOME/CHANGELOG.md" | grep -A 10 "^## " | head -12
else
    echo "  See ~/.paf/docs/RELEASE_NOTES_v4.md for details"
fi

echo ""
echo -e "${CYAN}Next steps:${NC}"
echo ""
echo "  1. Restart Claude Code/Desktop to pick up changes"
echo "  2. Run /paf-status in your projects to check for local updates"
echo ""
echo -e "${GREEN}Update complete!${NC}"
echo ""
