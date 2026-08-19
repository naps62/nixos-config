{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./darkman.nix
    ./spicetify.nix
  ];

  home = {
    packages = with pkgs; [
      # various
      google-chrome
      thunar
      obsidian
      mpv
      # screen recording — evaluating these
      obs-studio
      kooha # simple Wayland-native screen+audio recorder
      vokoscreen-ng # GUI recorder with webcam overlay
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
      ffmpeg
      unzip

      # remote desktop
      remmina

      # networking
      networkmanagerapplet
      mtr
      dnsutils

      # communication
      slack
      ferdium
      signal-desktop
      zoom-us

      # dev tools
      yaak
      bun

      # themes
      tela-icon-theme
    ];

    pointerCursor = {
      # setting the block alone no longer implies generation; must be explicit
      enable = true;
      package = pkgs.numix-cursor-theme;
      name = "Numix-Cursor-Light";
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Orchis-Dark-Compact";
      package = pkgs.orchis-theme;
    };
    # Keep applying the gtk3 theme to gtk4 too (new default is null).
    gtk4.theme = config.gtk.theme;
    iconTheme = {
      name = "Tela black";
      package = pkgs.tela-icon-theme;
    };
    cursorTheme = {
      name = "Numix-Cursor-Light";
      package = pkgs.numix-cursor-theme;
    };
  };

  xdg.configFile = {
    "zathura/zathurarc".text = ''
      set default-bg "#2e3440"
      set default-fg "#eceff4"
      set statusbar-bg "#3b4252"
      set statusbar-fg "#eceff4"
      set inputbar-bg "#3b4252"
      set inputbar-fg "#eceff4"
      set highlight-color "#ebcb8b"
      set highlight-active-color "#88c0d0"
      set recolor-lightcolor "#2e3440"
      set recolor-darkcolor "#eceff4"
    '';

    # qt: dark color scheme shipped by qt5ct/qt6ct themselves. Applied via
    # QT_QPA_PLATFORMTHEME=qt6ct, set in the Hyprland env block (and imported
    # into the dbus activation environment so the xdph screen-share picker
    # inherits it too). custom_palette=true is required for qt5ct/qt6ct to
    # actually apply the color scheme; Fusion is used because it fully honors a
    # custom palette (Breeze/native styles partly ignore it).
    "qt5ct/qt5ct.conf".text = ''
      [Appearance]
      style=Fusion
      custom_palette=true
      color_scheme_path=${pkgs.libsForQt5.qt5ct}/share/qt5ct/colors/darker.conf
    '';
    "qt6ct/qt6ct.conf".text = ''
      [Appearance]
      style=Fusion
      custom_palette=true
      color_scheme_path=${pkgs.kdePackages.qt6ct}/share/qt6ct/colors/darker.conf
    '';
  };
}
