{ inputs, pkgs, ... }:
{
  services.xserver = {
    enable = true;
    displayManager = {
      defaultSession = "none+i3";
    };
    windowManager.i3.enable = true;

    layout = "us";
    xkbVariant = "";
  };

  xdg = {
    portal = {
      enable = true;
    };
  };
}
