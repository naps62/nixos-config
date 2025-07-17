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
    ../common/programs/zen-browser.nix
    ../common/programs/hyprland
    ../common/programs/i3.nix
    ../common/programs/ghostty.nix
    ../common/programs/kitty.nix
    ../common/programs/syncthing.nix
    ../common/programs/unity.nix
    ../common/programs/gpg.nix
    ../common/features/xdg.nix
    ../common/features/bluetooth.nix
    ./monitors.nix
  ];

  wayland.windowManager.hyprland.settings = {
    workspace = [
      "1, monitor:DP-3"
      "2, monitor:eDP-1"
      "3, monitor:eDP-1"
      "4, monitor:eDP-1"
    ];

    windowrulev2 = [
      "noinitialfocus, class:bevy-.*"
      "float, class:bevy-.*"
      "size 800 600, class:bevy-.*"
      "move 100%-800 100%-600, class:bevy-.*"
    ];

    env = [
      "GDK_SCALE, 1.5"
    ];
  };

  programs.hyprpanel.settings.layout = {
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
