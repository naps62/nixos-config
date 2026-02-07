---
description: Compare worktree changes with target branch before merging
---

# Compare Worktree Changes

Visualize changes in the current worktree compared to a target branch (usually main/master).

**Usage:** `/worktree-compare [target-branch]`

**Arguments:**
- `$1`: Target branch to compare against (default: auto-detect main/master)

## Process

### 1. Verify Context

```bash
CURRENT_BRANCH=$(git branch --show-current)
WORKTREE_DIR=$(git rev-parse --git-common-dir)

if [[ ! "$WORKTREE_DIR" == *".git/worktrees"* ]]; then
  echo "❌ Error: You're not in a worktree"
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
  else
    echo "❌ Error: Cannot auto-detect main branch"
    exit 1
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

# Detailed diff (delta if installed)
if command -v delta &> /dev/null; then
  git diff "$TARGET_BRANCH..$CURRENT_BRANCH" | delta
else
  git diff "$TARGET_BRANCH..$CURRENT_BRANCH" --color=always | less -R
fi
```

### 5. Conflict Detection

```bash
COMMON_FILES=$(comm -12 \
  <(git diff --name-only "$TARGET_BRANCH..$CURRENT_BRANCH" | sort) \
  <(git diff --name-only "$CURRENT_BRANCH..$TARGET_BRANCH" | sort))

if [ -z "$COMMON_FILES" ]; then
  echo "✅ No potential conflicts detected"
else
  echo "⚠️  Potential conflicts in:"
  echo "$COMMON_FILES"
fi
```
