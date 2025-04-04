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
      "eDP-1, preferred, 0x0, 1, bitdepth, 8"
      "DP-3, preferred, 0x-2160, 1.2"
      # "DP-3, 1920x1200, 0x0, 1, mirror, eDP-1"
    ];
  };

  services.hyprpaper.settings.preload = [ (builtins.toString wallpaper1) ];
  services.hyprpaper.settings.wallpaper = [
    "eDP-1,${builtins.toString wallpaper1}"
    "DP-3,${builtins.toString wallpaper1}"
  ];
}
