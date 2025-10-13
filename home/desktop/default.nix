{
  inputs,
  lib,
  pkgs,
  config,
  outputs,
  ...
}:
{
  imports = [
    inputs.nix-colors.homeManagerModule
    inputs.nixvim.homeModules.nixvim
    ../common/programs/default.nix
    ../common/programs/desktop
    ../common/programs/zen-browser.nix
    ../common/programs/hyprland
    ../common/programs/i3.nix
    ../common/programs/kitty.nix
    ../common/programs/syncthing.nix
    ../common/programs/unity.nix
    ../common/programs/gpg.nix
    ../common/programs/ethui.nix
    ../common/programs/3d.nix
    ../common/features/xdg.nix
    ../common/features/bluetooth.nix
    ../common/features/ledger.nix
    ./monitors.nix
  ];

  home.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GDM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      # ethui-dev
      "workspace 1, title:ethui-dev.*"
      "noinitialfocus, title:ethui-dev.*"
      "float, title:ethui-dev - dialog.*"

      "workspace 3 silent, class:bevy-.*"
      "noinitialfocus, class:bevy-.*"
      "fullscreen, class:bevy-.*"

      "workspace 1 silent, title:egui-.*"
      "bordersize 0, title:egui-.*"
      "float, title:egui-.*"
      "noblur, title:egui-.*"
      "move 100%-w-20 100%-h-20, title:egui-.*"
    ];

    render = {
      direct_scanout = true;
    };

  };

  programs.kitty.settings.font_size = 16;

  home = {
    username = lib.mkDefault "naps62";
    stateVersion = lib.mkDefault "24.05";
  };
}
