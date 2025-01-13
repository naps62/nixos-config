{
  inputs,
  ...
}:

{
  imports = [ inputs.hyprpanel.homeManagerModules.hyprpanel ];

  programs.hyprpanel = {
    enable = true;
    overlay.enable = true;
    systemd.enable = true;
    overwrite.enable = true;

    layout = {
      "bar.layouts" = {
        "1" = {
          "left" = [
            "dashboard"
            "workspaces"
            "windowtitle"
          ];
          "middle" = [ "media" ];
          "right" = [
            "volume"
            "network"
            "bluetooth"
            "systray"
            "clock"
            "notifications"
          ];
        };
        "0" = {
          "left" = [ ];
          "middle" = [ ];
          "right" = [ ];
        };
        "2" = {
          "left" = [ ];
          "middle" = [ ];
          "right" = [ ];
        };
      };
    };

    settings = {
      theme.bar.transparent = true;
      theme.font = {
        name = "Fira Code Nerd Font";
        size = "14px";
      };
    };
  };
}
