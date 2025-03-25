{ pkgs, ... }:
{
  imports = [
    ./firefox.nix
    ./darkman.nix
  ];

  home.packages = with pkgs; [
    # various
    google-chrome
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
    zathura
    nwg-look
    xournalpp
    jq
    kooha
    ffmpeg
    unzip

    # networking
    networkmanagerapplet
    mtr
    dnsutils

    # communication
    slack
    zoom-us
    ferdium
    signal-desktop

    # dev tools
    ferdium
    bruno
    bun

    # themes
    tela-icon-theme
    papirus-icon-theme
  ];

  gtk = {
    enable = true;
    theme = {
      name = "Orchis-Dark-Compact";
      package = pkgs.orchis-theme;
    };
    iconTheme = {
      name = "Tela black";
      package = pkgs.tela-icon-theme;
    };
  };
}
