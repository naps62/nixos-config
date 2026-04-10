---
name: work
description: "Pick a Linear task (or create one), implement in a worktree, open a PR, and iterate on reviews autonomously"
user-invocable: true
args:
  - name: input
    description: "A Linear issue ID (e.g. ERN-347), an ad-hoc task description, or omit to auto-pick next unblocked task"
    required: false
---

# Work - Proper PR Flow

Autonomous workflow: Linear issue -> worktree -> implementation -> PR -> review iteration -> done.

**First:** Read `~/.claude/skills/linear-common/COMMON.md` for shared setup instructions.

## Workflow

### 1. Setup (from COMMON.md)
- Load project config
- Select task (from `$ARGUMENTS`)
- Set up worktree
- Gather context

### 2. Plan

1. Analyze the issue requirements and the codebase context you gathered.
2. Break the work into logical commits.
3. If the issue is non-trivial, write a brief plan as a comment on the Linear issue.
4. Identify risks or open questions. If they're blocking, ask the user. If not, note them and proceed with best judgment.

### 3. Implement

Follow the implementation guidelines from COMMON.md.

After implementation is complete:
1. Run the `buildCommand` from the config. All checks must pass before opening a PR.
2. If tests fail, fix them. Do not ship broken code.

### 4. Open PR

1. Push the branch: `git push -u origin <branch>`
2. Open a PR with `gh pr create`:
   - Title: concise, under 70 characters
   - Body format:
     ```
     ## Summary
     <bullets>

     ## Linear
     Closes <ISSUE-ID>

     ## Test plan
     <what was tested and how>
     ```
   - Request reviewers from `prReviewers` if configured.
3. Move the Linear issue to "In Review" (or equivalent status).

### 5. Review loop

Repeat until the PR is approved and CI passes:

1. Poll for reviews:
   ```
   gh pr view <number> --json reviews,reviewRequests,statusCheckRollup
   gh api repos/{owner}/{repo}/pulls/{number}/comments
   ```

2. For each review comment:
   - **Valid feedback**: fix the code, commit, push.
   - **Misunderstanding**: reply explaining, resolve the thread.
   - Resolve addressed threads via GraphQL:
     ```
     gh api graphql -f query='mutation { resolveReviewThread(input: {threadId: "<ID>"}) { thread { isResolved } } }'
     ```
   - Find thread IDs:
     ```
     gh api graphql -f query='{ repository(owner: "<OWNER>", name: "<REPO>") { pullRequest(number: <N>) { reviewThreads(first: 100) { nodes { id isResolved comments(first: 1) { nodes { body } } } } } } }'
     ```

3. After addressing all comments, verify the build still passes.

4. Continue until:
   - All review threads resolved
   - CI checks pass
   - No pending review requests

5. Move the Linear issue to "Done" (or "Ready to merge" if that status exists).
