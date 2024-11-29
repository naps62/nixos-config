{
  inputs,
  pkgs,
  config,
}:
let
  wallpaper1 = pkgs.fetchurl {
    url = "https://i.redd.it/mvev8aelh7zc1.png";
    hash = "sha256-lJjIq+3140a5OkNy/FAEOCoCcvQqOi73GWJGwR2zT9w";
  };
in
{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "DP-1, preferred, 0x0, auto, bitdepth, 8"
      "HDMI-A-1, preferred, 2560x0, auto, bitdepth, 8"
    ];
    workspace = [
      "1, monitor=HDMI-A-1"
      "2, monitor=DP-1"
      "3, monitor=DP-1"
      "4, monitor=DP-1"
    ];
  };

  services.hyprpaper.settings.wallpapers = [
    "DP-1, ${builtins.toString wallpaper1}"
    "HDMI-A-1, ${builtins.toString wallpaper1}"
  ];
}
