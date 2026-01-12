# PAF Skills Index

This directory contains hot-reloadable Claude Code skills for PAF.

## Available Skills (9)

| Skill | File | Description |
|-------|------|-------------|
| /paf | paf.md | Main PAF orchestrator skill |
| /paf-cto | paf-cto.md | CTO agent - main orchestrator |
| /paf-init | paf-init.md | Project initialization with Git/GitHub |
| /paf-fix | paf-fix.md | Auto-fix build errors |
| /paf-validate | paf-validate.md | Build verification |
| /paf-status | paf-status.md | Project status |
| /paf-setup-github | paf-setup-github.md | GitHub integration setup |
| /paf-help | paf-help.md | Interactive help system |
| /paf-quickref | paf-quickref.md | Quick reference card |

## Commands Documentation

Command documentation is also available in `~/.paf/commands/`:

| Command | Description |
|---------|-------------|
| /paf-fix | Auto-fix build errors (TypeScript, ESLint, etc.) |
| /paf-validate | Build verification with different modes |
| /paf-status | Detailed project status report |
| /paf-help | Interactive help for all PAF commands |
| /paf-quickref | Compact quick reference card |
| /paf-setup-github | Manual GitHub setup trigger |

## Hot-Reload

Skills in this directory are automatically reloaded when modified.
No restart required.

## Usage

```bash
# Main orchestrator
/paf-cto "Review my authentication code" --build=standard

# Initialize a new project
/paf-init

# Quick help
/paf-help
```

## Structure

```
~/.claude/
├── skills/               # Hot-reloadable skills (9 total)
│   ├── index.md          # This file
│   ├── paf.md            # Main PAF skill
│   ├── paf-cto.md        # CTO orchestrator
│   ├── paf-init.md       # Project initialization
│   ├── paf-fix.md        # Auto-fix errors
│   ├── paf-validate.md   # Build verification
│   ├── paf-status.md     # Project status
│   ├── paf-setup-github.md # GitHub setup
│   ├── paf-help.md       # Interactive help
│   └── paf-quickref.md   # Quick reference
│
├── commands/             # Command documentation
│   ├── paf-fix.md
│   ├── paf-validate.md
│   ├── paf-status.md
│   └── ...
│
└── CLAUDE.md             # Global user instructions
```

## Installation

Skills and commands are installed by:
```bash
~/.paf/install.sh
```

And updated by:
```bash
cd ~/.paf && git pull && ./update.sh
```
