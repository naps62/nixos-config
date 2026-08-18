{ pkgs, ... }:
{
  # Clipboard (and file) sync between hosts over the LAN. Moonlight/Sunshine
  # carry no clipboard channel at all, so this is the only path between the
  # streaming client and its host.
  programs.kdeconnect = {
    enable = true;
    package = pkgs.kdePackages.kdeconnect-kde;
  };
}
