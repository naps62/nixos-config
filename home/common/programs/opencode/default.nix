{
  lib,
  pkgs,
  config,
  ...
}:
{
  # Global config file
  xdg.configFile."opencode/opencode.json".source = ./opencode.json;

  # Global rules (equivalent to ~/.claude/CLAUDE.md)
  xdg.configFile."opencode/AGENTS.md".source = ./AGENTS.md;

  # Custom agents
  xdg.configFile."opencode/agents/oracle.md".source = ./agents/oracle.md;
  xdg.configFile."opencode/agents/explorer.md".source = ./agents/explorer.md;
  xdg.configFile."opencode/agents/librarian.md".source = ./agents/librarian.md;
  xdg.configFile."opencode/agents/fixer.md".source = ./agents/fixer.md;
  xdg.configFile."opencode/agents/designer.md".source = ./agents/designer.md;
  xdg.configFile."opencode/agents/designer-bold.md".source = ./agents/designer-bold.md;
  xdg.configFile."opencode/agents/analyze-branch.md".source = ./agents/analyze-branch.md;

  # Global commands
  xdg.configFile."opencode/commands/work.md".source = ./commands/work.md;
  xdg.configFile."opencode/commands/merge.md".source = ./commands/merge.md;
  xdg.configFile."opencode/commands/update.md".source = ./commands/update.md;
  xdg.configFile."opencode/commands/smart-debug.md".source = ./commands/smart-debug.md;
  xdg.configFile."opencode/commands/tdd-cycle.md".source = ./commands/tdd-cycle.md;
  xdg.configFile."opencode/commands/security-scan.md".source = ./commands/security-scan.md;
  xdg.configFile."opencode/commands/issue.md".source = ./commands/issue.md;
  xdg.configFile."opencode/commands/remove-deadcode.md".source = ./commands/remove-deadcode.md;
  xdg.configFile."opencode/commands/worktree-compare.md".source = ./commands/worktree-compare.md;
  xdg.configFile."opencode/commands/worktree-list.md".source = ./commands/worktree-list.md;

  # Skills
  xdg.configFile."opencode/skills/git-master/SKILL.md".source = ./skills/git-master/SKILL.md;
  xdg.configFile."opencode/skills/planning-with-files/SKILL.md".source =
    ./skills/planning-with-files/SKILL.md;
  xdg.configFile."opencode/skills/react-patterns/SKILL.md".source = ./skills/react-patterns/SKILL.md;
  xdg.configFile."opencode/skills/vercel-react-best-practices/SKILL.md".source =
    ./skills/vercel-react-best-practices/SKILL.md;
}
