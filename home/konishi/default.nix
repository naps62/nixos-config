{
  ...
}:
{
  imports = [
    ../common/programs/default.nix
    ../common/programs/desktop
    ../common/programs/zen-browser.nix
    ../common/programs/hyprland
    ../common/programs/kitty
    ../common/programs/gpg.nix
    ../common/programs/ethui.nix
    ../common/programs/3d.nix
    ../common/programs/godot.nix
    ../common/programs/gaming.nix
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

  custom.gaming = {
    enable = true;
    nvidia = true;
  };

  wayland.windowManager.hyprland.settings = {
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

      # gaming: Steam/Proton titles run under XWayland with WM_CLASS
      # steam_app_<appid>. Send them fullscreen to workspace 3 (DP-1) — the same
      # streamed workspace as Big Picture below — instead of opening tiled on
      # whatever monitor Steam is on.
      # Native (non-Proton) games have their own class — grab it with
      # `hyprctl clients | grep -iE "class|title"` while the game runs and add a
      # matching line here.
      "workspace 3, match:class steam_app_.*"
      "fullscreen on, match:class steam_app_.*"

      # Steam Big Picture shares the plain `steam` WM_CLASS with the normal
      # client, so match its title instead. Without this it opens on whatever
      # monitor the cursor is on, not the streamed one. Pin it to ws3 — DP-1's
      # normal persistent workspace, which is what the stream captures. `.`
      # stands in for the literal spaces to keep the rule string unambiguous.
      "workspace 3, match:title Steam.Big.Picture.Mode"
      "fullscreen on, match:title Steam.Big.Picture.Mode"
    ];

    render = {
      direct_scanout = true;
    };

  };

  programs.noctalia.settings = {
    shell.ui_scale = 1.25;
    notification.monitors = [ "DP-1" ];
    # NOTE: v5 has no per-monitor wallpaper directories; only directory_light /
    # directory_dark. Re-add via Settings UI if upstream gains support.
  };

  programs.kitty.settings.font_size = 16;
}
