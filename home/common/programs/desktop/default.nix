{
  config,
  lib,
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

      # dev tools
      yaak
      bun

      # themes
      tela-icon-theme
    ];

    pointerCursor = {
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
    # zathura: include noctalia-generated theme
    "zathura/zathurarc".text = ''
      include noctaliarc
    '';

    # gtk: include noctalia-generated css (mkForce to override gtk module)
    "gtk-3.0/gtk.css".text = lib.mkForce ''
      @import url("noctalia.css");
    '';
    "gtk-4.0/gtk.css".text = lib.mkForce ''
      @import url("noctalia.css");
    '';

    # qt: use noctalia color scheme. Applied via QT_QPA_PLATFORMTHEME=qt6ct,
    # set in the Hyprland env block (and imported into the dbus activation
    # environment so the xdph screen-share picker inherits it too).
    # custom_palette=true is required for qt5ct/qt6ct to actually apply the
    # color scheme; Fusion is used because it fully honors a custom palette
    # (Breeze/native styles partly ignore it).
    "qt5ct/qt5ct.conf".text = ''
      [Appearance]
      style=Fusion
      custom_palette=true
      color_scheme_path=${config.home.homeDirectory}/.config/qt5ct/colors/noctalia.conf
    '';
    "qt6ct/qt6ct.conf".text = ''
      [Appearance]
      style=Fusion
      custom_palette=true
      color_scheme_path=${config.home.homeDirectory}/.config/qt6ct/colors/noctalia.conf
    '';
  };
}
