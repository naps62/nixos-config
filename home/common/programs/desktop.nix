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
    ferdium

    # dev tools
    ferdium
    bruno
    bun
  ];

  gtk = {
    enable = true;
    theme = {
      name = "Orchis";
      package = pkgs.orchis-theme;
    };
    iconTheme = {
      name = "tela";
      package = pkgs.tela-icon-theme;
    };
  };
}
