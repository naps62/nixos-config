{
  lib,
  pkgs,
  config,
  ...
}:
{

  home.packages = with pkgs; [
    yazi
  ];

  xdg.configFile."yazi/yazi.yaml".source = ./yazi.yaml;
}
