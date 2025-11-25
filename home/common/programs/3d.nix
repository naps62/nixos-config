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

  xdg.desktopEntries.prusaslicer-url-handler = {
    name = "PrusaSlicer Protocol Handler";
    exec = "prusa-slicer %u";
    type = "Application";
    noDisplay = true;
    mimeType = [ "x-scheme-handler/prusaslicer" ];
  };
}
