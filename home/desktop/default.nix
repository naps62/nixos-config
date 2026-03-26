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
    ../common/programs/default.nix
    ../common/programs/desktop
    ../common/programs/zen-browser.nix
    ../common/programs/hyprland
    ../common/programs/kitty
    ../common/programs/syncthing.nix
    ../common/programs/unity.nix
    ../common/programs/gpg.nix
    ../common/programs/ethui.nix
    ../common/programs/3d.nix
    ../common/programs/nerd-dictation.nix
    ../common/features/xdg.nix
    ../common/features/downloads-cleanup.nix
    ./monitors.nix
  ];

  home.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    GDM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  custom.hyprland = {
    yaziSize = "2400 1800";
    cursorSize = 42;
  };

  wayland.windowManager.hyprland.settings = {
    env = [
      "WEBKIT_DISABLE_DMABUF_RENDERER, 1"
    ];

    exec-once = [
      "$HOME/.local/bin/hyprpaper-rotate"
    ];

    windowrule = [
      # ethui-dev
      "workspace 2, match:title ethui-dev.*"
      "no_initial_focus on, match:title ethui-dev.*"
      "float on, match:title ethui-dev - dialog.*"

      "workspace 1, match:title ethui.*"
      "no_initial_focus on, match:title ethui.*"
      "float on, match:title ethui - dialog.*"

      "workspace 1, match:title ^\\[bevy\\].*"

      "workspace 3 silent, match:class bevy-.*"
      "no_initial_focus on, match:class bevy-.*"
      "fullscreen on, match:class bevy-.*"

      "workspace 1 silent, match:title egui-.*"
      "border_size 0, match:title egui-.*"
      "float on, match:title egui-.*"
      "no_blur on, match:title egui-.*"
      "move 100%-w-20 100%-h-20, match:title egui-.*"
    ];

    render = {
      direct_scanout = true;
    };

  };

  programs.noctalia-shell.settings = {
    bar = {
      density = "spacious";
    };
    notifications = {
      monitors = [ "DP-1" ];
    };
    ui = {
      fontDefaultScale = 1.25;
      fontFixedScale = 1.25;
    };
    wallpaper = {
      enableMultiMonitorDirectories = true;
      monitorDirectories = [
        { monitor = "HDMI-A-1"; directory = "${config.home.homeDirectory}/.cache/wallpapers/3840x2160"; }
        { monitor = "DP-1";     directory = "${config.home.homeDirectory}/.cache/wallpapers/3840x2160"; }
        { monitor = "DP-2";     directory = "${config.home.homeDirectory}/.cache/wallpapers/2160x3840"; }
      ];
    };
  };

  programs.kitty.settings.font_size = 16;
}
