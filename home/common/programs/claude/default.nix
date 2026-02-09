{
  lib,
  pkgs,
  config,
  ...
}:
{
  home.file.".default-npm-packages".text = ''
    @anthropic-ai/claude-code
  '';

  # Create writable commands directory and symlink individual command files
  home.activation.claudeCommandsDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
    COMMANDS_DIR="$HOME/.claude/commands"
    SETTINGS_FILE="$HOME/.claude/settings.json"

    # Remove old symlink if it exists
    if [ -L "$COMMANDS_DIR" ]; then
      $DRY_RUN_CMD rm -f "$COMMANDS_DIR"
    fi

    # Create the directory if it doesn't exist
    $DRY_RUN_CMD mkdir -p "$COMMANDS_DIR"

    # Symlink individual command files from nix store
    $DRY_RUN_CMD ln -sf ${./commands/merge.md} "$COMMANDS_DIR/merge.md"
    $DRY_RUN_CMD ln -sf ${./commands/update.md} "$COMMANDS_DIR/update.md"
    $DRY_RUN_CMD ln -sf ${./commands/work.md} "$COMMANDS_DIR/work.md"

    # Agents (adapted from opencode)
    $DRY_RUN_CMD ln -sf ${./commands/designer-bold.md} "$COMMANDS_DIR/designer-bold.md"
    $DRY_RUN_CMD ln -sf ${./commands/designer.md} "$COMMANDS_DIR/designer.md"
    $DRY_RUN_CMD ln -sf ${./commands/analyze-branch.md} "$COMMANDS_DIR/analyze-branch.md"
    $DRY_RUN_CMD ln -sf ${./commands/oracle.md} "$COMMANDS_DIR/oracle.md"
    $DRY_RUN_CMD ln -sf ${./commands/librarian.md} "$COMMANDS_DIR/librarian.md"

    # Skills (adapted from opencode)
    $DRY_RUN_CMD ln -sf ${./commands/git-master.md} "$COMMANDS_DIR/git-master.md"
    $DRY_RUN_CMD ln -sf ${./commands/planning-with-files.md} "$COMMANDS_DIR/planning-with-files.md"
    $DRY_RUN_CMD ln -sf ${./commands/react-patterns.md} "$COMMANDS_DIR/react-patterns.md"
    $DRY_RUN_CMD ln -sf ${./commands/vercel-react-best-practices.md} "$COMMANDS_DIR/vercel-react-best-practices.md"

    # Commands (adapted from opencode)
    $DRY_RUN_CMD ln -sf ${./commands/smart-debug.md} "$COMMANDS_DIR/smart-debug.md"
    $DRY_RUN_CMD ln -sf ${./commands/tdd-cycle.md} "$COMMANDS_DIR/tdd-cycle.md"
    $DRY_RUN_CMD ln -sf ${./commands/security-scan.md} "$COMMANDS_DIR/security-scan.md"
    $DRY_RUN_CMD ln -sf ${./commands/issue.md} "$COMMANDS_DIR/issue.md"
    $DRY_RUN_CMD ln -sf ${./commands/remove-deadcode.md} "$COMMANDS_DIR/remove-deadcode.md"
    $DRY_RUN_CMD ln -sf ${./commands/worktree-compare.md} "$COMMANDS_DIR/worktree-compare.md"
    $DRY_RUN_CMD ln -sf ${./commands/worktree-list.md} "$COMMANDS_DIR/worktree-list.md"

    # Copy settings.json to make it writable (only if it doesn't exist or is a symlink)
    if [ -L "$SETTINGS_FILE" ] || [ ! -f "$SETTINGS_FILE" ]; then
      $DRY_RUN_CMD rm -f "$SETTINGS_FILE"
      $DRY_RUN_CMD cp ${./settings.json} "$SETTINGS_FILE"
      $DRY_RUN_CMD chmod 644 "$SETTINGS_FILE"
    fi
  '';
  home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;
}
