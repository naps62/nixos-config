{ ... }:
{
  # Removable media. udisks2 provides the D-Bus API plus the polkit rules that
  # let the logged-in user mount without root — which is what makes flashing a
  # keyboard possible, since there's no keyboard to type a sudo password with.
  services.udisks2.enable = true;
  # gvfs is what lets Thunar list and unmount the device.
  services.gvfs.enable = true;
}
