{ inputs, pkgs, ... }:
{
  services.xserver = {
    enable = true;
    displayManager = {
      startx.enable = true;
    };
    autoRepeatDelay = 250;
    autoRepeatInterval = 30;
  };
  services.displayManager.gdm.enable = true;
}
