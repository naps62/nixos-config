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
      # monitor, res,       position, scale, transform, rotation
      "HDMI-A-1, 3840x2160, 0x1620,   1.333333"
      "DP-1,     3840x2160, 0x0,      1.333333"
      # 300 instead of 0 is so that 'move left' actually focuses the bottom one instead of the top one
      # for some reason, that's the minimum value for which this works
      "DP-2,     3840x2160, 2880x180,   1.333333,   transform, 1"
    ];
    workspace = [
      "1, monitor=DP-2"
      "2, monitor=DP-1"
      "3, monitor=DP-2"
      "4, monitor=HDMI-A-1"
      "5, monitor=HDMI-A-1"
    ];
  };

  xsession.windowManager.i3 = {
    extraConfig = lib.mkAfter ''
      workspace 1 output HDMI-0
      workspace 2 output DP-2
      workspace 3 output DP-0

      for_window [class="^Ethui-test$"] workspace 2
      for_window [class="^Ethui-test$"] border normal 2, floating enable, resize set 1024 900, move position mouse

      for_window [class="^Ethui-dev$"] workspace 2
      for_window [class="^Ethui-dev$"] border normal 2, floating enable, resize set 1024 900, move position mouse
    '';
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
