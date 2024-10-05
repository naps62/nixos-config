{ pkgs, ... }: {
  home.packages = [
    # various
    pkgs.google-chrome
    pkgs.firefox-devedition
    pkgs.spotify
    pkgs.spicetify-cli
    pkgs.xfce.thunar
    pkgs.obsidian
    pkgs.mpv
    pkgs.obs-studio
    pkgs.calibre
    pkgs.gimp
    pkgs.font-manager

    # communication
    pkgs.slack
    pkgs.zoom-us

    # dev tools
    pkgs.ferdium
    pkgs.bruno
    pkgs.bun

  ];

  imports = [ ./rofi.nix ];
}
