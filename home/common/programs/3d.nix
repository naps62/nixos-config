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
  ];
}
