# Changelog

All notable changes to PAF Framework will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [4.4.0] - 2026-01-12

### Added

- **Language-Agnostic Agent Improvements**
  - Rachel: Integration Validation for any programming language (C++, Python, Rust, Go, etc.)
  - Tina: Smoke Test Protocol works with any technology stack
  - Sarah: Cross-File Awareness with examples for Python, C++, Rust
  - Validator: Multi-language integration checks
  - Leo: Documentation generation during development (not just retrospective)
  - Tony: Post-deploy verification protocol

### Changed

- **Complete English Translation** - All German text removed from entire codebase
- **Semantic Understanding** - Removed pattern-based signal detection
  - CTO now uses Claude's semantic understanding instead of keyword matching
  - signals.yaml simplified to pure documentation (no keywords/patterns)
  - builds.yaml cleaned up (no signal detection arrays)

### Fixed

- **Post-Mortem Driven Fixes** - Based on real-world Snake-7000 project analysis
  - Agents now check file dependencies across all languages (not just HTML/CSS/JS)
  - Integration validation catches missing symbols, unresolved imports
  - Dead code detection works language-agnostically
  - Smoke testing verifies builds and core functionality


## [4.3.1] - 2026-01-12

### Added

- **Complete Uninstall Script** (`uninstall.sh`)
  - Removes ~/.paf/, skills, commands, CLAUDE.md section, MCP server
  - Supports `--yes` flag for non-interactive mode
  - Works via `curl | bash` pipe execution

- **Intelligent Gideon Recovery** in paf-init
  - Automatic recovery when Gideon times out
  - Checks existing labels/boards/templates before creating
  - No duplicates, no user interaction needed

### Fixed

- **Gideon Project Boards** - Now creates repo-specific boards
  - Board titles include repo name: `{REPO} - Sprint Board`
  - Boards linked to repo via `gh project link`
  - Each repo gets its own 7 dedicated boards (no shared boards)

- **paf-init Fixes**
  - `git init -b main` (correct default branch)
  - GitHub username detection via `gh api user -q .login`
  - Removed `--push` from `gh repo create` (push after commit)
  - Gideon timeout increased to 10 minutes

- **Agent Count** - Fixed count in verify-paf.sh and install.sh
  - Excludes AGENT_PROLOGUE.md and spawn-templates.md
  - Now correctly shows 38 agents


## [4.3.0] - 2026-01-12

### Added

- **Option B: Flat Implementation Structure** - CTO spawns all Implementation Agents directly
  - Sarah coordinates but does NOT spawn team members
  - Enables true parallel execution without hierarchical bottleneck
  - Avoids 4-agent limit conflicts during implementation phase

### Changed

- **Config Consistency** - All configs now have consistent schema versions and last_updated fields
- **AGENT_PROTOCOL.md** - Corrected label count from ~50 to 91

### Fixed

- **spawning.yaml** - Sarah now correctly marked as `can_spawn: false`
- **sarah.md** - Activation prompt aligned with Option B (coordinate, not spawn)
- **Duplicate Cleanup** - Removed 6 duplicate workflows and 2 duplicate issue templates


## [4.2.0] - 2026-01-12

### Added

- **Mandatory Gideon Bootstrap** - CTO must run Gideon first if GITHUB_SYSTEM.md missing
  - New "SCHRITT 0" in paf-cto skill - blocking check before any agent spawning
  - paf-init now spawns Gideon instead of legacy shell scripts
  - Ensures GitHub integration is always properly configured

- **MCP Server Debug Logging** (v1.9.0)
  - Pre-spawn diagnostics (PID, API key, file descriptors)
  - Spawn timing and process state logging
  - Heartbeat monitoring every 30s for first 5 minutes
  - All logs written to `/tmp/paf-nested-subagent-debug.log`

- **TaskList Auto-Cleanup** (v1.10.0)
  - Automatic purge of tasks older than 24 hours
  - Filtered display: hide completed/failed tasks older than 2 hours
  - Tasks sorted by status (running first) then recency

- **GitHub Integration in Agent Prologue** (v1.11.0)
  - Each spawned agent receives their GitHub prefix, label, and board number
  - Agents get gh commands ready to use for issue creation
  - Agent-specific configuration (SEC for alex, PERF for emma, etc.)

### Changed

- **MCP Server** - Version bumped to 1.12.0
  - Comprehensive debug logging for troubleshooting
  - Better task lifecycle management
  - GitHub integration baked into agent prompts

- **paf-cto Skill** - Complete rewrite of workflow section
  - Explicit Gideon bootstrap check as STEP 0
  - Clear blocking behavior until GITHUB_SYSTEM.md exists
  - Updated workflow to emphasize Gideon-first approach

- **paf-init Skill** - GitHub setup now uses Gideon
  - Replaced legacy shell scripts with Gideon agent
  - Consistent setup experience across init and cto

### Fixed

- **Race Condition** in concurrent agent spawning
  - Log file preservation between spawns
  - Proper file descriptor handling

- **Agent Timeout** - Increased default from 10 to 20 minutes
  - Complex tasks no longer timeout prematurely

- **Agent Role Descriptions** - Aligned across all config files

- **Plugin Cache** - Cleared in installer and updater
  - Prevents stale code from being used after updates


## [4.1.3] - 2026-01-11

### Fixed

- **HARD LIMIT for Concurrent Agents** - Maximum 4 agents simultaneously
  - Prevents system overload and Exit Code 143 errors
  - Serialized spawning with limit checks

- **Variable Naming** - Use correct backgroundTasks variable name


## [4.1.2] - 2026-01-10

### Added

- **COMMS.md @MENTION Syntax** - Complete documentation for 40 agent mentions
  - All 38 agents + @ORCHESTRATOR alias + @AGENT generic
  - Usage examples for handoffs, blocking, and direct communication
  - ISO8601 timestamp format documentation

- **CTO VETO-Recht** - Security and Accessibility agents can block releases
  - Alex (Security) VETO for critical security findings
  - Luna (A11Y) VETO for WCAG AA failures
  - Clear priority order and blocking workflow

- **Utility Agents in ai-success-profiles.yaml**
  - CTO (orchestration_agents section)
  - Bug-Fixer, Validator, Gideon (utility_agents section)
  - All 38 agents now fully documented with success rates

### Fixed

- **Cross-platform sed compatibility** in shell scripts
  - Added `sed_inplace()` function to `bump-version.sh`
  - Added `sed_inplace()` function to `migrate-project.sh`
  - Fixes macOS vs Linux `sed -i` incompatibility

- **GITHUB_SYSTEM_TEMPLATE.md** - Complete Issue Prefix Table
  - Added Bug-Fixer (BUG), Validator (VAL), Gideon (SETUP) prefixes
  - Updated Agent-zu-Board Quick Reference
  - Now lists all 38 agents

- **Label count consistency** across documentation
  - `commands/paf-setup-github.md`: 80/52 → 91 labels
  - `.claude/skills/paf-setup-github.md`: 73 → 91 labels
  - Matches actual count in `config/labels.yaml`

### Changed

- **V4 Comprehensive Audit** with 20 specialized agents
  - install.sh, update.sh, CTO, Nested Plugin audits
  - Documentation, COMMS, Config, Scripts audits
  - GitHub Issues, Projects, Workflows audits
  - Security, Cross-Reference, User Experience audits


## [4.1.1] - 2026-01-10

### Added

- **Update System** - Complete framework update mechanism
  - `VERSION` file as Single Source of Truth
  - `update.sh` for framework updates after git pull
  - `scripts/migrate-project.sh` for project-level updates
  - `scripts/bump-version.sh` for semantic versioning
  - CTO automatic version check at startup
  - Project-level `.paf/VERSION` tracking

- **Documentation**
  - `docs/VERSIONING.md` - Complete versioning guide
  - README.md update section
  - Improved installation documentation

### Changed

- **install.sh** - Complete rewrite with:
  - Dynamic version from VERSION file
  - Plugin auto-installation (npm install && npm run build)
  - Backup/restore for updates
  - Better error handling

- **verify-paf.sh** - Dynamic version reading, improved checks

- **CTO Agent** - Added PAF Version Check section
  - Compares global vs local versions
  - Offers update on mismatch
  - Auto-update for comprehensive/autonomous mode

### Fixed

- Version consistency across all files (4.0 -> 4.1)
- Utility Agents count (2 -> 3, including Gideon)
- Sarah's role as Level 2 Team Lead in hierarchy
- Agent naming: `bugfix` -> `bug-fixer`
- Build preset agent counts in documentation

## [4.1.0] - 2026-01-09

### Added

- **🐙 GitHub Integration** - Complete GitHub lifecycle management
  - **Gideon** - New Setup Agent that runs once per repository
  - **91 Labels** - Type, priority, phase, agent, category, status
  - **7 Project Boards** - Sprint, Security, Backlog, Architecture, Bug, Tech Debt, Release
  - **Issue Templates** - Agent Finding, Bug, Feature, Incident, ADR, Task, Retro
  - **GitHub Actions** - Auto-triage, stale issues, sprint metrics, release notes
  - **Issue Prefixes** - SEC, PERF, UX, MAINT, A11Y, COST, DOC, IDEA per agent
  - **Automatic Setup** - CTO detects missing config and spawns Gideon
  - **GITHUB_SYSTEM.md** - Generated per-repo with all board IDs and commands

- **Agent Updates** - All 38 agents now have GitHub Integration section
  - Issue creation commands
  - Board assignments
  - Label configuration
  - Prefix definitions

- **New Command** - `/paf-setup-github` for manual GitHub setup

- **Documentation**
  - `docs/GITHUB_WORKFLOW.md` - Complete workflow documentation
  - Updated AGENT_PROTOCOL.md with GitHub section
  - Updated SKILL.md with GitHub section

### Changed

- **spawn-templates.md** - Added GitHub instructions to all templates
- **CTO** - Bootstrap logic to check for GITHUB_SYSTEM.md
- **COMMS.md** - Added Gideon section

## [4.0.0] - 2025-01-09

### Added

- **Build Presets** - Three build presets (quick, standard, comprehensive) for different review depths
- **Signal Detection** - Automatic workflow and build detection from natural language
- **AI Success Profiles** - Agent performance metrics for optimization
- **Utility Agents** - Bug Fixer and Validator agents
- **Command System** - `/paf-help`, `/paf-fix`, `/paf-validate`, `/paf-status`, `/paf-quickref`
- **Quality Gates** - Build-aware quality checks
- **COMMS.md** - Inter-agent communication system
- **George Aggregator** - Centralized findings aggregation
- **Verification Script** - Installation verification with `verify-paf.sh`

### Changed

- **Agent Specializations** - All 10 perspective agents now have generic enterprise roles:
  - Alex: Security 🔒
  - Emma: Performance ⚡
  - Sam: UX 🎨
  - David: Scalability 🔀
  - Max: Maintainability 🔧
  - Luna: Accessibility ♿
  - Tom: Cost 💰
  - Nina: Triage 🎯
  - Leo: Documentation 📚
  - Ava: Innovation 💡

- **CTO Agent** - Enhanced with build awareness and signal detection
- **Configuration Structure** - New YAML-based configuration system
- **Documentation** - Complete rewrite for clarity

### Fixed

- Agent-documentation consistency across all files
- Workflow-to-agent mappings
- Signal detection patterns for German and English

## [3.1.0] - 2025-01-08

### Added

- Initial integration plan for "The System" (ASDO) features
- Basic workflow definitions
- Perspective agents concept

## [3.0.0] - 2025-01-07

### Added

- Multi-agent architecture
- CTO orchestrator
- Basic perspective agents
- COMMS.md communication

## [2.0.0] - 2024-12

### Added

- Single-agent review system
- Basic code analysis

## [1.0.0] - 2024-11

### Added

- Initial release
- Basic code review functionality
