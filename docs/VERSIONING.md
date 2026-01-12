# PAF Framework - Versioning Guide

> This document describes the versioning system of the PAF Framework.

---

## Single Source of Truth

The **only** authoritative source for the PAF version is:

```
/VERSION
```

This file contains only the version number (e.g., `4.1.0`) without additional text.

---

## Semantic Versioning

PAF uses [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH
  |     |     |
  |     |     +-- Patch: Bug fixes, typos, small corrections
  |     +-------- Minor: New features, agents, commands (backwards compatible)
  +-------------- Major: Breaking changes, API changes
```

### When to increment what?

| Change | Example | Version Bump |
|--------|---------|--------------|
| Typo fix | Documentation corrected | PATCH |
| Bug fix | Agent error fixed | PATCH |
| New agent | New utility agent | MINOR |
| New command | /paf-new-command | MINOR |
| New config option | New build preset | MINOR |
| Agent removed | Deprecation completed | MAJOR |
| API change | Spawn format changed | MAJOR |
| COMMS.md format | Breaking change | MAJOR |

---

## Performing Version Bump

### Automatic (recommended)

```bash
# Patch: Bug fixes, typos (4.1.0 -> 4.1.1)
./scripts/bump-version.sh patch

# Minor: New features (4.1.0 -> 4.2.0)
./scripts/bump-version.sh minor

# Major: Breaking changes (4.1.0 -> 5.0.0)
./scripts/bump-version.sh major

# Set specific version
./scripts/bump-version.sh set 4.2.0
```

The script automatically updates:
1. `VERSION` (Single Source of Truth)
2. `CHANGELOG.md` (new entry)
3. Files with static versions (Dockerfile, README, etc.)
4. Config files (`framework: "PAF v4.x"`)

### Manual

If needed, the version can be changed manually:

```bash
# 1. Change VERSION file
echo "4.1.1" > VERSION

# 2. Update CHANGELOG.md
# Add new entry

# 3. Update static files
# Dockerfile, README.md badge, etc.
```

---

## Files with Versions

### Dynamic (read VERSION)

These files read the version at runtime:

| File | How |
|------|-----|
| `install.sh` | `cat VERSION` |
| `update.sh` | `cat VERSION` |
| `verify-paf.sh` | `cat ~/.paf/VERSION` |
| `bin/paf` | `cat ~/.paf/VERSION` |
| CTO Agent | Reads `~/.paf/VERSION` |

### Static (must be updated)

These files MUST be updated with each release:

| File | Line | Format |
|------|------|--------|
| `Dockerfile` | LABEL | `version="4.1.0"` |
| `README.md` | Badge | `Version-4.1.0-blue` |
| `SKILL.md` | Header | `**Version:** (see VERSION)` |
| `.claude/skills/paf.md` | Frontmatter | `version: "4.1.0"` |

The `bump-version.sh` script updates these automatically.

### Config Files (Metadata)

Config files have a `framework` metadata line:

```yaml
meta:
  framework: "PAF v4.1"  # Only Major.Minor
  last_updated: "2026-01-10"
```

These are also updated automatically.

---

## CHANGELOG.md Format

```markdown
# Changelog

## [4.1.1] - 2026-01-10

### Added
- New feature X

### Changed
- Improvement Y

### Fixed
- Bug Z fixed

### Removed
- Deprecated feature removed

## [4.1.0] - 2026-01-09

...
```

### Rules

1. **Every release** gets an entry
2. **Every change** is documented
3. Categories: Added, Changed, Fixed, Removed, Deprecated, Security
4. Date format YYYY-MM-DD
5. Newest version at top

---

## Release Workflow

### 1. Complete Development

```bash
# Commit all changes
git add -A
git commit -m "feat: add new feature X"
```

### 2. Bump Version

```bash
# Choose the correct bump type
./scripts/bump-version.sh patch  # or minor/major
```

### 3. Edit CHANGELOG

```bash
# Open CHANGELOG.md and add details
# The script created a placeholder entry
```

### 4. Commit and Tag

```bash
# Commit
git add -A
git commit -m "chore: release v4.1.1"

# Create tag
git tag v4.1.1

# Push
git push && git push --tags
```

### 5. User Update

After push, users can update:

```bash
cd ~/.paf
git pull
./update.sh
```

The CTO then automatically recognizes the new version.

---

## CTO Version Check

The CTO performs a version check on every start:

```
1. Read ~/.paf/VERSION (Global)
2. Read .paf/VERSION (Project, if present)
3. Compare versions
4. On mismatch: Offer update
```

### Automatic Update

With `--build=comprehensive` or `--autonomous`, updates happen automatically.

---

## Project-wide Version Tracking

Every project with PAF has a local `.paf/VERSION`:

```
project/
├── .paf/
│   ├── VERSION          # e.g., "4.1.0"
│   ├── project.yaml     # contains paf_version
│   └── ...
```

On a global update, the CTO checks if the project needs to be updated.

---

## Important Notes

1. **Never forget VERSION file** - It's the single source of truth
2. **Always update CHANGELOG** - Document every change
3. **Create tags** - A Git tag for each release (v4.1.0)
4. **Follow semantic versioning** - Use patch/minor/major correctly
5. **Use bump-version.sh** - Prevents forgotten files

---

## Troubleshooting

### Version doesn't match

```bash
# Check VERSION file
cat ~/.paf/VERSION

# Check all version mentions
grep -r "v4\." ~/.paf --include="*.md" --include="*.yaml" | head -20

# Manually correct if needed
./scripts/bump-version.sh set 4.1.1
```

### CHANGELOG missing

```bash
# bump-version.sh automatically creates a CHANGELOG
./scripts/bump-version.sh patch
```

---

*PAF Versioning Guide - v1.0*
