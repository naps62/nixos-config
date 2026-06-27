{
  lib,
  inputs,
  pkgs,
  config,
  ...
}:
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
}
