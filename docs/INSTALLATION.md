# PAF Framework - Installation Guide

Complete installation guide for the PAF Framework.

## 📋 Prerequisites

### Minimum

- **Claude Code** CLI ([Installation](https://docs.anthropic.com/en/docs/claude-code))
- **Operating System:** macOS, Windows, or Linux
- **Storage:** ~50 MB
- **Node.js:** v18+ (for plugin)

### Optional

- Git (for cloning and updates)
- Text editor (for customizations)

## 🚀 One-Click Installation

### Option 1: curl (Recommended)

```bash
curl -sSL https://raw.githubusercontent.com/crack00r/paf-framework/main/install.sh | bash
```

### Option 2: Clone and Install

```bash
git clone https://github.com/crack00r/paf-framework.git
cd paf-framework
./install.sh
```

### Option 3: Manual

```bash
# Clone
git clone https://github.com/crack00r/paf-framework.git

# Copy to ~/.paf
cp -R paf-framework ~/.paf

# Build plugin
cd ~/.paf/plugins/nested-subagent/mcp-server
npm install && npm run build

# Verify
bash ~/.paf/scripts/verify-paf.sh
```

## 🔌 Plugin Configuration

The plugin is automatically registered during installation. If not, add manually:

### Automatic (recommended)

```bash
claude mcp add nested-subagent node ~/.paf/plugins/nested-subagent/mcp-server/dist/index.mjs -s user
```

### Check if registered

```bash
claude mcp list
```

Should display `nested-subagent`.

### Manually remove

```bash
claude mcp remove nested-subagent
```

## ✅ Verification

Run the verification script:

```bash
bash ~/.paf/scripts/verify-paf.sh
```

Expected output:

```
╔══════════════════════════════════════════════════════════════════╗
║          PAF Framework - Installation Verification                  ║
╚══════════════════════════════════════════════════════════════════╝

  ✅ Passed:   35
  ❌ Failed:   0
  ⚠️  Warnings: 0

┌─────────────────────────────────────────────────────────────────┐
│ ✅ PAF INSTALLATION VERIFIED                                       │
└─────────────────────────────────────────────────────────────────┘
```

## 🧪 Test Installation

Enter in Claude:

```
/paf-cto "Quick test" --build=quick
```

You should see:
1. CTO detects signals
2. Agents are spawned
3. Results are aggregated

## 📁 Installation Structure

After installation:

```
~/.paf/
├── agents/
│   ├── orchestration/cto.md
│   ├── perspectives/          # 10 agent files
│   ├── retrospective/george.md
│   └── utility/               # bug-fixer, validator
├── config/
│   ├── builds.yaml
│   ├── signals.yaml
│   ├── preferences.yaml
│   └── ai-success-profiles.yaml
├── workflows/                 # 6 workflow files
├── commands/                  # 11 command files
├── plugins/
│   └── nested-subagent/       # Integrated plugin
├── docs/                      # Documentation
├── scripts/
│   └── verify-paf.sh
├── COMMS.md
├── README.md
├── VERSION
└── SKILL.md
```

## ⚙️ Post-Installation Configuration

### Set language

Edit `~/.paf/config/preferences.yaml`:

```yaml
general:
  language: en  # or 'de'
```

### Set default build

```yaml
build:
  default_build: standard  # or 'quick', 'comprehensive'
```

## 🔄 Update PAF

```bash
cd ~/.paf
git pull
./update.sh
```

The update.sh script:
- Backs up your configurations
- Syncs new files
- Restores your configurations
- Rebuilds plugin if needed

## 🗑️ Uninstallation

Remove PAF completely:

```bash
# PAF Framework
rm -rf ~/.paf

# Claude Skills/Commands
rm -f ~/.claude/skills/paf*.md
rm -f ~/.claude/commands/paf*.md

# Remove PAF section from CLAUDE.md (manually)
```

Remove MCP server: `claude mcp remove nested-subagent`

## ❗ Troubleshooting

### "Command not found"

Make sure you're typing in Claude, not in the terminal.

### Plugin doesn't work

1. Check plugin is built: `ls ~/.paf/plugins/nested-subagent/mcp-server/dist/`
2. Verify config path
3. Restart Claude Code

### Verification fails

1. Check file permissions: `chmod -R 755 ~/.paf`
2. Verify all files are copied

### Agents don't spawn

1. Confirm plugin installation
2. Check MCP server status: `claude mcp list`
3. Try a simpler command first

See [docs/TROUBLESHOOTING.md](TROUBLESHOOTING.md) for more help.

## 📚 Next Steps

1. Read [Quick Start Guide](QUICK_START.md)
2. Try example commands in [README.md](../README.md)
3. Explore [Configuration](CONFIGURATION.md) options
4. Check [FAQ](../FAQ.md) for common questions

---

Need help? Open an issue on GitHub.
