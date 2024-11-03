{ pkgs, ... }:
{
  home.packages = with pkgs; [
    rofi-wayland
    (callPackage ../../../../pkgs/rofi-launchers/package.nix { })
  ];
}
