# Linear Common - Shared Config & Setup

This document is referenced by the `/work` and `/yolo` skills. Do not invoke it directly.

## Project config

Look for `.claude/linear.json` in the current git repo root (`git rev-parse --show-toplevel`). If it doesn't exist, run **First-time setup** below, then continue.

### Schema

```json
{
  "org": "ern",
  "team": "Ern",
  "project": "Contracts v2",
  "defaultBranch": "main",
  "commitScope": "platform",
  "buildCommand": "forge test",
  "setupCommands": ["bun install"],
  "contextFiles": ["docs/README.md"],
  "prReviewers": [],
  "labels": []
}
```

| Field | Required | Description |
|---|---|---|
| `org` | yes | Linear organization slug |
| `team` | yes | Linear team name (for listing/creating issues) |
| `project` | no | Linear project name (narrows issue search) |
| `defaultBranch` | no | Base branch, default `main` |
| `commitScope` | no | Conventional commit scope, e.g. `platform` -> `feat(platform): ...` |
| `buildCommand` | no | Command to verify the build. Run after implementation. |
| `setupCommands` | no | Commands to run inside a new worktree (install deps, etc.) |
| `contextFiles` | no | Files to read before coding (specs, architecture docs) |
| `prReviewers` | no | GitHub usernames to request reviews from (`/work` only) |
| `labels` | no | Default Linear labels for ad-hoc issues |

### First-time setup

If `.claude/linear.json` doesn't exist:

1. Ask the user for: `org`, `team`, and optionally `project`.
2. Ask which optional fields they want. Show the table above.
3. Write the file. Suggest they commit it or gitignore it depending on preference.
4. Continue with the task.

## Linear MCP auth

The Linear MCP server supports one org at a time. Before making Linear API calls, verify the current auth matches the configured `org`. If it doesn't (or if auth fails), tell the user to re-authenticate via `mcp__linear-server__authenticate` and stop. Don't try to work around auth issues silently.

## Task selection

Based on `$ARGUMENTS`:

### Linear issue ID provided (e.g. `ERN-347`)
1. Fetch the issue via Linear MCP (`get_issue`).
2. Read the full description, acceptance criteria, and comments.

### Ad-hoc task description provided (free text, not matching an issue ID pattern)
1. Create a new Linear issue in the configured team (and project if set).
2. Apply any configured default `labels`.
3. Use the provided text as the issue title. If it's long, summarize for the title and use the full text as description.

### No argument (auto-pick)
1. List issues in the configured team/project that are unstarted (Backlog, Todo, Ready, or equivalent).
2. Pick the highest-priority unblocked issue.
3. If none found, tell the user and stop.

**In all cases:**
- Move the issue to "In Progress" immediately.
- Note the issue ID, title, and `gitBranchName` for later use.
- Use `gitBranchName` from the Linear response for branch naming (auto-links in Linear).

## Worktree setup

### Already in a worktree
Detect by checking `git worktree list` — if the current working directory is not the main worktree, you're already in one.

If already in a worktree: stay here. Check out the issue branch if the current branch doesn't match.

### Not in a worktree
1. Create a worktree at `worktrees/<branch-name>` relative to the repo root.
   - Use `gitBranchName` from Linear. If unavailable, derive a concise name from the issue title.
   - Do NOT include "claude" in branch names.
2. `cd` into the worktree.
3. Run each command in `setupCommands` from the config.
4. Set kitty tab title (silently skip if kitty isn't available):
   ```
   kitty @ set-tab-title "<repo>/<branch>" 2>/dev/null || true
   ```

## Gather context

1. Read all `contextFiles` from the config.
2. Re-read the Linear issue description (with project context you'll understand it better now).
3. Read `CLAUDE.md` / `AGENTS.md` at the repo root or `.claude/` if they exist, for project conventions.
4. Check recent git history: `git log --oneline -20` to understand current patterns.

## Implementation guidelines

1. Work methodically through the requirements.
2. Commit after each logical step using conventional commits:
   - With scope if configured: `feat(scope): description`
   - Without: `feat: description`
   - Prefixes: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
3. Follow existing code patterns. Match the style of surrounding code.
4. Write tests appropriate to the project (match existing test patterns and coverage level).
5. Never amend commits — always create new ones.
6. Keep the Linear issue updated if scope changes significantly.

## Rules

- **Never ask the user** during autonomous work unless you hit a genuine blocker (architectural contradiction, missing credentials, ambiguous requirements that could go very wrong).
- **If the build fails**, fix it before pushing.
- **Respect existing project conventions** from CLAUDE.md, AGENTS.md, etc.
