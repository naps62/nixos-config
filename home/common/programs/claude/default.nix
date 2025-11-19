{
  lib,
  pkgs,
  config,
  ...
}:
{
  home.file.".claude/commands".source = ./commands;
}
