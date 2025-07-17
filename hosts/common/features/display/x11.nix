{ inputs, pkgs, ... }:
{

  services = {
    desktopManager = {
      gnome.enable = true;
    };
    xserver = {
      windowManager.i3.enable = true;
      xkbOptions = "ctrl:nocaps";
    };
    sysprof.enable = true;
    gnome = {
      glib-networking.enable = true;
      gnome-keyring.enable = true;
      gnome-online-accounts.enable = true;
    };
  };

  programs = {
    i3lock.enable = true;
    dconf.enable = true;
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
