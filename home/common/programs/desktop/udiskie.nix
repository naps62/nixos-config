{ ... }:
{
  # Mounts removable media on insert. Needed on top of host-side udisks2:
  # udisks2 only exposes the API, and Thunar is installed as a bare package
  # here (no thunar-volman), so nothing would otherwise mount anything.
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    # No systray dependency — unmount from Thunar or `udisksctl unmount`.
    tray = "never";
  };
}
