{ inputs, pkgs, ... }:
{
  imports = [ inputs.nvchad4nix.homeManagerModule ];
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.packages = with pkgs; [
    nixfmt-rfc-style
    biome
    stylua
    neovide
  ];

  programs.nvchad = {
    enable = true;
  };
}
