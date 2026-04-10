---
name: yolo
description: "Pick a Linear task (or create one), implement in a worktree, push directly with minimal ceremony"
user-invocable: true
args:
  - name: input
    description: "A Linear issue ID (e.g. ERN-347), an ad-hoc task description, or omit to auto-pick next unblocked task"
    required: false
---

# Yolo - Quick Ship Flow

Fast autonomous workflow: Linear issue -> worktree -> implementation -> push -> done. No PRs, no reviews.

**First:** Read `~/.claude/skills/linear-common/COMMON.md` for shared setup instructions.

## Workflow

### 1. Setup (from COMMON.md)
- Load project config
- Select task (from `$ARGUMENTS`)
- Set up worktree
- Gather context

### 2. Implement

Follow the implementation guidelines from COMMON.md. Move fast — this is yolo mode.

- Skip formal planning. Read the issue, understand it, start coding.
- Still write tests if the project has them, but don't block on edge cases.
- Run the `buildCommand` if configured. If it fails, fix it. If a failure is minor and unrelated to your change, warn the user but keep going.

### 3. Ship

1. Push the branch: `git push -u origin <branch>`
2. If the work is complete and self-contained, merge to the default branch:
   ```
   git checkout <defaultBranch>
   git merge <branch> --no-edit
   git push
   git checkout <branch>
   ```
   Only do this if the change is clearly ready. If unsure, just push the branch and let the user decide.
3. Move the Linear issue to "Done".
4. That's it. No PR, no review loop.
