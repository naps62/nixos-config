---
description: Merge worktree changes and clean up safely
---

# Merge Worktree and Cleanup

Merge changes from the current worktree into a target branch and clean up the worktree.

**Usage:** `/merge [target-branch]`

**Arguments:**
- `$1`: Target branch to merge into (default: auto-detect main/master)

## Process

### 1. Pre-flight Checks

```bash
CURRENT_BRANCH=$(git branch --show-current)
WORKTREE_DIR=$(git rev-parse --git-common-dir)

if [[ ! "$WORKTREE_DIR" == *".git/worktrees"* ]]; then
  echo "❌ Error: You're not in a worktree"
  exit 1
fi

if ! git diff-index --quiet HEAD --; then
  echo "❌ Error: You have uncommitted changes"
  git status --short
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
WORKTREE_PATH=$(pwd)
COMMON_DIR=$(git rev-parse --git-common-dir)
REPO_ROOT=$(echo "$COMMON_DIR" | sed 's/\.git.*//' | sed 's/\/$//')
if [ "$COMMON_DIR" = ".git" ]; then
  REPO_ROOT=$(git rev-parse --show-toplevel)
fi

cd "$REPO_ROOT"
git checkout "$TARGET_BRANCH"
git pull origin "$TARGET_BRANCH"
```

### 4. Merge

```bash
git merge --no-ff "$CURRENT_BRANCH" -m "Merge branch '$CURRENT_BRANCH'"
```

If you prefer a squash merge, do this instead:

```bash
git merge --squash "$CURRENT_BRANCH"
git commit -m "feat: <summary>"
```

### 5. Push and Clean Up

```bash
git push origin "$TARGET_BRANCH"

git worktree remove "$WORKTREE_PATH" --force || rm -rf "$WORKTREE_PATH"
git branch -d "$CURRENT_BRANCH" || git branch -D "$CURRENT_BRANCH"
```

### 6. Optional: Delete Remote Branch

```bash
git push origin --delete "$CURRENT_BRANCH"
```

## Language-specific checks

### Rust
- `cargo check`
- `cargo clippy` (clean up new warnings)

### TypeScript
- `tsc`
