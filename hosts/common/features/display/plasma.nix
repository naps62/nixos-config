{ pkgs, ... }:
# KDE Plasma 6 as a second desktop next to Hyprland: the "desktop mode" for
# gaming mode (gaming/gaming-mode.nix), the way SteamOS pairs the two. Picked in
# SDDM; Hyprland stays the default session.
{
  services.desktopManager.plasma6.enable = true;

  # DrKonqi's crash-handler needs a Qt display. Under gamescope (and right after
  # a Hyprland logout) there is none, so each launcher aborts, which is itself a
  # coredump that spawns the next launcher: 5000+ in a row, hanging the session.
  # Masking the socket makes switch-to-configuration fail when it restarts it,
  # so keep the socket and make the per-connection service a no-op instead.
  systemd.user.services."drkonqi-coredump-launcher@" = {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStart = [
      ""
      "${pkgs.coreutils}/bin/true"
    ];
  };

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
