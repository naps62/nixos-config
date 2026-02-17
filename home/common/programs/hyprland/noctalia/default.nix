{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  avatar = pkgs.fetchurl {
    url = "https://github.com/naps62.png";
    sha256 = "1ck11xg4rwcvn8dcc06ax7i9yfzy21v1n6h5mcjrkrici5sznlsv";
  };
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;
  };

  home.file.".face".source = avatar;

  # symlink directly to the repo file so we can edit it through the GUI
  xdg.configFile."noctalia/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "/home/naps62/projects/nixos-config/home/common/programs/hyprland/noctalia/settings.json";

  # force overwrite files that noctalia may have turned into regular files
  xdg.configFile."hypr/hyprland.conf".force = true;
  xdg.configFile."gtk-3.0/gtk.css".force = true;

  # source noctalia-generated color theme in hyprland
  wayland.windowManager.hyprland.settings.source = [
    "~/.config/hypr/noctalia/noctalia-colors.conf"
  ];
}
