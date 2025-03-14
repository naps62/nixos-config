{ inputs, pkgs, ... }:
{
  services.xserver.enable = true;
  services.xserver.windowManager.gnome.enable = true;
  hardware.opengl.enable = true;
}
