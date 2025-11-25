{
  lib,
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    blender
    openscad
    prusa-slicer
    google-fonts
  ];

  fonts.fontconfig.enable = true;
}
