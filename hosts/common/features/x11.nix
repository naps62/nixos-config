{ inputs, pkgs, ... }:
{

  services.xserver = {
    enable = true;
    desktopManager.gdm.enable = true;
    displayManager.gdm.enable = true;

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
