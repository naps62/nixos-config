{
  lib,
  inputs,
  pkgs,
  config,
  ...
}:
let
  wallpaper1 = pkgs.fetchurl {
    url = "https://images.hdqwalls.com/download/black-red-square-rectangle-rq-3840x2160.jpg";
    hash = "sha256-ZWJKHHye6Ukjd+v4bwmidJim4z+6woM8e7n3bExf6kc=";
  };
  wallpaper2 = pkgs.fetchurl {
    url = "https://images.hdqwalls.com/download/metals-shapes-abstract-8k-8c-3840x2160.jpg";
    hash = "sha256-EYG89NfMjylnNXNFtmEYYjEFq/j22ORvnw/OTcY0BVs=";
  };
  wallpaper-vertical = pkgs.fetchurl {
    url = "https://images.hdqwalls.com/download/horizon-zero-dawn-abstract-m2-2160x3840.jpg";
    hash = "sha256-zwMnHigZhqeDSrtpyxC0hpn8p9Z7bI8tXx/uNxhSa60=";
  };
in
{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      # List HDMI-A-1 first so it becomes the primary monitor (ID 0)
      "HDMI-A-1, 3840x2160, 0x2160,   1"
      # Then the other monitors
      "DP-2,     3840x2160, 3840x180,   1,   transform, 1"
      "DP-1,     3840x2160, 0x0,      1"
    ];
    workspace = [
      "1, monitor:HDMI-A-1, default:true, persistent:true"  # bottom-left (primary)
      "2, monitor:DP-2, persistent:true"       # right (vertical)
      "3, monitor:DP-1, persistent:true"       # top-left
      "4, monitor:HDMI-A-1"  # bottom-left
      "5, monitor:DP-2"       # right (vertical)
      "6, monitor:DP-1"       # top-left
    ];
  };

  services.hyprpaper.settings.preload = [
    (builtins.toString wallpaper1)
    (builtins.toString wallpaper2)
    (builtins.toString wallpaper-vertical)
  ];
  services.hyprpaper.settings.wallpaper = [
    "HDMI-A-1,${builtins.toString wallpaper1}"
    "DP-1,${builtins.toString wallpaper2}"
    "DP-2,${builtins.toString wallpaper-vertical}"
  ];
}
