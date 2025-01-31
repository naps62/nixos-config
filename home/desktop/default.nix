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
    inputs.nixvim.homeManagerModules.nixvim
    ../common/programs/default.nix
    ../common/programs/desktop
    ../common/programs/hyprland
    ../common/programs/kitty.nix
    ../common/programs/ghostty.nix
    ../common/programs/syncthing.nix
    ../common/programs/gpg.nix
    ../common/features/xdg.nix
    ../common/features/bluetooth.nix
    ../common/features/ledger.nix
    ./monitors.nix
  ];

  home.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GDM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  wayland.windowManager.hyprland.settings = {
    windowrulev2 = [
      # ethui-dev
      "workspace 1, class:ethui"
      "float, class:ethui"
      "size 800 800, class:ethui"
      "move 100%-800 100%-800, class:ethui"
      "noinitialfocus, class:ethui"
    ];

    env = [
      "GDK_SCALE, 2"
    ];
  };

  programs.kitty.settings.font_size = 12;

  home = {
    username = lib.mkDefault "naps62";
    stateVersion = lib.mkDefault "24.05";
  };
}
