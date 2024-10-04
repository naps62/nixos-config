{ inputs, pkgs, foundry, ... }: {
  # home.packages = [ pkgs.foundry-bin pkgs.solc ];

  programs = { gh.enable = true; };
}
