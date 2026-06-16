{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  avatar = pkgs.fetchurl {
    url = "https://github.com/naps62.png";
    sha256 = "1ck11xg4rwcvn8dcc06ax7i9yfzy21v1n6h5mcjrkrici5sznlsv";
  };
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  # Noctalia v5 rewrote the config schema (TOML, snake_case, flat sections).
  # The v4 settings (appLauncher.*, bar.widgets.*, controlCenter.shortcuts.*, etc.)
  # have no v5 equivalents — most must now be tweaked through the in-shell
  # Settings UI. See docs.noctalia.dev/v5 and example.toml in the upstream repo.
  programs.noctalia = {
    enable = true;
    settings = {
      shell = {
        font_family = "Sans Serif";
        avatar_path = "${config.home.homeDirectory}/.face";
        telemetry_enabled = false;
        polkit_agent = true;
      };

      wallpaper = {
        enabled = true;
        fill_mode = "crop";
        directory = "${config.home.homeDirectory}/.cache/wallpapers/3840x2160";
        transition = [ "fade" ];
        transition_duration = 1500;
        automation = {
          enabled = true;
          interval_minutes = 360;
          order = "random";
          recursive = true;
        };
      };

      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Nord";
        templates = {
          enable_builtin_templates = true;
          builtin_ids = [
            "btop"
            "gtk3"
            "gtk4"
            "hyprland"
            "kitty"
            "qt"
          ];
        };
      };

      notification.enable_daemon = true;

      weather = {
        enabled = true;
        unit = "celsius";
      };

      location = {
        auto_locate = false;
        address = "Braga, Portugal";
      };

      nightlight = {
        enabled = true;
        temperature_day = 6500;
        temperature_night = 4000;
      };

      bar.main = {
        position = "top";
        background_opacity = 0.93;
        radius = 12;
        start = [ "launcher" "wallpaper" "workspaces" ];
        center = [ "media" "clock" ];
        end = [ "tray" "notifications" "network" "bluetooth" "volume" "brightness" "battery" "control-center" "session" ];
      };
    };
  };

  home.file.".face".source = avatar;

  # force overwrite files that noctalia may have turned into regular files
  xdg.configFile."hypr/hyprland.conf".force = true;
  xdg.configFile."gtk-3.0/gtk.css".force = true;

  # source noctalia-generated color theme in hyprland (v5 path).
  # Hyprland globs every source path, so a missing file errors as
  # "globbing error: found no match" — pre-create an empty placeholder
  # so the first boot doesn't fail before noctalia has run.
  home.activation.ensureNoctaliaHyprConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.config/hypr"
    run touch "$HOME/.config/hypr/noctalia.conf"
  '';

  wayland.windowManager.hyprland.settings.source = [
    "~/.config/hypr/noctalia.conf"
  ];
}
