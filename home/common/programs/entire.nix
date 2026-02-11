{
  pkgs,
  ...
}:
let
  entire = pkgs.callPackage ../../../pkgs/entire/package.nix { };
in
{
  home.packages = [ entire ];
}
