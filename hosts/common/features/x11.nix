{ inputs, pkgs, ... }:
{
  services.displayManager = {
    defaultSession = "none+i3";
  };
  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };
    windowManager.i3.enable = true;

    xkb = {
      layout = "us";
      variant = "";
    };
  };

  xdg = {
    portal = {
      enable = true;
    };
  };
}
