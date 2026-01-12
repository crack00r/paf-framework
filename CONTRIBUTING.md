# Contributing to PAF Framework

Thank you for your interest in contributing to PAF! This document provides guidelines for contributions.

## 🌟 Ways to Contribute

- **Bug Reports** - Found a bug? Let us know!
- **Feature Requests** - Have an idea? Share it!
- **New Agents** - Create new perspective agents
- **Workflows** - Build new workflow templates
- **Documentation** - Improve docs, add examples
- **Translations** - Help translate to other languages

## 🚀 Getting Started

1. **Fork the repository**
2. **Clone your fork:**
   ```bash
   git clone https://github.com/yourusername/paf-framework.git
   ```
3. **Create a branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```
4. **Make your changes**
5. **Test your changes:**
   ```bash
   bash scripts/verify-paf.sh
   ```
6. **Commit and push**
7. **Open a Pull Request**

## 📝 Code Style

### Agent Files (Markdown)

Follow the existing agent template structure:

```markdown
# Agent: Name (Perspective)

## Identity
- **Name:** Name
- **Role:** Role Description
- **Emoji:** 🔒
- **Model:** claude-sonnet-4-20250514

## Perspective
[Description of how this agent thinks]

## Focus Areas
1. Area 1
2. Area 2
...

## Red Flags 🚩
- Flag 1
- Flag 2
...

## Review Format
[Output template]

## Activation
[Activation prompt]
```

### Configuration Files (YAML)

- Use 2-space indentation
- Add comments for complex sections
- Follow existing naming conventions

### Documentation

- Use clear, concise language
- Include code examples where helpful
- Keep formatting consistent

## 🧪 Testing

Before submitting:

1. **Run verification:**
   ```bash
   bash scripts/verify-paf.sh
   ```

2. **Test with Claude:**
   - Install to `~/.paf`
   - Run a few test reviews
   - Verify agents spawn correctly

3. **Check documentation:**
   - Links work
   - Examples are accurate
   - No typos

## 📦 Pull Request Guidelines

### PR Title Format

```
type: brief description

Examples:
feat: add new DevSecOps agent
fix: correct semantic understanding for multilingual input
docs: improve installation guide
refactor: simplify CTO orchestration logic
```

### PR Description Template

```markdown
## Description
[What does this PR do?]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation
- [ ] Refactoring

## Testing Done
[How did you test this?]

## Checklist
- [ ] verify-paf.sh passes
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
```

## Bug Reports

Include:
- PAF version
- Operating system
- Claude Code version (`claude --version`)
- Steps to reproduce
- Expected behavior
- Actual behavior
- Error messages/logs

## 💡 Feature Requests

Include:
- Clear description of the feature
- Use case / why it's needed
- Proposed implementation (if any)
- Alternatives considered

## 🎭 Adding New Agents

1. Create `agents/perspectives/newagent.md` following the template
2. Add to `config/builds.yaml` (decide which builds include it)
3. Add to `config/ai-success-profiles.yaml`
4. Update relevant workflows if applicable
5. Update documentation (README, help, quickref)
6. Test the agent works correctly

## 📊 Adding New Workflows

1. Create `workflows/new-workflow.yaml` and `.md`
2. Define phases, agents, and dependencies
3. Add to signals.yaml documentation if applicable
4. Update documentation
5. Test end-to-end

## 🌍 Translations

PAF uses English as its primary language. To add language support:

1. Update `config/signals.yaml` documentation with when-to-use guidance
2. Translate agent prompts (optional)
3. Update documentation

Currently supported: English (en)

## 📜 Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn
- Focus on the code, not the person

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙋 Questions?

- Open a GitHub Discussion
- Check existing issues
- Read the FAQ

---

Thank you for contributing to PAF! 🎉
