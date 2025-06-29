{ inputs, pkgs, ... }:
{
  services.xserver = {
    enable = true;
    displayManager = {
      startx.enable = true;
      gdm.enable = true;
    };
    autoRepeatDelay = 250;
    autoRepeatInterval = 30;
  };
}
