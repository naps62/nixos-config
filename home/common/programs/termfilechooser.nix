{ pkgs, ... }:
{
  xdg.configFile."xdg-desktop-portal/hyprland-portals.conf".text = ''
    [preferred]
    default=hyprland;gtk
    org.freedesktop.impl.portal.FileChooser=termfilechooser
  '';

  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd=${pkgs.writeShellScript "termfilechooser-yazi" ''
      exec kitty -T termfilechooser yazi "$@"
    ''}
    default_dir=$HOME
  '';
}
