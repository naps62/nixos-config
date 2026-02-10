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
git worktree list
```

## Cleanup Merged Worktrees

If argument is "cleanup":

```bash
# Find main branch
if git show-ref --verify --quiet refs/heads/main; then
  MAIN_BRANCH="main"
elif git show-ref --verify --quiet refs/heads/master; then
  MAIN_BRANCH="master"
fi

# Find and remove merged branches and their worktrees
MERGED_BRANCHES=$(git branch --merged "$MAIN_BRANCH" | grep -v '^\*' | grep -v "$MAIN_BRANCH")

for branch in $MERGED_BRANCHES; do
  WORKTREE_PATH=$(git worktree list | grep "\[$branch\]" | awk '{print $1}')
  if [ -n "$WORKTREE_PATH" ]; then
    git worktree remove "$WORKTREE_PATH" --force
  fi
  git branch -d "$branch"
done

git worktree prune
git worktree list
```

## Prune Stale References

If argument is "prune":

```bash
git worktree prune -v
git worktree list
```

$ARGUMENTS
