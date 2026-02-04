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

    # Copy settings.json to make it writable (only if it doesn't exist or is a symlink)
    if [ -L "$SETTINGS_FILE" ] || [ ! -f "$SETTINGS_FILE" ]; then
      $DRY_RUN_CMD rm -f "$SETTINGS_FILE"
      $DRY_RUN_CMD cp ${./settings.json} "$SETTINGS_FILE"
      $DRY_RUN_CMD chmod 644 "$SETTINGS_FILE"
    fi
  '';
  home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;
}
