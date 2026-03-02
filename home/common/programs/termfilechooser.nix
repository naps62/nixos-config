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
      output="$1"
      chooser=$(mktemp)
      kitty -T termfilechooser yazi --chooser-file="$chooser"
      if [ -s "$chooser" ]; then
        cat "$chooser" > "$output"
      fi
      rm -f "$chooser"
    ''}
    default_dir=$HOME
  '';
}
