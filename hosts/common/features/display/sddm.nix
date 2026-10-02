{ lib, pkgs, ... }:
{
  services.xserver = {
    enable = true;
    displayManager = {
      startx.enable = true;
    };
    autoRepeatDelay = 250;
    autoRepeatInterval = 30;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sddm-astronaut-theme";
    package = lib.mkDefault pkgs.kdePackages.sddm; # plasma6 sets the same one
    extraPackages = with pkgs.kdePackages; [
      qtmultimedia
      qtsvg
      qtvirtualkeyboard
      qt5compat
    ];
  };

  environment.systemPackages = with pkgs; [
    sddm-astronaut
  ];
}
