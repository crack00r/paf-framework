#!/usr/bin/env bash

# =============================================================================
# PAF Framework - One-Click Installer
# =============================================================================
# Usage:
#   curl -sSL https://raw.githubusercontent.com/crack00r/paf-framework/main/install.sh | bash
#   OR
#   git clone ... && cd paf-framework && ./install.sh
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
PAF_REPO="https://github.com/crack00r/paf-framework.git"
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

# Get version from VERSION file
get_version() {
    local version_file="$1/VERSION"
    if [ -f "$version_file" ]; then
        cat "$version_file" | tr -d '\n\r '
    else
        echo "unknown"
    fi
}

# =============================================================================
# INSTALLATION MODE DETECTION
# =============================================================================

# Determine if running from cloned repo or via curl
if [ -f "$SCRIPT_DIR/VERSION" ] && [ -d "$SCRIPT_DIR/agents" ]; then
    INSTALL_MODE="local"
    SOURCE_DIR="$SCRIPT_DIR"
    PAF_VERSION=$(get_version "$SOURCE_DIR")
else
    INSTALL_MODE="remote"
    SOURCE_DIR=""
    PAF_VERSION="latest"
fi

# =============================================================================
# HEADER
# =============================================================================

# Show version string only if known, otherwise just show installer name
if [ "$INSTALL_MODE" == "local" ]; then
    VERSION_STR="v${PAF_VERSION}"
else
    VERSION_STR="(latest)"
fi

echo ""
echo -e "${CYAN}+==================================================================+${NC}"
echo -e "${CYAN}|        PAF Framework ${VERSION_STR} - Installer                     |${NC}"
echo -e "${CYAN}|              38 Enterprise AI Agents                            |${NC}"
echo -e "${CYAN}+==================================================================+${NC}"
echo ""

# =============================================================================
# PREREQUISITES CHECK
# =============================================================================

log_info "Checking prerequisites..."

# Check git
if ! command -v git &> /dev/null; then
    log_error "Git is required but not installed."
    echo "   Install: https://git-scm.com/downloads"
    exit 1
fi
log_success "Git found"

# =============================================================================
# EXISTING INSTALLATION CHECK
# =============================================================================

if [ -d "$PAF_HOME" ]; then
    EXISTING_VERSION=$(get_version "$PAF_HOME")
    echo ""
    log_warn "PAF is already installed at ${PAF_HOME}"
    log_warn "Installed version: ${EXISTING_VERSION}"
    log_warn "New version: ${PAF_VERSION}"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  1) Update (keeps user configs like preferences.yaml)"
    echo "  2) Clean install (removes everything)"
    echo "  3) Cancel"
    echo ""
    read -p "Choose [1/2/3]: " -n 1 -r choice
    echo ""

    case $choice in
        1)
            log_info "Updating existing installation..."
            # Backup user configs
            BACKUP_DIR="${PAF_HOME}/.backup_$(date +%Y%m%d_%H%M%S)"
            mkdir -p "$BACKUP_DIR"

            # List of files to preserve
            PRESERVE_FILES=(
                "config/preferences.yaml"
                "COMMS.md"
            )

            for file in "${PRESERVE_FILES[@]}"; do
                if [ -f "$PAF_HOME/$file" ]; then
                    mkdir -p "$BACKUP_DIR/$(dirname "$file")"
                    cp "$PAF_HOME/$file" "$BACKUP_DIR/$file"
                    log_info "Backed up: $file"
                fi
            done

            UPDATE_MODE="true"
            ;;
        2)
            log_warn "Removing existing installation..."
            rm -rf "$PAF_HOME"
            UPDATE_MODE="false"
            ;;
        *)
            log_info "Installation cancelled."
            exit 0
            ;;
    esac
else
    UPDATE_MODE="false"
fi

# =============================================================================
# CLONE OR COPY
# =============================================================================

echo ""
if [ "$INSTALL_MODE" == "remote" ]; then
    log_info "Cloning PAF Framework from GitHub..."
    git clone --depth 1 "$PAF_REPO" "$PAF_HOME" 2>&1 | grep -v "^remote:" | grep -v "^Receiving" | grep -v "^Resolving" || true
    PAF_VERSION=$(get_version "$PAF_HOME")
else
    log_info "Installing from local directory..."
    if [ "$UPDATE_MODE" == "true" ]; then
        # Selective copy for update - don't overwrite user data
        rsync -av --exclude='.git' --exclude='COMMS.md' "$SOURCE_DIR/" "$PAF_HOME/" 2>/dev/null || {
            cp -R "$SOURCE_DIR/"* "$PAF_HOME/" 2>/dev/null || true
            # Also copy hidden directories (like .claude/)
            cp -R "$SOURCE_DIR/".??* "$PAF_HOME/" 2>/dev/null || true
        }
    else
        mkdir -p "$PAF_HOME"
        cp -R "$SOURCE_DIR/"* "$PAF_HOME/"
        # Also copy hidden directories (like .claude/)
        cp -R "$SOURCE_DIR/".??* "$PAF_HOME/" 2>/dev/null || true
    fi
fi
log_success "Installed to ${PAF_HOME}"

# =============================================================================
# RESTORE BACKUPS (if updating)
# =============================================================================

if [ "$UPDATE_MODE" == "true" ] && [ -d "$BACKUP_DIR" ]; then
    log_info "Restoring user configurations..."
    for file in "${PRESERVE_FILES[@]}"; do
        if [ -f "$BACKUP_DIR/$file" ]; then
            cp "$BACKUP_DIR/$file" "$PAF_HOME/$file"
            log_success "Restored: $file"
        fi
    done
    rm -rf "$BACKUP_DIR"
fi

# =============================================================================
# SETUP SCRIPTS
# =============================================================================

log_info "Setting up scripts..."
chmod +x "$PAF_HOME/bin/"* 2>/dev/null || true
chmod +x "$PAF_HOME/scripts/"* 2>/dev/null || true
chmod +x "$PAF_HOME/install.sh" 2>/dev/null || true
chmod +x "$PAF_HOME/update.sh" 2>/dev/null || true
log_success "Scripts ready"

# =============================================================================
# INITIAL FILES
# =============================================================================

# Create COMMS.md from template if not exists
if [ ! -f "$PAF_HOME/COMMS.md" ]; then
    if [ -f "$PAF_HOME/templates/COMMS.md" ]; then
        cp "$PAF_HOME/templates/COMMS.md" "$PAF_HOME/COMMS.md"
        log_success "Created COMMS.md from template"
    fi
fi

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
    log_success "Plugin cache cleared"
fi

# =============================================================================
# PLUGIN INSTALLATION (nested-subagent)
# Based on: https://github.com/gruckion/nested-subagent (MIT License)
# =============================================================================

echo ""
log_info "Setting up nested-subagent plugin..."

PLUGIN_DIR="$PAF_HOME/plugins/nested-subagent"
PLUGIN_MCP="$PLUGIN_DIR/mcp-server"

if [ -d "$PLUGIN_MCP" ]; then
    if command -v node &> /dev/null && command -v npm &> /dev/null; then
        NODE_VERSION=$(node -v)
        log_info "Node.js ${NODE_VERSION} found, building plugin..."

        cd "$PLUGIN_MCP"

        # Install dependencies
        if npm install --silent 2>/dev/null; then
            log_success "Plugin dependencies installed"
        else
            log_warn "Plugin dependencies installation failed (non-critical)"
        fi

        # Build plugin
        if npm run build --silent 2>/dev/null; then
            log_success "Plugin built successfully"

            # Check if built correctly
            if [ -f "$PLUGIN_MCP/dist/index.mjs" ]; then
                log_success "Plugin ready at: $PLUGIN_MCP/dist/index.mjs"
                PLUGIN_READY="true"
            else
                log_warn "Plugin build incomplete"
                PLUGIN_READY="false"
            fi
        else
            log_warn "Plugin build failed (will need manual setup)"
            PLUGIN_READY="false"
        fi

        cd - > /dev/null
    else
        log_warn "Node.js not found - plugin requires manual installation"
        log_info "Install Node.js 18+ and run: cd ~/.paf/plugins/nested-subagent/mcp-server && npm install && npm run build"
        PLUGIN_READY="false"
    fi
else
    log_warn "Plugin directory not found"
    PLUGIN_READY="false"
fi

# =============================================================================
# CLAUDE CODE INTEGRATION (Skills & Commands)
# =============================================================================

echo ""
log_info "Setting up Claude Code integration..."

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
log_success "${skill_count} skills, ${command_count} commands registered"

# Update ~/.claude/CLAUDE.md with PAF section
CLAUDE_MD="$CLAUDE_HOME/CLAUDE.md"
PAF_VERSION=$(cat "$PAF_HOME/VERSION" 2>/dev/null || echo "4.4")

if [ -f "$CLAUDE_MD" ]; then
    # Check if PAF section already exists
    if grep -q "## PAF - Project Agent Framework" "$CLAUDE_MD" 2>/dev/null; then
        # Remove old PAF section and add new one
        # Create temp file without PAF section
        sed '/^## PAF - Project Agent Framework/,/^## [^P]/{ /^## [^P]/!d; }' "$CLAUDE_MD" > "$CLAUDE_MD.tmp"
        # If the file ends with PAF section (no following ##), remove it differently
        if grep -q "## PAF - Project Agent Framework" "$CLAUDE_MD.tmp"; then
            sed '/^## PAF - Project Agent Framework/,$d' "$CLAUDE_MD" > "$CLAUDE_MD.tmp"
        fi
        mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"
        log_info "Updating PAF section in CLAUDE.md..."
    else
        log_info "Adding PAF section to CLAUDE.md..."
    fi
else
    # Create new CLAUDE.md
    log_info "Creating ~/.claude/CLAUDE.md..."
    cat > "$CLAUDE_MD" << 'HEADER'
# Global Claude Code Configuration

> This file is automatically loaded in EVERY project.

---

HEADER
fi

# Append PAF section
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

### The 38 Agents

| Category | Agents |
|-----------|---------|
| **Orchestration (1)** | CTO |
| **Discovery (3)** | Ben, Maya, Iris |
| **Planning (3)** | Sophia, Michael, Kai |
| **Implementation (5)** | Sarah, Anna, Chris, Dan, Tina |
| **Review (4)** | Rachel, Scanner, Stan, Perf |
| **Deployment (3)** | Tony, Miggy, Rel |
| **Operations (3)** | Inci, Monitor, Feedback |
| **Perspectives (10)** | Alex, Emma, Sam, David, Max, Luna, Tom, Nina, Leo, Ava |
| **Retrospective (3)** | George, Otto, Docu |
| **Utility (3)** | Bug-Fixer, Gideon, Validator |

---
PAFSECTION

log_success "CLAUDE.md updated with PAF v${PAF_VERSION}"

# =============================================================================
# VERIFICATION
# =============================================================================

echo ""
log_info "Verifying installation..."

ERRORS=0

# Check core files
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

if [ -f "$PAF_HOME/VERSION" ]; then
    log_success "VERSION file present ($(cat $PAF_HOME/VERSION))"
else
    log_error "VERSION file missing"
    ERRORS=$((ERRORS + 1))
fi

# Count agents (exclude helper files)
agent_count=$(find "$PAF_HOME/agents" -name "*.md" -type f ! -name "AGENT_PROLOGUE.md" ! -name "spawn-templates.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$agent_count" -eq 38 ]; then
    log_success "${agent_count} agents installed"
elif [ "$agent_count" -ge 30 ]; then
    log_warn "${agent_count} agents found (expected 38)"
else
    log_warn "Only ${agent_count} agents found (expected 38)"
fi

# =============================================================================
# CLAUDE CODE MCP CONFIG
# =============================================================================

echo ""
if [ "$PLUGIN_READY" == "true" ]; then
    log_info "Setting up MCP server for Claude Code..."

    # Try to auto-add MCP server
    if command -v claude &> /dev/null; then
        # Remove old entry if exists, then add new
        claude mcp remove nested-subagent 2>/dev/null || true
        if claude mcp add nested-subagent node "$PAF_HOME/plugins/nested-subagent/mcp-server/dist/index.mjs" -s user 2>/dev/null; then
            log_success "MCP server 'nested-subagent' registered globally with Claude Code"
        else
            log_warn "Could not auto-register MCP server. Add manually:"
            echo ""
            echo -e "    ${YELLOW}claude mcp add nested-subagent node $PAF_HOME/plugins/nested-subagent/mcp-server/dist/index.mjs -s user${NC}"
            echo ""
        fi
    else
        log_info "Claude Code CLI not found. Add MCP server manually after installing Claude Code:"
        echo ""
        echo -e "    ${YELLOW}claude mcp add nested-subagent node $PAF_HOME/plugins/nested-subagent/mcp-server/dist/index.mjs -s user${NC}"
        echo ""
    fi
fi

# =============================================================================
# SUCCESS MESSAGE
# =============================================================================

echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}+==================================================================+${NC}"
    echo -e "${GREEN}|          PAF Framework v${PAF_VERSION} installed successfully!         |${NC}"
    echo -e "${GREEN}+==================================================================+${NC}"
else
    echo -e "${YELLOW}+==================================================================+${NC}"
    echo -e "${YELLOW}|    PAF Framework installed with ${ERRORS} warning(s)                    |${NC}"
    echo -e "${YELLOW}+==================================================================+${NC}"
fi

echo ""
echo -e "${CYAN}Quick Start:${NC}"
echo ""
echo "  In Claude Code, type:"
echo ""
echo -e "    ${YELLOW}/paf-cto \"Review my code\"${NC}"
echo ""
echo -e "${CYAN}Commands:${NC}"
echo ""
echo "    /paf-cto          - Start CTO orchestrator"
echo "    /paf-init         - Initialize PAF in a project"
echo "    /paf-status       - Show status"
echo "    /paf-help         - Interactive help"
echo ""
echo -e "${CYAN}Updates:${NC}"
echo ""
echo "    cd ~/.paf && git pull && ./update.sh"
echo ""
echo -e "${CYAN}Verify:${NC}"
echo ""
echo "    bash ~/.paf/scripts/verify-paf.sh"
echo ""
echo -e "${GREEN}Enjoy PAF!${NC}"
echo ""
