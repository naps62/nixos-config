#!/usr/bin/env bash
# NixOS has no /bin/bash; use env so the shebang resolves on all hosts.
input=$(cat)

# Extract values from JSON input
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // "~"')
CONTEXT_USED=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')

# Machine hostname (bash sets HOSTNAME; fall back to /etc/hostname)
HOST="${HOSTNAME:-$(cat /etc/hostname 2>/dev/null || echo host)}"

# Git repo root (abbreviated ~/projects -> p/) and branch/PR info
GIT_INFO=""
REPO_PATH=""
if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
    REPO_ROOT=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null)
    # For worktrees, use the main repo root instead of the worktree path
    MAIN_GIT_DIR=$(git -C "$DIR" rev-parse --git-common-dir 2>/dev/null)
    if [ -n "$MAIN_GIT_DIR" ] && [[ "$MAIN_GIT_DIR" == /* ]]; then
        REPO_ROOT=$(dirname "$MAIN_GIT_DIR")
    fi
    REPO_PATH="${REPO_ROOT/#$HOME\/projects\//p/}"
    BRANCH=$(git -C "$DIR" branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        PR_NUMBER=$(GIT_DIR="$DIR/.git" GIT_WORK_TREE="$DIR" gh pr view --json number -q '.number' 2>/dev/null)
        if [ -n "$PR_NUMBER" ]; then
            GIT_INFO="$BRANCH (#$PR_NUMBER)"
        else
            GIT_INFO="$BRANCH"
        fi
    fi
fi

# Format cost (force C locale so the decimal separator is always ".")
COST_FMT=$(LC_NUMERIC=C printf "%.2f" "$COST")

# Colors
RESET=$'\033[0m'
C_HOST=$'\033[1;36m'   # bold cyan — distinguishes the machine
C_PATH=$'\033[32m'     # green
C_BRANCH=$'\033[33m'   # yellow
C_MODEL=$'\033[35m'    # magenta
C_COST=$'\033[32m'     # green
SEP=$'\033[90m | \033[0m'  # dim separator

# Context % colored by fill level: green < 50, yellow < 80, red >= 80
CTX_INT=${CONTEXT_USED%.*}; CTX_INT=${CTX_INT:-0}
if [ "$CTX_INT" -ge 80 ] 2>/dev/null; then
    C_CTX=$'\033[31m'
elif [ "$CTX_INT" -ge 50 ] 2>/dev/null; then
    C_CTX=$'\033[33m'
else
    C_CTX=$'\033[32m'
fi

out="${C_HOST}${HOST}${RESET}"
[ -n "$REPO_PATH" ] && out="${out}${SEP}${C_PATH}${REPO_PATH}${RESET}"
[ -n "$GIT_INFO" ] && out="${out}${SEP}${C_BRANCH}${GIT_INFO}${RESET}"
out="${out}${SEP}${C_MODEL}[${MODEL}]${RESET}"
out="${out}${SEP}${C_COST}\$${COST_FMT}${RESET}"
out="${out}${SEP}${C_CTX}${CONTEXT_USED}%${RESET}"
printf '%s\n' "$out"
