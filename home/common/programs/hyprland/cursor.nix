{ pkgs, inputs, ... }:
let
  nordzy-cursors = pkgs.callPackage ../../../../pkgs/nordzy-cursors/package.nix { };
in
{
  home.packages = [
    nordzy-cursors
  ];

  home.sessionVariables = {
    HYPRCURSOR_THEME = "Nordzy-cursors";  # Dark variant (default)
    HYPRCURSOR_SIZE = 32;
    XCURSOR_THEME = "Nordzy-cursors";
    XCURSOR_SIZE = 32;
  };

  dconf = {
    enable = true;
    # settings = {
    # "org/gnome/desktop/interface" = {
    #   cursor-theme = "BreezeX-RosePine-Linux";
    # };
    # };
  };
}
