{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    # desktop apps
    pkgs.google-chrome
    pkgs.firefox-devedition
    pkgs.spotify
    pkgs.spicetify-cli
    pkgs.xfce.thunar
    pkgs.obsidian
    pkgs.mpv

    # communication
    pkgs.slack

    # dev tools
    pkgs.ferdium
    pkgs.bruno
  ];
}
