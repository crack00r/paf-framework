# PAF Framework - Troubleshooting Guide

Solutions for common problems with PAF.

## 🔍 Quick Diagnostics

Run first:

```bash
bash ~/.paf/scripts/verify-paf.sh
```

Checks:
- ✅ Directory structure
- ✅ Configuration files
- ✅ Agent files
- ✅ Workflows
- ✅ Commands

---

## 🔌 Plugin Issues

### "Plugin not found" or "MCP error"

**Symptoms:**
- CTO cannot spawn agents
- Error mentions MCP or Plugin

**Solutions:**

1. **Check plugin build:**
   ```bash
   ls ~/.paf/plugins/nested-subagent/mcp-server/dist/
   # Should show index.mjs
   ```

2. **Check MCP server registration:**

   ```bash
   # Check if plugin is registered
   claude mcp list

   # If not present, add:
   claude mcp add nested-subagent node /Users/YOUR_USERNAME/.paf/plugins/nested-subagent/mcp-server/dist/index.mjs -s user
   ```

3. **Restart Claude Code** (end session and start new one)

### Plugin crashes or hangs

**Solutions:**

1. **Check Node.js version:**
   ```bash
   node --version
   # Requires v18+
   ```

2. **Reinstall plugin:**
   ```bash
   cd ~/.paf/plugins/nested-subagent/mcp-server
   rm -rf node_modules dist
   npm install
   npm run build
   ```

3. **Check permissions:**
   ```bash
   chmod +x ~/.paf/plugins/nested-subagent/mcp-server/dist/index.mjs
   ```

---

## 🤖 Agent Issues

### Agents don't spawn

**Symptoms:**
- CTO starts but no Perspective agents run
- Review seems incomplete

**Solutions:**

1. **Check plugin (see above)**

2. **Verify agent files exist:**
   ```bash
   ls ~/.paf/agents/perspectives/
   # Should show 10 .md files
   ```

3. **Check COMMS.md for errors:**
   ```bash
   cat .paf/COMMS.md
   ```

4. **Try with explicit build:**
   ```
   /paf-cto "Test" --build=quick
   ```

### Wrong agents selected

**Symptoms:**
- Different agents than expected
- Specific perspective missing

**Solutions:**

1. **Check build preset:**
   - `quick` uses only 3-5 agents
   - `standard` uses 8-10
   - `comprehensive` uses all

2. **Check workflow requirements:**
   - Some workflows restrict which agents run
   - Try `perspective-review` for all agents

3. **Use explicit flags:**
   ```
   /paf-cto "Review" --build=comprehensive --workflow=full-feature
   ```

### Agent produces wrong output format

**Solutions:**

1. **Check agent file:**
   ```bash
   cat ~/.paf/agents/perspectives/alex.md
   ```

2. **Verify review format section exists**

3. **Reset agent to default (recopy from original)**

---

## ⚙️ Configuration Issues

### Wrong build or workflow selected

**Symptoms:**
- Unexpected build level
- Different workflow than expected

**Solutions:**

1. **PAF uses semantic understanding** - Claude interprets your intent naturally. Be clear about what you want:
   - "Quick check" → quick build
   - "Full security review" → security-audit workflow
   - "Comprehensive analysis" → comprehensive build

2. **Use explicit flags for precision:**
   ```
   /paf-cto "Review" --build=standard --workflow=security-audit
   ```

3. **Check signals.yaml documentation:**
   ```bash
   cat ~/.paf/config/signals.yaml | head -50
   ```

### Settings not being applied

**Solutions:**

1. **Check file syntax (YAML is indentation-sensitive)**

2. **Verify correct file:**
   ```bash
   cat ~/.paf/config/preferences.yaml
   ```

3. **Check for typos in setting names**

---

## 📝 Output Issues

### Output too short/incomplete

**Solutions:**

1. **Use more comprehensive build:**
   ```
   /paf-cto "Review" --build=comprehensive
   ```

2. **Check if agents complete:**
   - Look for all agent sections in output
   - Check COMMS.md for BLOCKED status

### Output formatting broken

**Solutions:**

1. **Check markdown rendering** in Claude

2. **Verify George (Aggregator) runs** for standard/comprehensive builds

3. **Try different build preset**

---

## 🐌 Performance Issues

### Review takes too long

**Causes & Solutions:**

1. **Too many agents:**
   - `--build=quick` for faster results

2. **Large context:**
   - Reduce code size in context
   - Focus on specific files

3. **Network issues:**
   - Check internet connection
   - Claude servers might be slow

### Review times out

**Solutions:**

1. **Quick build first:**
   ```
   /paf-cto "Quick check" --build=quick
   ```

2. **Increase timeout in preferences:**
   ```yaml
   agents:
     default_timeout: 600  # 10 minutes
   ```

3. **Split into smaller reviews**

---

## 🗂️ File Issues

### "File not found" errors

**Solutions:**

1. **Verify installation:**
   ```bash
   bash ~/.paf/scripts/verify-paf.sh
   ```

2. **Check permissions:**
   ```bash
   chmod -R 755 ~/.paf
   ```

3. **Reinstall if needed:**
   ```bash
   rm -rf ~/.paf
   git clone https://github.com/crack00r/paf-framework.git
   cd paf-framework && ./install.sh
   ```

### COMMS.md corrupted

**Solutions:**

1. **Reset COMMS.md:**
   ```bash
   cp ~/.paf/templates/COMMS.md .paf/COMMS.md
   ```

2. **Or create fresh:**
   ```bash
   echo "# PAF COMMS\n\n*Session start*" > .paf/COMMS.md
   ```

---

## 🔄 Reset & Recovery

### Complete Reset

If nothing else works:

```bash
# Backup customizations
cp ~/.paf/config/preferences.yaml ~/paf-backup.yaml

# Complete reset
rm -rf ~/.paf

# Reinstall
git clone https://github.com/crack00r/paf-framework.git
cd paf-framework && ./install.sh

# Restore preferences
cp ~/paf-backup.yaml ~/.paf/config/preferences.yaml

# Verify
bash ~/.paf/scripts/verify-paf.sh
```

### Partial Reset

Reset specific components:

```bash
# Reset only agents
rm -rf ~/.paf/agents
cp -R /path/to/paf-framework/agents ~/.paf/

# Reset only config
rm -rf ~/.paf/config
cp -R /path/to/paf-framework/config ~/.paf/

# Reset only plugin
cd ~/.paf/plugins/nested-subagent/mcp-server
rm -rf node_modules dist
npm install && npm run build
```

---

## 📞 Getting Help

If problems persist:

1. **Check FAQ:** [FAQ.md](../FAQ.md)
2. **Search GitHub Issues**
3. **Open new issue** with:
   - PAF version (`cat ~/.paf/VERSION`)
   - OS and Claude Code version (`claude --version`)
   - Reproduction steps
   - Error messages
   - Output from `verify-paf.sh`

---

## 🐛 Debug Mode

For detailed debugging:

```bash
export PAF_DEBUG=true
```

Enables verbose logging in agent operations.

Plugin logs can be found at: `/tmp/paf-nested-subagent-debug.log`
