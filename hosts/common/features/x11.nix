{ inputs, pkgs, ... }:
{
  services.xserver = {
    enable = true;
    displayManager = {
      defaultSession = "none+i3";
    };
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
