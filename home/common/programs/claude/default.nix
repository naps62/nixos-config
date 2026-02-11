{ ... }:
{
  home.file.".default-npm-packages".text = ''
    @anthropic-ai/claude-code
  '';

  # Commands
  home.file.".claude/commands/merge.md".source = ./commands/merge.md;
  home.file.".claude/commands/update.md".source = ./commands/update.md;
  home.file.".claude/commands/work.md".source = ./commands/work.md;

  # Skills: agents
  home.file.".claude/skills/designer-bold/SKILL.md".source = ./skills/designer-bold/SKILL.md;
  home.file.".claude/skills/designer/SKILL.md".source = ./skills/designer/SKILL.md;
  home.file.".claude/skills/frontend-design/SKILL.md".source = ./skills/frontend-design/SKILL.md;
  home.file.".claude/skills/analyze-branch/SKILL.md".source = ./skills/analyze-branch/SKILL.md;
  home.file.".claude/skills/oracle/SKILL.md".source = ./skills/oracle/SKILL.md;
  home.file.".claude/skills/librarian/SKILL.md".source = ./skills/librarian/SKILL.md;

  # Skills: knowledge
  home.file.".claude/skills/git-master/SKILL.md".source = ./skills/git-master/SKILL.md;
  home.file.".claude/skills/planning-with-files/SKILL.md".source = ./skills/planning-with-files/SKILL.md;
  home.file.".claude/skills/react-patterns/SKILL.md".source = ./skills/react-patterns/SKILL.md;
  home.file.".claude/skills/vercel-react-best-practices/SKILL.md".source = ./skills/vercel-react-best-practices/SKILL.md;

  # Skills: workflows
  home.file.".claude/skills/smart-debug/SKILL.md".source = ./skills/smart-debug/SKILL.md;
  home.file.".claude/skills/tdd-cycle/SKILL.md".source = ./skills/tdd-cycle/SKILL.md;
  home.file.".claude/skills/security-scan/SKILL.md".source = ./skills/security-scan/SKILL.md;
  home.file.".claude/skills/issue/SKILL.md".source = ./skills/issue/SKILL.md;
  home.file.".claude/skills/remove-deadcode/SKILL.md".source = ./skills/remove-deadcode/SKILL.md;
  home.file.".claude/skills/worktree-compare/SKILL.md".source = ./skills/worktree-compare/SKILL.md;
  home.file.".claude/skills/worktree-list/SKILL.md".source = ./skills/worktree-list/SKILL.md;

  home.file.".claude/settings.json".source = ./settings.json;
  home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;
}
