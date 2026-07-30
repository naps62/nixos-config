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

  # Route the Secret portal (org.freedesktop.portal.Secret) to gnome-keyring.
  # Hyprland's portal doesn't implement Secret, and the preferred backend list
  # (hyprland;gtk) has no Secret provider — so without this, the portal exposes
  # no Secret interface at all. Electron apps (e.g. Claude Desktop) fetch their
  # token-encryption key through this portal; when it's missing, os_crypt init
  # fails (prev_init_success:false) and they can't persist a login across boots.
  xdg.portal.config.common."org.freedesktop.impl.portal.Secret" = "gnome-keyring";

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
