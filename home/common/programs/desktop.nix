{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # various
    google-chrome
    firefox-devedition
    spotify
    spicetify-cli
    xfce.thunar
    obsidian
    mpv
    obs-studio
    calibre
    gimp
    font-manager
    imv
    pavucontrol

    # communication
    slack
    zoom-us

    # dev tools
    ferdium
    bruno
    bun
  ];
}
