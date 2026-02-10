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

  # Create writable commands/skills directories and symlink files
  home.activation.claudeCommandsDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    COMMANDS_DIR="$HOME/.claude/commands"
    SKILLS_DIR="$HOME/.claude/skills"
    SETTINGS_FILE="$HOME/.claude/settings.json"

    # Remove old symlinks if they exist
    if [ -L "$COMMANDS_DIR" ]; then
      $DRY_RUN_CMD rm -f "$COMMANDS_DIR"
    fi
    if [ -L "$SKILLS_DIR" ]; then
      $DRY_RUN_CMD rm -f "$SKILLS_DIR"
    fi

    # Create directories
    $DRY_RUN_CMD mkdir -p "$COMMANDS_DIR"
    $DRY_RUN_CMD mkdir -p "$SKILLS_DIR"

    # Commands
    $DRY_RUN_CMD ln -sf ${./commands/merge.md} "$COMMANDS_DIR/merge.md"
    $DRY_RUN_CMD ln -sf ${./commands/update.md} "$COMMANDS_DIR/update.md"
    $DRY_RUN_CMD ln -sf ${./commands/work.md} "$COMMANDS_DIR/work.md"

    # Skills: agents (adapted from opencode)
    $DRY_RUN_CMD mkdir -p "$SKILLS_DIR"/{designer-bold,designer,analyze-branch,oracle,librarian}
    $DRY_RUN_CMD ln -sf ${./skills/designer-bold/SKILL.md} "$SKILLS_DIR/designer-bold/SKILL.md"
    $DRY_RUN_CMD ln -sf ${./skills/designer/SKILL.md} "$SKILLS_DIR/designer/SKILL.md"
    $DRY_RUN_CMD ln -sf ${./skills/analyze-branch/SKILL.md} "$SKILLS_DIR/analyze-branch/SKILL.md"
    $DRY_RUN_CMD ln -sf ${./skills/oracle/SKILL.md} "$SKILLS_DIR/oracle/SKILL.md"
    $DRY_RUN_CMD ln -sf ${./skills/librarian/SKILL.md} "$SKILLS_DIR/librarian/SKILL.md"

    # Skills: knowledge (adapted from opencode)
    $DRY_RUN_CMD mkdir -p "$SKILLS_DIR"/{git-master,planning-with-files,react-patterns,vercel-react-best-practices}
    $DRY_RUN_CMD ln -sf ${./skills/git-master/SKILL.md} "$SKILLS_DIR/git-master/SKILL.md"
    $DRY_RUN_CMD ln -sf ${./skills/planning-with-files/SKILL.md} "$SKILLS_DIR/planning-with-files/SKILL.md"
    $DRY_RUN_CMD ln -sf ${./skills/react-patterns/SKILL.md} "$SKILLS_DIR/react-patterns/SKILL.md"
    $DRY_RUN_CMD ln -sf ${./skills/vercel-react-best-practices/SKILL.md} "$SKILLS_DIR/vercel-react-best-practices/SKILL.md"

    # Skills: workflows (adapted from opencode)
    $DRY_RUN_CMD mkdir -p "$SKILLS_DIR"/{smart-debug,tdd-cycle,security-scan,issue,remove-deadcode,worktree-compare,worktree-list}
    $DRY_RUN_CMD ln -sf ${./skills/smart-debug/SKILL.md} "$SKILLS_DIR/smart-debug/SKILL.md"
    $DRY_RUN_CMD ln -sf ${./skills/tdd-cycle/SKILL.md} "$SKILLS_DIR/tdd-cycle/SKILL.md"
    $DRY_RUN_CMD ln -sf ${./skills/security-scan/SKILL.md} "$SKILLS_DIR/security-scan/SKILL.md"
    $DRY_RUN_CMD ln -sf ${./skills/issue/SKILL.md} "$SKILLS_DIR/issue/SKILL.md"
    $DRY_RUN_CMD ln -sf ${./skills/remove-deadcode/SKILL.md} "$SKILLS_DIR/remove-deadcode/SKILL.md"
    $DRY_RUN_CMD ln -sf ${./skills/worktree-compare/SKILL.md} "$SKILLS_DIR/worktree-compare/SKILL.md"
    $DRY_RUN_CMD ln -sf ${./skills/worktree-list/SKILL.md} "$SKILLS_DIR/worktree-list/SKILL.md"

    # Copy settings.json to make it writable (only if it doesn't exist or is a symlink)
    if [ -L "$SETTINGS_FILE" ] || [ ! -f "$SETTINGS_FILE" ]; then
      $DRY_RUN_CMD rm -f "$SETTINGS_FILE"
      $DRY_RUN_CMD cp ${./settings.json} "$SETTINGS_FILE"
      $DRY_RUN_CMD chmod 644 "$SETTINGS_FILE"
    fi
  '';
  home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;
}
