{ inputs, pkgs, ... }: {
  imports = [ inputs.nvchad4nix.homeManagerModule ];
  home.sessionVariables = { EDITOR = "nvim"; };
  programs.nvchad = { enable = true; };
}
