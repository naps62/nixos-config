{ inputs, pkgs, ... }:
{

  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  environment.systemPackages = with pkgs; [
    xorg.xhost
    xorg.xrandr
    xorg.xinit
    gnome-session
    gnome-shell
  ];

  xdg = {
    portal = {
      enable = true;
    };
  };
}
