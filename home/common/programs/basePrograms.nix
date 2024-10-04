{ inputs, pkgs, foundry, ... }: {
  home.packages = with pkgs; [ foundry-bin solc ];
  programs = { gh.enable = true; };
}
