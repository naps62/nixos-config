---
description: Fast branch analysis - review changes for bugs, performance, security, and architecture issues
---

# Analyze Branch

Analyze the current branch relative to the base branch and generate a detailed report in `reports/` focusing on:
- Critical bugs (null safety, SQL injection, type errors)
- N+1 queries and performance issues
- Security vulnerabilities
- Breaking changes (caller analysis)
- Database migration risks
- Architecture (SOLID/DRY)

Create the `reports/` directory if missing. Create/overwrite ONE report file in that directory.

## Constraints (CRITICAL)

- DO NOT execute commands that modify the repository or history.
- DO NOT execute commands that modify dependencies or runtime state.
- The only allowed write operation is the report file in `reports/`.

## Input

You may receive a branch/ref as an argument. If absent or empty, use the **current branch**.

## Procedure

### Step 1: Git Context

```bash
CURRENT=$(git branch --show-current)
BASE=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null)
git diff --name-only $BASE..HEAD
git diff --stat $BASE..HEAD
```

### Step 2: Analyze Changed Files

For each changed file:
1. Read the full diff: `git diff $BASE..HEAD -- <file>`
2. Read surrounding context in the file
3. Check for issues listed above

### Step 3: Cross-Reference

- Check callers of modified functions (grep for function names across codebase)
- Check if modified database queries have proper indexes
- Check if new endpoints have authentication/authorization
- Check if error handling covers new failure modes

### Step 4: Generate Report

Write report to `reports/branch-analysis-<branch-name>.md`:

```markdown
# Branch Analysis: <branch-name>

**Date**: <date>
**Base**: <base-branch>
**Files Changed**: <count>
**Risk Score**: <LOW|MEDIUM|HIGH|CRITICAL>

## Summary
<1-3 sentence overview>

## Critical Findings
### <Finding Title>
- **Severity**: CRITICAL|HIGH|MEDIUM|LOW
- **File**: path/to/file:line
- **Issue**: Description
- **Suggestion**: How to fix

## Performance
<N+1 queries, missing indexes, expensive operations>

## Security
<Auth gaps, injection risks, data exposure>

## Breaking Changes
<API changes, schema changes, removed exports>

## Architecture
<SOLID violations, DRY issues, complexity>
```

### Step 5: Summary

Print the risk score and top 3 findings to stdout after writing the report.

$ARGUMENTS
