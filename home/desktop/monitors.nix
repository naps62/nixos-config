{
  inputs,
  pkgs,
  config,
  ...
}:
let
  wallpaper1 = pkgs.fetchurl {
    url = "https://4kwallpapers.com/images/wallpapers/abstract-design-3840x2160-17068.jpg";
    hash = "sha256-F/XE/ETwzYwtbQWXY78c2AJc8xe2mRunB8Q9/c2F7kY=";
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

  services.hyprpaper.settings.preload = [ (builtins.toString wallpaper1) ];
  services.hyprpaper.settings.wallpaper = [
    "DP-1,${builtins.toString wallpaper1}"
    "HDMI-A-1,${builtins.toString wallpaper1}"
  ];
}
