{ inputs, pkgs, ... }:
let
  sddm-noctalia-theme = pkgs.callPackage ../../../../pkgs/sddm-noctalia-theme/package.nix { };
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
    theme = "sddm-noctalia";
    package = pkgs.kdePackages.sddm;
    extraPackages = with pkgs.kdePackages; [
      qtmultimedia
      qtsvg
      qtvirtualkeyboard
      qt5compat
    ];
  };

  environment.systemPackages = with pkgs; [
    sddm-noctalia-theme
  ];
}
