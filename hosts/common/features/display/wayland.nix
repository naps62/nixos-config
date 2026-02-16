{ inputs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wl-clipboard
  ];

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  # GTK/GNOME services still useful on Wayland
  programs.dconf.enable = true;

  services = {
    # thumbnail support for images
    tumbler.enable = true;

    gnome = {
      glib-networking.enable = true;
      gnome-keyring.enable = true;
    };
  };

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
}
