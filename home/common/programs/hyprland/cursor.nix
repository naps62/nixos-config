{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    rose-pine-cursor
    inputs.rose-pine-hyprcursor.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  home.sessionVariables = {
    HYPRCURSOR_THEME = "BreezeX-RosePine-Linux";
    HYPRCURSOR_SIZE = 32;
    XCURSOR_THEME = "BreezeX-RosePine-Linux";
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
