{ pkgs, ... }:
# KDE Plasma 6 as a second desktop next to Hyprland: the "desktop mode" for
# gaming mode (gaming/gaming-mode.nix), the way SteamOS pairs the two. Picked in
# SDDM; Hyprland stays the default session.
{
  services.desktopManager.plasma6.enable = true;

  # Plasma's own apps that duplicate what the Hyprland setup already has, or
  # that a TV box has no use for.
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    kate
    khelpcenter
    konsole
    krdp
    okular
  ];
}
