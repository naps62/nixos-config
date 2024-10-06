{ config, pkgs, ... }:
{
  programs.eww = {
    enable = true;
    enableZshIntegration = true;
    configDir = ./config;
  };

  # xdg.configFile = {
  #   "eww/eww.yuck".source = ./eww.yuck;
  #   "eww/eww.scss".source = ./eww.scss;
  #   "eww/scripts".source = ./scripts;
  # };
}
