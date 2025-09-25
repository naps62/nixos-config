{
  inputs,
  pkgs,
  ...
}:

{
  home.packages = with pkgs; [ upower ];

  programs.hyprpanel = {
    enable = true;
    settings = {
      bar.layouts = {
        "0" = {
          left = [
            "dashboard"
            "workspaces"
          ];
          middle = [ "media" ];
          right = [
            "volume"
            "network"
            "bluetooth"
            "systray"
            "clock"
            "notifications"
          ];
        };
        "*" = {
          left = [ ];
          middle = [ ];
          right = [ ];
        };
      };
      theme.bar.transparent = true;
      theme.font.size = "18px";

      menus = {
        dashboard = {
          directories.enable = false;
          stats.enable_gpu = true;
        };
      };
    };
  };
}
