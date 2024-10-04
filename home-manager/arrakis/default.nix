{ inputs, lib, pkgs, config, outputs, catppuccin, ... }: {
  imports = [
    inputs.nix-colors.homeManagerModule
    inputs.nixvim.homeManagerModules.nixvim
    catppuccin.homeManagerModules.catppuccin
    ../common/programs/default.nix
    ../common/programs/hyprland.nix
    ../common/programs/eww
    ../common/programs/kitty.nix
    ../common/features/colorscheme.nix
  ];

  home.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GDM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  wayland.windowManager.hyprland.settings = {
    monitor = [ "eDP-1, preferred, 0x1080, 1.2, bitdepth, 8" ];
    windowrulev2 = [
      "float, class:thunar"
      "move cursor -50% -50%, class:thunar"
      "size 800 600, class:thunar"
    ];
  };

  programs.kitty.settings.font_size = 8;

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
