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
    ../common/programs/ethui.nix
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
      "workspace 1, class:ethui"
      "noinitialfocus, class:ethui"

      "workspace 3 silent, class:bevy-.*"
      "noinitialfocus, class:bevy-.*"
      "fullscreen, class:bevy-.*"
    ];

    render = {
      explicit_sync = 2;
      explicit_sync_kms = 0;
      direct_scanout = true;
    };

    opengl = {
      nvidia_anti_flicker = 0;
    };

    misc = {
      vfr = 0;
    };

    debug = {
      damage_tracking = 0;
    };
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

  programs.kitty.settings.font_size = 16;

  home = {
    username = lib.mkDefault "naps62";
    stateVersion = lib.mkDefault "24.05";
  };
}
