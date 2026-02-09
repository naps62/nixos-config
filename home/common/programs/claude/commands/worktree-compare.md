---
description: Compare worktree changes with target branch before merging
---

# Compare Worktree Changes

Visualize changes in the current worktree compared to a target branch (usually main/master).

**Usage:** `/worktree-compare [target-branch]`

## Process

### 1. Verify Context

```bash
CURRENT_BRANCH=$(git branch --show-current)
WORKTREE_DIR=$(git rev-parse --git-common-dir)

# Check we're in a worktree
if [[ ! "$WORKTREE_DIR" == *".git/worktrees"* ]]; then
  echo "Error: You're not in a worktree"
  exit 1
fi
```

### 2. Determine Target Branch

```bash
TARGET_BRANCH="${1:-}"
if [ -z "$TARGET_BRANCH" ]; then
  if git show-ref --verify --quiet refs/heads/main; then
    TARGET_BRANCH="main"
  elif git show-ref --verify --quiet refs/heads/master; then
    TARGET_BRANCH="master"
  fi
fi
```

### 3. Update Target Branch

```bash
git fetch origin "$TARGET_BRANCH:$TARGET_BRANCH" 2>/dev/null || true
```

### 4. Summary + Diff

```bash
git diff --shortstat "$TARGET_BRANCH..$CURRENT_BRANCH"
git diff --name-status "$TARGET_BRANCH..$CURRENT_BRANCH"
git log "$TARGET_BRANCH..$CURRENT_BRANCH" --oneline --decorate --graph
git diff "$TARGET_BRANCH..$CURRENT_BRANCH"
```

### 5. Conflict Detection

```bash
# Check for files modified in both branches
COMMON_FILES=$(comm -12 \
  <(git diff --name-only "$TARGET_BRANCH..$CURRENT_BRANCH" | sort) \
  <(git diff --name-only "$CURRENT_BRANCH..$TARGET_BRANCH" | sort))

if [ -z "$COMMON_FILES" ]; then
  echo "No potential conflicts detected"
else
  echo "Potential conflicts in:"
  echo "$COMMON_FILES"
fi
```

$ARGUMENTS
