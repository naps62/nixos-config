{ inputs, pkgs, ... }:
let
  hyprland-session = pkgs.makeDesktopItem {
    name = "Hyprland";
    comment = "Hyprland (custom desktop file)";
    desktopNames = "Hyprland";
    exec = "Hyprland";
    type = "Application";
  };
in
{

  services.xserver = {
    enable = true;
    displayManager = {
      startx.enable = true;
      gdm.enable = true;
    };
    autoRepeatDelay = 250;
    autoRepeatInterval = 30;
  };
  services.displayManager.sessionPackages = with pkgs; [
    hyprland
  ];

  services.desktopManager = {
    gnome.enable = true;
  };
  services.xserver.windowManager = {
    i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
      ];
    };
  };
  programs.i3lock.enable = true;

  programs.dconf.enable = true;
  services = {
    sysprof.enable = true;
    gnome = {
      evolution-data-server.enable = true;
      glib-networking.enable = true;
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
    };
  };
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
      gnome-console
      gnome-text-editor
      gedit
    ])
    ++ (with pkgs; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      epiphany # web browser
      geary # email reader
      evince # document viewer
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      gnome-contacts
      gnome-initial-setup
      gnome-shell-extensions
    ]);

}
