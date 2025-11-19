Merge a branch from the worktree.
If you're currently working on a worktree, assume that's the one I'm referring to.

Start by merging back the new main branch, since I may have made changes to it.

# Language specific:

## Rust

Ensure cargo check is happy.
Ensure clippy is happy. clean up any new warnings.

## Typescript

Ensure tsc is happy.

# Finally

Squash the commits into a single one, merge into the base branch, and delete the worktree.
