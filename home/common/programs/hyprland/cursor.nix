{ pkgs, config, ... }:
let
  cfg = config.custom.hyprland;
  nordzy-cursors = pkgs.callPackage ../../../../pkgs/nordzy-cursors/package.nix { };
  cursorPackage = if cfg.cursorPackage != null then cfg.cursorPackage else nordzy-cursors;
  cursorSize = cfg.cursorSize;
in
{
  home.packages = [
    cursorPackage
  ];

  home.sessionVariables = {
    HYPRCURSOR_THEME = cfg.cursorTheme.dark;
    HYPRCURSOR_SIZE = cursorSize;
    XCURSOR_THEME = cfg.cursorTheme.dark;
    XCURSOR_SIZE = cursorSize;
  };

  dconf.enable = true;
}
