# /paf-help - PAF Framework Help System

Interactive help system for all PAF commands and features.

## Usage

```
/paf-help                    # Show all commands
/paf-help <command>          # Help for specific command
/paf-help --workflows        # List all workflows
/paf-help --agents           # List all agents
/paf-help --builds           # Explain build presets
```

## Default Output

```
╔══════════════════════════════════════════════════════════════════╗
║  🆘 PAF FRAMEWORK - COMMAND HELP                                   ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  🎯 ORCHESTRATION                                                ║
║     /paf-cto              Start CTO Orchestrator                ║
║     /paf-cto --build=X    With Build Preset                     ║
║     /paf-cto --workflow=Y With specific Workflow                ║
║     /paf-cto --autonomous Autonomous mode (no interaction)      ║
║                                                                  ║
║  📊 WORKFLOWS (7 available)                                      ║
║     perspective-review    Multi-Perspective Code Review         ║
║     security-audit        Security Deep Dive (Alex 🔒)          ║
║     performance-review    Performance Analysis (Emma ⚡)         ║
║     full-feature          All Perspectives                      ║
║     bugfix                Bug Investigation                     ║
║     hotfix                Emergency Fix                         ║
║     retrospective         Sprint Retrospective                  ║
║                                                                  ║
║  👥 PERSPECTIVE AGENTS (10)                                      ║
║     Alex 🔒 Security       Emma ⚡ Performance                    ║
║     Sam 🎨 UX              David 🔀 Scalability                  ║
║     Max 🔧 Maintainability Luna ♿ Accessibility                 ║
║     Tom 💰 Cost            Nina 🎯 Triage                        ║
║     Leo 📚 Documentation   Ava 💡 Innovation                     ║
║                                                                  ║
║  🔧 UTILITIES                                                    ║
║     /paf-init             Initialize project (Git/GitHub)       ║
║     /paf-fix [type]       Bug Fixer - Auto-fix Errors           ║
║     /paf-validate [mode]  Build Verification                    ║
║     /paf-status           Show current status                   ║
║                                                                  ║
║  📚 REFERENCE                                                    ║
║     /paf-help             This help system                      ║
║     /paf-quickref         Quick Reference Card                  ║
║                                                                  ║
║  ⚡ BUILD PRESETS                                                 ║
║     quick                 2-3 min, 5-8 Agents                   ║
║     standard (default)    8-12 min, 15-20 Agents                ║
║     comprehensive         20-30 min, 30-38 Agents               ║
║                                                                  ║
║  💡 EXAMPLES                                                     ║
║     /paf-cto "Review my auth implementation"                    ║
║     /paf-cto --build=quick "Quick security check"               ║
║     /paf-cto --workflow=security-audit "Audit this API"         ║
║     /paf-cto --autonomous "Full review without questions"       ║
║     /paf-fix typescript                                         ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

## Agents Help (`/paf-help --agents`)

```
╔══════════════════════════════════════════════════════════════════╗
║  👥 PAF PERSPECTIVE AGENTS                                       ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  Alex  🔒  Security                                              ║
║            Vulnerabilities, Auth, OWASP, Input Validation        ║
║            "Trust nothing, verify everything"                    ║
║                                                                  ║
║  Emma  ⚡  Performance                                            ║
║            Latency, Caching, N+1 Queries, Memory Leaks           ║
║            "Measure twice, optimize once"                        ║
║                                                                  ║
║  Sam   🎨  UX                                                     ║
║            Usability, User Flows, States, Consistency            ║
║            "Don't make me think"                                 ║
║                                                                  ║
║  David 🔀  Scalability                                           ║
║            Architecture, Load Balancing, Microservices           ║
║            "Design for 10x, build for 2x"                        ║
║                                                                  ║
║  Max   🔧  Maintainability                                       ║
║            Code Quality, SOLID, Tech Debt, Refactoring           ║
║            "Leave code better than you found it"                 ║
║                                                                  ║
║  Luna  ♿  Accessibility                                          ║
║            WCAG 2.1 AA, Screen Reader, Keyboard Navigation       ║
║            "The web is for everyone"                             ║
║                                                                  ║
║  Tom   💰  Cost                                                   ║
║            Cloud Costs, FinOps, Resource Optimization            ║
║            "Every dollar counts"                                 ║
║                                                                  ║
║  Nina  🎯  Triage                                                 ║
║            Prioritization, Risk Assessment, Go/No-Go             ║
║            "Focus on what matters most"                          ║
║                                                                  ║
║  Leo   📚  Documentation                                          ║
║            README, API Docs, Code Comments, Onboarding           ║
║            "Good docs make good developers"                      ║
║                                                                  ║
║  Ava   💡  Innovation                                             ║
║            Emerging Tech, Alternatives, Future-proofing          ║
║            "There's always a better way"                         ║
║                                                                  ║
╠══════════════════════════════════════════════════════════════════╣
║  📊 AGGREGATION                                                  ║
║  George 📋 Scrum Master - Aggregates all findings                ║
║                                                                  ║
║  🔧 UTILITY                                                      ║
║  Bug Fixer 🐛 - Auto-fix build errors                           ║
║  Validator ✅ - Build verification                               ║
╚══════════════════════════════════════════════════════════════════╝
```

## Builds Help (`/paf-help --builds`)

```
╔══════════════════════════════════════════════════════════════════╗
║  ⚡ PAF BUILD PRESETS                                             ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  quick                                                           ║
║  ─────────────────────────────────────────────────────────────── ║
║  ⏱️  Time:    2-3 minutes                                        ║
║  👥 Agents:  5-8 (Max, David, Nina + conditional)                ║
║  📊 Depth:   Superficial, critical issues only                   ║
║  📝 Output:  Compact summary (~500 words)                        ║
║  🎯 Use:     Quick checks, urgent reviews                        ║
║                                                                  ║
║  standard (Default)                                              ║
║  ─────────────────────────────────────────────────────────────── ║
║  ⏱️  Time:    8-12 minutes                                       ║
║  👥 Agents:  15-20 (Core + conditional)                         ║
║  📊 Depth:   Thorough, all important areas                       ║
║  📝 Output:  Structured report (~2000 words)                     ║
║  🎯 Use:     Normal reviews, Feature assessments                 ║
║                                                                  ║
║  comprehensive                                                   ║
║  ─────────────────────────────────────────────────────────────── ║
║  ⏱️  Time:    20-30 minutes                                      ║
║  👥 Agents:  30-38 (All available)                               ║
║  📊 Depth:   Exhaustive, Deep Dive                               ║
║  📝 Output:  Enterprise report (~5000 words)                     ║
║  🎯 Use:     Audits, Production releases, Critical               ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```

## Workflows Help (`/paf-help --workflows`)

```
╔══════════════════════════════════════════════════════════════════╗
║  📊 PAF WORKFLOWS                                                ║
╠══════════════════════════════════════════════════════════════════╣
║                                                                  ║
║  perspective-review (Default)                                    ║
║     Multi-Perspective Code/Feature Review                        ║
║     Agents: Based on Build Preset                                ║
║                                                                  ║
║  security-audit                                                  ║
║     Security-focused Deep Dive                                   ║
║     Lead: Alex 🔒 | Support: Max, David, Emma                    ║
║                                                                  ║
║  performance-review                                              ║
║     Performance-focused Analysis                                 ║
║     Lead: Emma ⚡ | Support: David, Tom                           ║
║                                                                  ║
║  full-feature                                                    ║
║     Complete Analysis with all Perspectives                      ║
║     Agents: All 10 + George                                      ║
║                                                                  ║
║  bugfix                                                          ║
║     Bug Investigation and Fix                                    ║
║     Trigger: "bug", "error", "fix"                               ║
║                                                                  ║
║  hotfix                                                          ║
║     Emergency Production Fix                                     ║
║     Trigger: "hotfix", "production", "urgent"                    ║
║                                                                  ║
║  retrospective                                                   ║
║     Sprint Retrospective                                         ║
║     Lead: George | Trigger: "retro", "retrospective"             ║
║                                                                  ║
╚══════════════════════════════════════════════════════════════════╝
```
