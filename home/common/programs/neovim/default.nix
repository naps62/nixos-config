{ inputs, pkgs, ... }:
{
  imports = [ inputs.nvchad4nix.homeManagerModule ];
  home.sessionVariables = {
    EDITOR = "nvim";
  };
  home.packages = with pkgs; [
    nixfmt
    biome
    stylua
  ];

  programs.nvchad = {
    enable = true;
  };
}
