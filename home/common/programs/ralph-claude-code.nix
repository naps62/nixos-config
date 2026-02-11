{
  pkgs,
  ...
}:
let
  ralph-claude-code = pkgs.callPackage ../../../pkgs/ralph-claude-code/package.nix { };
in
{
  home.packages = [ ralph-claude-code ];
}
