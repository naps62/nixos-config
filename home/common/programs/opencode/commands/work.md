---
description: Start parallel work on a feature using git worktree
---

# Start Worktree for Feature

Initialize a new git worktree to work on a feature in parallel with your current work.

**Usage:** `/work "feature description"`
**Manual:** `/work branch-name`

**Arguments:**
- `$1`: Feature description (quoted) OR branch name (single word)

## Requirements

- Must run from the main repository (not inside an existing worktree)
- Git installed, repository clean or stashable
- Worktrees live in `worktrees/` inside the repo root

## Process

### 1. Pre-flight Checks

```bash
# Ensure we're in a git repo
git rev-parse --git-dir > /dev/null

# Ensure not already in a worktree
CURRENT_GIT_DIR=$(git rev-parse --git-common-dir)
if [[ "$CURRENT_GIT_DIR" == *".git/worktrees"* ]]; then
  echo "❌ Error: already inside a worktree"
  exit 1
fi

# Ensure clean (or stash)
if ! git diff-index --quiet HEAD --; then
  echo "⚠️  Working tree has changes"
  git status --short
  echo "Stash before creating worktree"
  git stash push -m "Auto-stash before worktree"
fi
```

### 2. Determine Base Branch

```bash
if git show-ref --verify --quiet refs/heads/main; then
  BASE_BRANCH="main"
elif git show-ref --verify --quiet refs/heads/master; then
  BASE_BRANCH="master"
else
  echo "❌ Error: Cannot auto-detect base branch"
  exit 1
fi
```

### 3. Determine Branch Name

If `$1` contains spaces, treat it as a description and generate a concise branch name.

Rules:
- Lowercase, hyphens, max 50 chars
- Prefer `feat/`, `fix/`, `refactor/`, `chore/` prefixes when obvious

If `$1` is a single word, use it directly.

**Do not include "opencode" in the branch name.**

### 4. Create Worktree

```bash
REPO_ROOT=$(git rev-parse --show-toplevel)
WORKTREES_DIR="$REPO_ROOT/worktrees"
mkdir -p "$WORKTREES_DIR"

WORKTREE_PATH="$WORKTREES_DIR/$BRANCH_NAME"
git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" "$BASE_BRANCH"
```

### 5. Next Steps

```bash
cd "$WORKTREE_PATH"
git status
```

## Notes

- Use `/worktree-compare` to review changes before merging.
- Use `/merge` when ready to integrate.
