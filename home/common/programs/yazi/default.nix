{
  lib,
  pkgs,
  config,
  ...
}:
{

  programs.yazi.enable = true;

  home.packages = with pkgs; [ yaziPlugins.git ];

  xdg.configFile."yazi/yazi.toml".source = ./yazi.toml;
  xdg.configFile."yazi/init.lua".source = ./init.lua;
}
