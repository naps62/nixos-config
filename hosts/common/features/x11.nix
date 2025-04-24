{ inputs, pkgs, ... }:
{
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    layout = "us";
    xkbVariant = "";
  };

  xdg = {
    portal = {
      enable = true;
    };
  };
}
