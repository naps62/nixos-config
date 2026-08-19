_:
{
  # Global rules (opencode/AGENTS.md) and the shared commands (merge, update)
  # come from the agent-skills home-manager module — opencode has no @file
  # imports, so the module concatenates the shared fragments into one file.
  # opencode also auto-loads skills from ~/.claude/skills and ~/.agents/skills.
  xdg.configFile = {
    # Global config file
    "opencode/opencode.json".source = ./opencode.json;

    # Custom agents
    "opencode/agents/oracle.md".source = ./agents/oracle.md;
    "opencode/agents/explorer.md".source = ./agents/explorer.md;
    "opencode/agents/librarian.md".source = ./agents/librarian.md;
    "opencode/agents/fixer.md".source = ./agents/fixer.md;
    "opencode/agents/designer.md".source = ./agents/designer.md;
    "opencode/agents/designer-bold.md".source = ./agents/designer-bold.md;
    "opencode/agents/analyze-branch.md".source = ./agents/analyze-branch.md;

    # Global commands (opencode-specific ones only)
    "opencode/commands/work.md".source = ./commands/work.md;
    "opencode/commands/smart-debug.md".source = ./commands/smart-debug.md;
    "opencode/commands/tdd-cycle.md".source = ./commands/tdd-cycle.md;
    "opencode/commands/security-scan.md".source = ./commands/security-scan.md;
    "opencode/commands/issue.md".source = ./commands/issue.md;
    "opencode/commands/remove-deadcode.md".source = ./commands/remove-deadcode.md;
    "opencode/commands/worktree-compare.md".source = ./commands/worktree-compare.md;
    "opencode/commands/worktree-list.md".source = ./commands/worktree-list.md;

    # Skills
    "opencode/skills/git-master/SKILL.md".source = ./skills/git-master/SKILL.md;
    "opencode/skills/planning-with-files/SKILL.md".source =
      ./skills/planning-with-files/SKILL.md;
    "opencode/skills/react-patterns/SKILL.md".source = ./skills/react-patterns/SKILL.md;
    "opencode/skills/vercel-react-best-practices/SKILL.md".source =
      ./skills/vercel-react-best-practices/SKILL.md;
  };
}
