#!/usr/bin/env bash
# PAF GitHub Actions Setup
# Creates GitHub Workflows in .github/workflows/ directory

set -e

WORKFLOWS_DIR=".github/workflows"

echo "⚡ Creating PAF GitHub Actions..."
echo ""

mkdir -p "$WORKFLOWS_DIR"

echo "📦 Creating Workflows..."

# 1. Auto-Triage Workflow
cat > "$WORKFLOWS_DIR/paf-auto-triage.yml" << 'EOF'
name: PAF Auto-Triage

on:
  issues:
    types: [opened, labeled]

jobs:
  add-to-project:
    runs-on: ubuntu-latest
    steps:
      - name: Add finding to Sprint Board
        uses: actions/add-to-project@v0.5.0
        with:
          project-url: ${{ vars.PAF_SPRINT_BOARD_URL }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
        if: contains(github.event.issue.labels.*.name, 'finding')
        continue-on-error: true

      - name: Add security issue to Security Board
        uses: actions/add-to-project@v0.5.0
        with:
          project-url: ${{ vars.PAF_SECURITY_BOARD_URL }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
        if: |
          contains(github.event.issue.labels.*.name, 'security') ||
          contains(github.event.issue.labels.*.name, '🔒 alex') ||
          contains(github.event.issue.labels.*.name, '🔍 scanner')
        continue-on-error: true

      - name: Add tech-debt to Tech Debt Board
        uses: actions/add-to-project@v0.5.0
        with:
          project-url: ${{ vars.PAF_TECHDEBT_BOARD_URL }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
        if: |
          contains(github.event.issue.labels.*.name, 'tech-debt') ||
          contains(github.event.issue.labels.*.name, '🔧 max')
        continue-on-error: true

      - name: Add bug to Bug Tracker
        uses: actions/add-to-project@v0.5.0
        with:
          project-url: ${{ vars.PAF_BUG_BOARD_URL }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
        if: |
          contains(github.event.issue.labels.*.name, 'bug') ||
          contains(github.event.issue.labels.*.name, 'incident')
        continue-on-error: true

      - name: Add feature to Product Backlog
        uses: actions/add-to-project@v0.5.0
        with:
          project-url: ${{ vars.PAF_BACKLOG_BOARD_URL }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
        if: |
          contains(github.event.issue.labels.*.name, 'feature') ||
          contains(github.event.issue.labels.*.name, '💡 ava')
        continue-on-error: true

      - name: Add ADR to Architecture Board
        uses: actions/add-to-project@v0.5.0
        with:
          project-url: ${{ vars.PAF_ARCH_BOARD_URL }}
          github-token: ${{ secrets.GITHUB_TOKEN }}
        if: |
          contains(github.event.issue.labels.*.name, 'adr') ||
          contains(github.event.issue.labels.*.name, 'architecture')
        continue-on-error: true
EOF
echo "  ✅ paf-auto-triage.yml"

# 2. Auto-Label Workflow
cat > "$WORKFLOWS_DIR/paf-auto-label.yml" << 'EOF'
name: PAF Auto-Label

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  label:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
    steps:
      - uses: actions/labeler@v5
        with:
          repo-token: "${{ secrets.GITHUB_TOKEN }}"
          configuration-path: .github/labeler.yml
        continue-on-error: true
EOF

# Create labeler config
cat > ".github/labeler.yml" << 'EOF'
# PAF Auto-Labeler Configuration

# Documentation
documentation:
  - changed-files:
      - any-glob-to-any-file:
          - '**/*.md'
          - 'docs/**/*'

# Testing
testing:
  - changed-files:
      - any-glob-to-any-file:
          - '**/*.test.*'
          - '**/*.spec.*'
          - 'tests/**/*'
          - '__tests__/**/*'

# Infrastructure
infrastructure:
  - changed-files:
      - any-glob-to-any-file:
          - '.github/**/*'
          - 'Dockerfile*'
          - 'docker-compose*'
          - '*.yml'
          - '*.yaml'

# Security
security:
  - changed-files:
      - any-glob-to-any-file:
          - '**/auth/**/*'
          - '**/security/**/*'
          - '**/crypto/**/*'

# Performance
performance:
  - changed-files:
      - any-glob-to-any-file:
          - '**/cache/**/*'
          - '**/performance/**/*'
EOF
echo "  ✅ paf-auto-label.yml + labeler.yml"

# 3. Stale Issues Workflow
cat > "$WORKFLOWS_DIR/paf-stale-issues.yml" << 'EOF'
name: PAF Stale Issues

on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight UTC
  workflow_dispatch:  # Manual trigger

jobs:
  stale:
    runs-on: ubuntu-latest
    permissions:
      issues: write
      pull-requests: write
    steps:
      - uses: actions/stale@v9
        with:
          stale-issue-message: |
            👋 This issue has been automatically marked as stale because it has not had recent activity.
            
            It will be closed in **7 days** if no further activity occurs.
            
            If this issue is still relevant:
            - Add a comment
            - Remove the `stale` label
            
            _This is an automated message from PAF Framework._
          stale-pr-message: |
            👋 This PR has been automatically marked as stale because it has not had recent activity.
            
            It will be closed in **7 days** if no further activity occurs.
            
            _This is an automated message from PAF Framework._
          stale-issue-label: 'stale'
          stale-pr-label: 'stale'
          days-before-stale: 14
          days-before-close: 7
          exempt-issue-labels: 'P0,P1,blocked,pinned,security'
          exempt-pr-labels: 'P0,P1,blocked,security'
          remove-stale-when-updated: true
EOF
echo "  ✅ paf-stale-issues.yml"

# 4. Sprint Metrics Workflow
cat > "$WORKFLOWS_DIR/paf-sprint-metrics.yml" << 'EOF'
name: PAF Sprint Metrics

on:
  milestone:
    types: [closed]
  workflow_dispatch:
    inputs:
      milestone:
        description: 'Milestone number to analyze'
        required: true
        type: number

jobs:
  metrics:
    runs-on: ubuntu-latest
    permissions:
      issues: write
    steps:
      - name: Get Milestone Info
        id: milestone
        uses: actions/github-script@v7
        with:
          script: |
            const milestoneNumber = context.payload.milestone?.number || ${{ inputs.milestone || 0 }};
            if (!milestoneNumber) {
              core.setFailed('No milestone specified');
              return;
            }
            
            const milestone = await github.rest.issues.getMilestone({
              owner: context.repo.owner,
              repo: context.repo.repo,
              milestone_number: milestoneNumber
            });
            
            const issues = await github.rest.issues.listForRepo({
              owner: context.repo.owner,
              repo: context.repo.repo,
              milestone: milestoneNumber,
              state: 'all',
              per_page: 100
            });
            
            const closed = issues.data.filter(i => i.state === 'closed').length;
            const open = issues.data.filter(i => i.state === 'open').length;
            const bugs = issues.data.filter(i => i.labels.some(l => l.name === 'bug')).length;
            const findings = issues.data.filter(i => i.labels.some(l => l.name === 'finding')).length;
            const p0 = issues.data.filter(i => i.labels.some(l => l.name === 'P0')).length;
            const p1 = issues.data.filter(i => i.labels.some(l => l.name === 'P1')).length;
            
            const body = `## 📊 Sprint Metrics: ${milestone.data.title}

            | Metric | Value |
            |--------|-------|
            | Total Issues | ${issues.data.length} |
            | Closed | ${closed} |
            | Open | ${open} |
            | Completion Rate | ${Math.round((closed / issues.data.length) * 100)}% |
            | Bugs | ${bugs} |
            | Findings | ${findings} |
            | P0 Issues | ${p0} |
            | P1 Issues | ${p1} |

            ### Issues by Label
            ${issues.data.slice(0, 20).map(i => `- ${i.state === 'closed' ? '✅' : '⏳'} #${i.number}: ${i.title}`).join('\n')}
            ${issues.data.length > 20 ? `\n... and ${issues.data.length - 20} more` : ''}

            ---
            _Generated by PAF Sprint Metrics_
            `;
            
            await github.rest.issues.create({
              owner: context.repo.owner,
              repo: context.repo.repo,
              title: `[RETRO] ${milestone.data.title} - Sprint Summary`,
              body: body,
              labels: ['retrospective', '📋 george']
            });
            
            core.info(`Created sprint summary for ${milestone.data.title}`);
EOF
echo "  ✅ paf-sprint-metrics.yml"

# 5. Release Notes Workflow
cat > "$WORKFLOWS_DIR/paf-release-notes.yml" << 'EOF'
name: PAF Release Notes

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Generate Release Notes
        uses: actions/github-script@v7
        with:
          script: |
            const { data: releases } = await github.rest.repos.listReleases({
              owner: context.repo.owner,
              repo: context.repo.repo,
              per_page: 2
            });
            
            const previousTag = releases[1]?.tag_name || '';
            const currentTag = context.ref.replace('refs/tags/', '');
            
            const { data: commits } = await github.rest.repos.compareCommits({
              owner: context.repo.owner,
              repo: context.repo.repo,
              base: previousTag || 'HEAD~10',
              head: currentTag
            });
            
            const features = [];
            const fixes = [];
            const others = [];
            
            for (const commit of commits.commits) {
              const msg = commit.commit.message.split('\n')[0];
              if (msg.startsWith('feat:') || msg.startsWith('feat(')) {
                features.push(`- ${msg.replace(/^feat(\([^)]+\))?:/, '').trim()}`);
              } else if (msg.startsWith('fix:') || msg.startsWith('fix(')) {
                fixes.push(`- ${msg.replace(/^fix(\([^)]+\))?:/, '').trim()}`);
              } else if (!msg.startsWith('chore:') && !msg.startsWith('docs:')) {
                others.push(`- ${msg}`);
              }
            }
            
            let body = `## What's Changed\n\n`;
            if (features.length) body += `### ✨ Features\n${features.join('\n')}\n\n`;
            if (fixes.length) body += `### 🐛 Bug Fixes\n${fixes.join('\n')}\n\n`;
            if (others.length) body += `### 📝 Other Changes\n${others.join('\n')}\n\n`;
            body += `---\n_Release generated by PAF Framework_`;
            
            await github.rest.repos.createRelease({
              owner: context.repo.owner,
              repo: context.repo.repo,
              tag_name: currentTag,
              name: `Release ${currentTag}`,
              body: body,
              draft: false,
              prerelease: currentTag.includes('-')
            });
EOF
echo "  ✅ paf-release-notes.yml"

# 6. PR Checks Workflow
cat > "$WORKFLOWS_DIR/paf-pr-checks.yml" << 'EOF'
name: PAF PR Checks

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check PR Title
        uses: actions/github-script@v7
        with:
          script: |
            const title = context.payload.pull_request.title;
            const validPrefixes = ['feat:', 'fix:', 'docs:', 'style:', 'refactor:', 'perf:', 'test:', 'chore:', 'ci:', 'build:'];
            
            // Also allow [PREFIX-XXX] format from PAF agents
            const agentPattern = /^\[(SEC|PERF|UX|SCALE|MAINT|A11Y|COST|DOC|IDEA|SCAN|TEST|INC|FIX)-\d+\]/;
            
            const hasValidPrefix = validPrefixes.some(p => title.toLowerCase().startsWith(p));
            const hasAgentPrefix = agentPattern.test(title);
            const isFixPrefix = title.startsWith('Fix:') || title.startsWith('fix:');
            
            if (!hasValidPrefix && !hasAgentPrefix && !isFixPrefix) {
              core.warning(`PR title should start with a conventional commit prefix (feat:, fix:, docs:, etc.) or a PAF agent prefix ([SEC-001], [PERF-002], etc.)`);
            } else {
              core.info('✅ PR title format is valid');
            }

      - name: Check for linked issues
        uses: actions/github-script@v7
        with:
          script: |
            const body = context.payload.pull_request.body || '';
            const hasLinkedIssue = /(?:closes?|fixes?|resolves?)\s+#\d+/i.test(body) || 
                                   /#\d+/.test(body);
            
            if (!hasLinkedIssue) {
              core.warning('Consider linking this PR to an issue using "Fixes #123" or "Closes #456"');
            } else {
              core.info('✅ PR has linked issues');
            }
EOF
echo "  ✅ paf-pr-checks.yml"

echo ""
echo "✅ GitHub Actions Setup completed!"
echo "   Created in: $WORKFLOWS_DIR/"
echo ""
echo "⚠️  NOTE: For Auto-Triage, repository variables must be set:"
echo "   Settings → Secrets and variables → Actions → Variables"
echo ""
echo "   Required Variables:"
echo "   - PAF_SPRINT_BOARD_URL"
echo "   - PAF_SECURITY_BOARD_URL"
echo "   - PAF_TECHDEBT_BOARD_URL"
echo "   - PAF_BUG_BOARD_URL"
echo "   - PAF_BACKLOG_BOARD_URL"
echo "   - PAF_ARCH_BOARD_URL"
