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
    ../common/programs/kitty.nix
    ../common/programs/ghostty.nix
    ../common/programs/syncthing.nix
    ../common/programs/gpg.nix
    ../common/features/colorscheme.nix
    ../common/features/xdg.nix
    ../common/features/bluetooth.nix
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
      # thunar
      "float, class:thunar"
      "move cursor -50% -50%, class:thunar"
      "size 800 600, class:thunar"

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

  programs.hyprpanel.layout = {
    "bar.layouts" = {
      "0" = {
        "left" = [
          "dashboard"
          "workspaces"
          "windowtitle"
        ];
        "middle" = [ "media" ];
        "right" = [
          "volume"
          "network"
          "bluetooth"
          "systray"
          "clock"
          "notifications"
        ];
      };
      "1" = {
        "left" = [ ];
        "middle" = [ ];
        "right" = [ ];
      };
      "2" = {
        "left" = [ ];
        "middle" = [ ];
        "right" = [ ];
      };
    };

  };

  programs.kitty.settings.font_size = 12;

  home = {
    username = lib.mkDefault "naps62";
    stateVersion = lib.mkDefault "24.05";
  };

}
