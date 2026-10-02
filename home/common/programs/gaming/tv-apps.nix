{
  config,
  lib,
  pkgs,
  ...
}:
# Couch apps for gaming mode. Add them to Steam as non-Steam games so Steam
# Input maps the controller for each one.
let
  cfg = config.custom.gaming;

  # youtube.com/tv only serves the controller-friendly TV UI to a TV user agent.
  youtube-tv = pkgs.writeShellApplication {
    name = "youtube-tv";
    text = ''
      exec ${lib.getExe pkgs.chromium} \
        --user-data-dir="''${XDG_DATA_HOME:-$HOME/.local/share}/youtube-tv" \
        --user-agent="Mozilla/5.0 (SMART-TV; LINUX; Tizen 6.0) AppleWebKit/537.36 (KHTML, like Gecko) 76.0.3809.146/6.0 TV Safari/537.36" \
        --kiosk \
        --app=https://www.youtube.com/tv \
        "$@"
    '';
  };
in
{
  options.custom.gaming.tvApps = lib.mkEnableOption "Jellyfin and YouTube TV launchers for gaming mode";

  config = lib.mkIf cfg.tvApps {
    home.packages = [
      pkgs.jellyfin-desktop
      youtube-tv
    ];

    xdg.desktopEntries.youtube-tv = {
      name = "YouTube TV";
      exec = "youtube-tv";
      icon = "youtube";
      categories = [ "AudioVideo" ];
    };
  };
}
