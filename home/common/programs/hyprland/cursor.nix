{ pkgs, config, inputs, ... }:
let
  nordzy-cursors = pkgs.callPackage ../../../../pkgs/nordzy-cursors/package.nix { };
  cursorSize = config.custom.hyprland.cursorSize;
in
{
  home.packages = [
    nordzy-cursors
  ];

  home.sessionVariables = {
    HYPRCURSOR_THEME = "Nordzy-cursors";  # Dark variant (default)
    HYPRCURSOR_SIZE = cursorSize;
    XCURSOR_THEME = "Nordzy-cursors";
    XCURSOR_SIZE = cursorSize;
  };

  dconf.enable = true;
}
