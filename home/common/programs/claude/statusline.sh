#!/bin/bash
input=$(cat)

# Extract values from JSON input
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // "~"')
DIR_NAME="${DIR##*/}"
CONTEXT_USED=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# Get git repo root path (abbreviated with ~) and branch/PR info
GIT_INFO=""
REPO_PATH=""
if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
    REPO_ROOT=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null)
    # For worktrees, get the main repo root instead of the worktree path
    MAIN_GIT_DIR=$(git -C "$DIR" rev-parse --git-common-dir 2>/dev/null)
    if [ -n "$MAIN_GIT_DIR" ] && [[ "$MAIN_GIT_DIR" == /* ]]; then
        REPO_ROOT=$(dirname "$MAIN_GIT_DIR")
    fi
    # Abbreviate ~/projects/ to p/
    REPO_PATH=" | ${REPO_ROOT/#$HOME\/projects\//p/}"
    BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        PR_NUMBER=$(GIT_DIR="$DIR/.git" GIT_WORK_TREE="$DIR" gh pr view --json number -q '.number' 2>/dev/null)
        if [ -n "$PR_NUMBER" ]; then
            GIT_INFO=" | $BRANCH (#$PR_NUMBER)"
        else
            GIT_INFO=" | $BRANCH"
        fi
    fi
fi

# Format cost
COST_FMT=$(printf "%.2f" "$COST")

echo "YOLO$REPO_PATH$GIT_INFO | [$MODEL] | \$$COST_FMT | ${CONTEXT_USED}%"
