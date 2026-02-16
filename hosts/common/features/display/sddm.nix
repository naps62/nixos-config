{ inputs, pkgs, ... }:
let
  sddm-astronaut-theme = pkgs.callPackage ../../../../pkgs/sddm-astronaut-theme/package.nix { };
in
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
    package = pkgs.kdePackages.sddm;
  };

  environment.systemPackages = with pkgs; [
    sddm-astronaut-theme
    kdePackages.qt6ct
    kdePackages.qtsvg
    kdePackages.qtvirtualkeyboard
    kdePackages.qtmultimedia
  ];
}
