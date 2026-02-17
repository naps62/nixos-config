{ config, lib, pkgs, ... }:
{
  imports = [
    ./darkman.nix
    ./spicetify.nix
  ];

  home.packages = with pkgs; [
    # various
    google-chrome
    thunar
    obsidian
    mpv
    obs-studio
    calibre
    gimp
    font-manager
    imv
    pavucontrol
    zathura
    libsForQt5.qt5ct
    kdePackages.qt6ct
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
    yaak
    bun

    # themes
    tela-icon-theme
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
    cursorTheme = {
      name = "Numix-Cursor-Light";
      package = pkgs.numix-cursor-theme;
    };
  };

  home.pointerCursor = {
    package = pkgs.numix-cursor-theme;
    name = "Numix-Cursor-Light";
  };

  # zathura: include noctalia-generated theme
  xdg.configFile."zathura/zathurarc".text = ''
    include noctaliarc
  '';

  # gtk: include noctalia-generated css (mkForce to override gtk module)
  xdg.configFile."gtk-3.0/gtk.css".text = lib.mkForce ''
    @import url("noctalia.css");
  '';
  xdg.configFile."gtk-4.0/gtk.css".text = lib.mkForce ''
    @import url("noctalia.css");
  '';

  # qt: use noctalia color scheme
  xdg.configFile."qt5ct/qt5ct.conf".text = ''
    [Appearance]
    color_scheme_path=${config.home.homeDirectory}/.config/qt5ct/colors/noctalia.conf
  '';
  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    color_scheme_path=${config.home.homeDirectory}/.config/qt6ct/colors/noctalia.conf
  '';
}
