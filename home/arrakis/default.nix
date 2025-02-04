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
    ../common/programs/ghostty.nix
    ../common/programs/syncthing.nix
    ../common/programs/gpg.nix
    ../common/features/xdg.nix
    ../common/features/bluetooth.nix
    ./monitors.nix
  ];

  home.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
  };

  wayland.windowManager.hyprland.settings = {
    monitor = [
      "eDP-1, 1920x1200, 0x0, 1"
      "DP-1, preferred, -320x-1200, 1"
    ];

    workspace = [
      "1, monitor:DP-1"
      "2, monitor:eDP-1"
      "3, monitor:eDP-1"
      "4, monitor:eDP-1"
    ];

    windowrulev2 = [
      # ethui-dev
      # "workspace 2 silent, class:ethui"
      # "float, class:ethui"
      # "size 800 800, class:ethui"
      # "move 100%-800 100%-800, class:ethui"
      # "noinitialfocus, class:ethui"
    ];

    env = [
      "GDK_SCALE, 1.5"
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
          "power"
          "bluetooth"
          "systray"
          "clock"
          "notifications"
        ];
      };
      "*" = {
        "left" = [ ];
        "middle" = [ ];
        "right" = [ ];
      };
    };
  };

  home = {
    username = lib.mkDefault "naps62";
    stateVersion = lib.mkDefault "24.05";
  };
}
