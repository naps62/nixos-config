{ inputs, pkgs, ... }:
{
  imports = [ inputs.walker.homeManagerModules.default ];

  programs.walker = {
    enable = true;
    runAsService = true;

    # Using default theme - clean dark theme with good defaults
    # You can customize later by copying from:
    # https://github.com/abenz1267/walker/tree/master/resources/themes/default
  };
}
