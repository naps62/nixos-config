{ inputs, lib, pkgs, config, outputs, ... }: {
  imports = [
    inputs.nix-colors.homeManagerModule
    inputs.nixvim.homeManagerModules.nixvim
    ../common/programs/default.nix
  ];

  colorscheme = inputs.nix-colors.colorSchemes.catppuccin-frappe;

  programs = {
    home-manager.enable = true;
    git.enable = true;
    fzf.enable = true;
  };

  home = {
    username = lib.mkDefault "naps62";
    stateVersion = lib.mkDefault "24.05";
  };
}
