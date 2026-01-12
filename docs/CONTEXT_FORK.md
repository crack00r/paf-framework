# PAF Context Fork Architecture

## Overview

PAF v4.4+ supports Claude Code's `context: fork` feature for efficient agent isolation without subprocess overhead.

## What is context:fork?

Instead of spawning new `claude -p` processes (via nested-subagent plugin), `context: fork` creates isolated context windows within the same process:

| Aspect | nested-subagent Plugin | context: fork |
|--------|------------------------|---------------|
| Isolation | Process-level | Context-level |
| Memory | ~500MB per agent | Shared, ~50MB overhead |
| Startup time | 2-5 seconds | <100ms |
| Context size | 200k tokens each | 200k tokens each |
| Communication | COMMS.md file | COMMS.md file |
| Parallelism | OS process limits | Claude limits |

## Resource Comparison

**10 Perspective Agents - Standard Review:**

| Metric | nested-subagent | context: fork | Improvement |
|--------|-----------------|---------------|--------------|
| Memory | ~5GB | ~1GB | 80% reduction |
| Startup time | 20-50s | <1s | 95% reduction |
| Total time | 8-12 min | 3-5 min | 60% reduction |

## When to Use Which

### Use context: fork (Recommended)
- Perspective reviews (10 parallel agents)
- Quick builds (5-8 agents)
- Standard reviews (15-20 agents)
- Any review where agents don't need to spawn sub-agents

### Use nested-subagent Plugin
- Hierarchical spawning (Sophia → Michael, Kai)
- Very long tasks (>30 min)
- When agents need to spawn other agents
- Comprehensive builds with complex workflows

## Configuration

### Skill Frontmatter

```yaml
---
name: paf-perspective-review
context: fork
model: claude-sonnet-4-20250514
---
```

### Agent Definition

```yaml
agent:
  name: alex
  role: Security Analyst
  emoji: 🔒
  context: fork
  context_size: 50000  # Reduced for efficiency
  model: sonnet
```

### CTO Orchestration

```python
# Pseudo-code for context:fork spawning
async def spawn_perspectives(task):
    agents = ['alex', 'emma', 'sam', 'david', 'max',
              'luna', 'tom', 'nina', 'leo', 'ava']

    # Fork contexts for all perspective agents
    contexts = await asyncio.gather(*[
        fork_context(
            agent=agent,
            task=task,
            context_size=50000,
            timeout=180
        )
        for agent in agents
    ])

    # Wait for all to complete
    results = await asyncio.gather(*[
        ctx.wait_completion() for ctx in contexts
    ])

    return aggregate_results(results)
```

## Migration Guide

### Phase 1: Dual-Mode Support

PAF supports both modes simultaneously:

```yaml
# config/spawning.yaml
spawning:
  default_mode: context_fork

  # Plugin for hierarchical spawning
  use_plugin_for:
    - sophia  # Spawns michael, kai
    - rachel  # Spawns stan, scanner, perf

  # context:fork for leaf agents
  use_fork_for:
    - perspectives  # All 10
    - discovery     # ben, maya, iris
    - implementation  # anna, chris, dan, sarah, tina
    - deployment    # tony, rel, miggy
    - operations    # inci, monitor, feedback
    - retrospective # george, otto, docu
```

### Phase 2: Full Migration

After stabilization, migrate hierarchical agents:

```yaml
spawning:
  default_mode: context_fork

  # Sophia uses fork, spawns michael/kai also via fork
  hierarchical_fork:
    sophia:
      children: [michael, kai]
    rachel:
      children: [stan, scanner, perf]
```

## Best Practices

1. **Context Size Optimization**
   - Perspective agents: 50k tokens (sufficient for code review)
   - Implementation agents: 100k tokens (need more for code changes)
   - Aggregator (George): 150k tokens (collects all findings)

2. **Timeout Management**
   - Quick build: 60s per agent
   - Standard: 180s per agent
   - Comprehensive: 300s per agent

3. **Error Handling**
   - Fork failures automatically fall back to plugin
   - COMMS.md tracks mode used per agent

4. **Monitoring**
   - Track fork vs plugin usage in metrics
   - Compare performance over time
   - Adjust context sizes based on actual usage

## Limitations

1. **No Nested Spawning from Forked Context**
   - Forked agents cannot spawn other agents
   - Use plugin for hierarchical workflows

2. **Shared Resource Limits**
   - All forked contexts share Claude's rate limits
   - May hit limits faster with many parallel forks

3. **Context Isolation**
   - Forked contexts cannot communicate directly
   - Must use COMMS.md for coordination

## Example: Perspective Review with Fork

```yaml
---
name: paf-perspective-fork
version: "1.0"
context: fork
---

# PAF Perspective Review (Forked)

## Spawn Command

```
/paf-cto "Review authentication module" --build=standard --mode=fork
```

## What Happens

1. CTO reads task and selects perspective agents
2. CTO forks 10 contexts (one per perspective)
3. Each agent reviews in parallel (isolated context)
4. Results are written to COMMS.md
5. George aggregates from COMMS.md
6. CTO presents summary

## Resource Usage

- Memory: ~1GB total
- Time: 3-5 minutes
- Tokens: ~500k total (50k × 10 agents)
```

## Future Roadmap

- [ ] Auto-selection of fork vs plugin based on task complexity
- [ ] Dynamic context size adjustment based on file count
- [ ] Fork pooling for frequently used agent configurations
- [ ] Real-time progress streaming from forked contexts
