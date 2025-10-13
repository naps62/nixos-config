{
  lib,
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    blender
    prusa-slicer
    flashprint
  ];
}
