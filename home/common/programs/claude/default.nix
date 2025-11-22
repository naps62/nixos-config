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

  home.file.".claude/commands".source = ./commands;
  home.file.".claude/settings.json".source = ./settings.json;
  home.file.".claude/CLAUDE.md".source = ./CLAUDE.md;
}
