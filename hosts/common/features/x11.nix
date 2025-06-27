{ inputs, pkgs, ... }:
let hyprland-session = pkgs.makeDesktopItem {
  name = "Hyprland";
  comment = "Hyprland (custom desktop file)";
  desktopNames = "Hyprland";
  exec = "Hyprland";
  type = "Application";
};
{

  services.xserver.enable = true;
  services.xserver.displayManager.startx.enable = true;
  # services.xserver.displayManager.sessionPackages = [ hyprland-session ];

  # services.xserver.windowManager.gnome.enable = true;
  # services.xserver.windowManager.gnome.wayland = false;
  # hardware.opengl.enable = true;
  #
  # environment.systemPackages = with pkgs; [
  #   xorg.xhost
  #   xorg.xrandr
  #   xorg.xinit
  #   gnome-session
  #   gnome-shell
  # ];
  #
  # xdg = {
  #   portal = {
  #     enable = true;
  #   };
  # };

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
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
