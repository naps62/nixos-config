{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    gnome-shell
    gnome-control-center
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      text-scaling-factor = "1.5";
    };
  };
}
