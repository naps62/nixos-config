{ inputs, pkgs, fonts, ... }: {
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

  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      ubuntu_font_family
      libertine
      fira-code
      fira-code-symbols
      (nerdfonts.override { fonts = [ "FiraCode" "VictorMono" ]; })
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Libertine" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "FiraCode" ];
      };
    };
  };

}
