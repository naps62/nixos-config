{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  catppuccin,
  ...
}:
{
  imports = [
    inputs.nix-colors.homeManagerModule
    inputs.nixvim.homeManagerModules.nixvim
    catppuccin.homeManagerModules.catppuccin
    ../common/programs/default.nix
    ../common/programs/desktop
    ../common/programs/hyprland
    ../common/programs/eww
    ../common/programs/kitty.nix
    ../common/programs/syncthing.nix
    ../common/features/colorscheme.nix
    ../common/features/xdg.nix
    ../common/features/bluetooth.nix
  ];

  home.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GDM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  wayland.windowManager.hyprland.settings = {
    monitor = [ "eDP-1, preferred, 0x1080, 1, bitdepth, 8" ];
    windowrulev2 = [
      "float, class:thunar"
      "move cursor -50% -50%, class:thunar"
      "size 800 600, class:thunar"
    ];
  };

  programs.kitty.settings.font_size = 12;

  home = {
    username = lib.mkDefault "naps62";
    stateVersion = lib.mkDefault "24.05";
  };

}
