# Performance Review Workflow

> Deep performance analysis with specialized agents

## Overview

The Performance Review Workflow is optimized for:
- Performance Bottleneck Identification
- Latency and Throughput Analysis
- Resource Optimization
- Cost/Performance Trade-offs

## Agents

| Agent | Role | Focus |
|-------|-------|-------|
| **Emma** ⚡ | Performance Engineer | Response Times, Memory, CPU |
| **Perf** | Performance Analyzer | Benchmarks, Profiling |
| **David** 🔀 | Scalability | Load Testing, Horizontal Scale |
| **Tom** 💰 | FinOps | Resource Efficiency, Cost |
| **Max** 🔧 | Maintainability | Code Efficiency |
| **Tony** | DevOps | CI/CD Performance |
| **Scanner** | Security | Security Performance Impact |
| **George** 📋 | Aggregator | Consolidated Report |

## Phases

```
┌─────────────────────────────────────────────────────────────┐
│ Phase 1: Performance Analysis (parallel)                    │
│ Emma ⚡ + Perf + David 🔀 + Tom 💰 + Max 🔧                 │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ Phase 2: Infrastructure Review (parallel)                   │
│ Tony + Scanner                                              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ Phase 3: Aggregation                                        │
│ George 📋                                                   │
└─────────────────────────────────────────────────────────────┘
```

## Usage

```bash
/paf-cto "Optimize our API performance" --workflow=performance-review
/paf-cto "Why is the app so slow?"
/paf-cto "Benchmark our database queries"
```

## Output

The Performance Review delivers:

1. **Executive Summary** - Overall performance assessment
2. **Performance Metrics** - Measurable indicators
3. **Bottlenecks** - Identified bottlenecks
4. **Optimization Recommendations** - Prioritized improvements
5. **Cost Impact** - Cost/benefit analysis
6. **Action Items** - Concrete next steps

## Example Output

```markdown
## ⚡ Performance Review Summary

**Overall Score:** 6.5/10
**Critical Bottlenecks:** 2
**Quick Wins:** 5

### Top Issues
1. N+1 Query Problem (Database) - P0
2. Missing CDN for static assets - P1
3. Unoptimized images - P2

### Recommendations
| Priority | Action | Impact | Effort |
|----------|--------|--------|--------|
| P0 | Add eager loading | High | Low |
| P1 | Enable CDN | High | Medium |
| P2 | Image compression | Medium | Low |

### Cost Analysis
Current: $450/month
After optimization: ~$320/month (29% savings)
```
