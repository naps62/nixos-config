---
description: List, manage, and clean up git worktrees
---

# List and Manage Worktrees

**Usage:**
- `/worktree-list` - List all worktrees
- `/worktree-list cleanup` - Remove merged worktrees
- `/worktree-list prune` - Clean stale references

## List All Worktrees

```bash
if [ -z "$1" ]; then
  git worktree list
  exit 0
fi
```

## Cleanup Merged Worktrees

```bash
if [ "$1" = "cleanup" ]; then
  if git show-ref --verify --quiet refs/heads/main; then
    MAIN_BRANCH="main"
  elif git show-ref --verify --quiet refs/heads/master; then
    MAIN_BRANCH="master"
  else
    echo "❌ Error: Cannot find main/master"
    exit 1
  fi

  MERGED_BRANCHES=$(git branch --merged "$MAIN_BRANCH" | grep -v '^\*' | grep -v "$MAIN_BRANCH")
  if [ -z "$MERGED_BRANCHES" ]; then
    echo "✅ No merged branches found"
    exit 0
  fi

  while IFS= read -r branch; do
    branch=$(echo "$branch" | xargs)
    [ -z "$branch" ] && continue

    WORKTREE_PATH=$(git worktree list | grep "\[$branch\]" | awk '{print $1}')
    if [ -n "$WORKTREE_PATH" ]; then
      git worktree remove "$WORKTREE_PATH" --force 2>/dev/null || rm -rf "$WORKTREE_PATH"
    fi

    git branch -d "$branch" 2>/dev/null || git branch -D "$branch"
  done <<< "$MERGED_BRANCHES"

  git worktree prune
  git worktree list
  exit 0
fi
```

## Prune Stale References

```bash
if [ "$1" = "prune" ]; then
  git worktree prune -v
  git worktree list
  exit 0
fi
```

## Invalid Argument

```bash
echo "❌ Error: Invalid argument '$1'"
echo "Usage: /worktree-list [cleanup|prune]"
exit 1
```
