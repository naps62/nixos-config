{ config, pkgs, ... }:
{
  home.packages = [ pkgs.eww ];
  xdg.configFile = {
    "eww/eww.yuck".source = ./eww.yuck;
    "eww/eww.scss".source = ./eww.scss;
    "eww/scripts".source = ./scripts;
  };
}
