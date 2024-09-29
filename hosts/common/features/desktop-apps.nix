{ inputs, pkgs, ... }: {
  environment.systemPackages = [
    # various
    pkgs.google-chrome
    pkgs.firefox-devedition
    pkgs.spotify
    pkgs.spicetify-cli
    pkgs.xfce.thunar
    pkgs.obsidian
    pkgs.mpv
    pkgs.obs-studio

    # communication
    pkgs.slack
    pkgs.zoom-us

    # dev tools
    pkgs.ferdium
    pkgs.bruno
    pkgs.kitty
  ];

}
