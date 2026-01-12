#!/usr/bin/env bash

# =============================================================================
# PAF Framework - Complete Uninstaller v1.1
# =============================================================================
# Removes:
#   - ~/.paf/                           (Framework directory)
#   - ~/.claude/skills/paf*.md          (PAF skills)
#   - ~/.claude/commands/paf*.md        (PAF commands)
#   - PAF section in ~/.claude/CLAUDE.md
#   - nested-subagent MCP server registration
#   - Plugin cache
#
# Usage:
#   ./uninstall.sh           # Interactive mode
#   ./uninstall.sh --yes     # Skip confirmations (for scripting)
#   ./uninstall.sh -y        # Same as --yes
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
PAF_HOME="${HOME}/.paf"
CLAUDE_HOME="${HOME}/.claude"
AUTO_YES="false"

# Parse arguments
for arg in "$@"; do
    case $arg in
        -y|--yes)
            AUTO_YES="true"
            shift
            ;;
    esac
done

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

# Safe read that works with pipes by reading from /dev/tty
safe_read() {
    local prompt="$1"
    local varname="$2"

    if [ "$AUTO_YES" == "true" ]; then
        # Use indirect variable assignment instead of eval for safety
        local -n ref_var="$varname"
        ref_var="y"
        return 0
    fi

    # Try to read from /dev/tty (works even when script is piped)
    if [ -t 0 ]; then
        # stdin is a terminal
        read -p "$prompt" -n 1 -r "$varname"
        echo ""
    elif [ -e /dev/tty ]; then
        # stdin is not a terminal, but /dev/tty exists
        read -p "$prompt" -n 1 -r "$varname" < /dev/tty
        echo ""
    else
        # No interactive input available
        log_error "Cannot read user input. Run with --yes flag for non-interactive mode:"
        echo ""
        echo "  curl -sSL https://raw.githubusercontent.com/crack00r/paf-framework/main/uninstall.sh | bash -s -- --yes"
        echo ""
        exit 1
    fi
}

# =============================================================================
# HEADER
# =============================================================================

echo ""
echo -e "${CYAN}+==================================================================+${NC}"
echo -e "${CYAN}|           PAF Framework - Complete Uninstaller                  |${NC}"
echo -e "${CYAN}+==================================================================+${NC}"
echo ""

# =============================================================================
# CONFIRMATION
# =============================================================================

echo -e "${YELLOW}This will completely remove PAF Framework from your system:${NC}"
echo ""
echo "  - ${PAF_HOME}/ (Framework directory)"
echo "  - ${CLAUDE_HOME}/skills/paf*.md (PAF skills)"
echo "  - ${CLAUDE_HOME}/commands/paf*.md (PAF commands)"
echo "  - PAF section in ${CLAUDE_HOME}/CLAUDE.md"
echo "  - nested-subagent MCP server registration"
echo "  - Plugin cache"
echo ""
echo -e "${RED}This action cannot be undone!${NC}"
echo ""

if [ "$AUTO_YES" == "true" ]; then
    log_info "Auto-confirm enabled (--yes flag)"
    REPLY="y"
else
    safe_read "Are you sure you want to uninstall PAF? [y/N]: " REPLY
fi

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_info "Uninstallation cancelled."
    exit 0
fi

echo ""

# =============================================================================
# 1. REMOVE MCP SERVER REGISTRATION
# =============================================================================

log_info "Removing MCP server registration..."

if command -v claude &> /dev/null; then
    if claude mcp remove nested-subagent 2>/dev/null; then
        log_success "MCP server 'nested-subagent' removed"
    else
        log_warn "MCP server was not registered or already removed"
    fi
else
    log_warn "Claude Code CLI not found - skipping MCP removal"
fi

# =============================================================================
# 2. REMOVE PLUGIN CACHE
# =============================================================================

log_info "Removing plugin cache..."

PLUGIN_CACHE="${CLAUDE_HOME}/plugins/cache/paf-nested-subagent"
if [ -d "$PLUGIN_CACHE" ]; then
    rm -rf "$PLUGIN_CACHE"
    log_success "Plugin cache removed"
else
    log_info "No plugin cache found"
fi

# =============================================================================
# 3. REMOVE PAF SKILLS
# =============================================================================

log_info "Removing PAF skills..."

SKILLS_DIR="${CLAUDE_HOME}/skills"
if [ -d "$SKILLS_DIR" ]; then
    # Find and remove PAF skill files
    paf_skills=$(find "$SKILLS_DIR" -maxdepth 1 -name "paf*.md" -type f 2>/dev/null || true)
    if [ -n "$paf_skills" ]; then
        skill_count=$(echo "$paf_skills" | wc -l | tr -d ' ')
        rm -f "$SKILLS_DIR"/paf*.md
        log_success "Removed ${skill_count} PAF skill(s)"
    else
        log_info "No PAF skills found"
    fi
else
    log_info "Skills directory does not exist"
fi

# =============================================================================
# 4. REMOVE PAF COMMANDS
# =============================================================================

log_info "Removing PAF commands..."

COMMANDS_DIR="${CLAUDE_HOME}/commands"
if [ -d "$COMMANDS_DIR" ]; then
    # Find and remove PAF command files
    paf_commands=$(find "$COMMANDS_DIR" -maxdepth 1 -name "paf*.md" -type f 2>/dev/null || true)
    if [ -n "$paf_commands" ]; then
        command_count=$(echo "$paf_commands" | wc -l | tr -d ' ')
        rm -f "$COMMANDS_DIR"/paf*.md
        log_success "Removed ${command_count} PAF command(s)"
    else
        log_info "No PAF commands found"
    fi
else
    log_info "Commands directory does not exist"
fi

# =============================================================================
# 5. REMOVE PAF SECTION FROM CLAUDE.MD
# =============================================================================

log_info "Removing PAF section from CLAUDE.md..."

CLAUDE_MD="${CLAUDE_HOME}/CLAUDE.md"
if [ -f "$CLAUDE_MD" ]; then
    # Check if PAF section exists
    if grep -q "## PAF - Project Agent Framework" "$CLAUDE_MD" 2>/dev/null; then
        # Create backup
        cp "$CLAUDE_MD" "$CLAUDE_MD.backup"

        # Remove PAF section (from "## PAF - Project Agent Framework" to next "## " or end of file)
        # Using awk for more reliable multi-line removal
        awk '
            /^## PAF - Project Agent Framework/ { skip=1; next }
            /^## / && skip { skip=0 }
            !skip { print }
        ' "$CLAUDE_MD.backup" > "$CLAUDE_MD"

        # Clean up trailing newlines (portable version)
        # Create temp file without excessive trailing newlines
        awk 'NF {p=1} p' "$CLAUDE_MD" > "$CLAUDE_MD.tmp" && mv "$CLAUDE_MD.tmp" "$CLAUDE_MD"

        # Remove backup
        rm -f "$CLAUDE_MD.backup"

        log_success "PAF section removed from CLAUDE.md"

        # Check if CLAUDE.md is now mostly empty
        content_lines=$(grep -v "^#" "$CLAUDE_MD" 2>/dev/null | grep -v "^>" | grep -v "^-" | grep -v "^$" | wc -l | tr -d ' ')
        if [ "$content_lines" -eq 0 ]; then
            log_info "CLAUDE.md is now empty (only contains header)"

            if [ "$AUTO_YES" == "true" ]; then
                # In auto mode, keep the file
                log_info "Keeping empty CLAUDE.md (use manual removal if desired)"
            else
                safe_read "Do you want to remove the empty CLAUDE.md? [y/N]: " REPLY2
                if [[ $REPLY2 =~ ^[Yy]$ ]]; then
                    rm -f "$CLAUDE_MD"
                    log_success "Empty CLAUDE.md removed"
                fi
            fi
        fi
    else
        log_info "No PAF section found in CLAUDE.md"
    fi
else
    log_info "CLAUDE.md does not exist"
fi

# =============================================================================
# 6. REMOVE ~/.paf DIRECTORY
# =============================================================================

log_info "Removing PAF Framework directory..."

if [ -d "$PAF_HOME" ]; then
    # Get version before removing
    if [ -f "$PAF_HOME/VERSION" ]; then
        PAF_VERSION=$(cat "$PAF_HOME/VERSION" | tr -d '\n\r ')
    else
        PAF_VERSION="unknown"
    fi

    rm -rf "$PAF_HOME"
    log_success "Removed ${PAF_HOME} (was v${PAF_VERSION})"
else
    log_warn "PAF directory ${PAF_HOME} does not exist"
fi

# =============================================================================
# 7. INFO: PROJECT-LOCAL .paf DIRECTORIES
# =============================================================================

echo ""
echo -e "${YELLOW}Note:${NC} PAF may have created .paf/ directories in your projects."
echo "These contain project-specific configs (COMMS.md, project.yaml, etc.)"
echo ""
echo "To find and remove them manually, run:"
echo ""
echo -e "  ${CYAN}find ~/Projects -maxdepth 3 -type d -name '.paf' -exec rm -rf {} +${NC}"
echo ""

# =============================================================================
# SUCCESS MESSAGE
# =============================================================================

echo ""
echo -e "${GREEN}+==================================================================+${NC}"
echo -e "${GREEN}|        PAF Framework has been completely uninstalled           |${NC}"
echo -e "${GREEN}+==================================================================+${NC}"
echo ""
echo "What was removed:"
echo ""
echo "  [x] ~/.paf/ (Framework directory)"
echo "  [x] ~/.claude/skills/paf*.md (PAF skills)"
echo "  [x] ~/.claude/commands/paf*.md (PAF commands)"
echo "  [x] PAF section in ~/.claude/CLAUDE.md"
echo "  [x] nested-subagent MCP server registration"
echo "  [x] Plugin cache"
echo ""
echo -e "${CYAN}To reinstall PAF:${NC}"
echo ""
echo "  curl -sSL https://raw.githubusercontent.com/crack00r/paf-framework/main/install.sh | bash"
echo ""
echo -e "${GREEN}Goodbye!${NC}"
echo ""
