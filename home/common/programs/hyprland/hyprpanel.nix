{
  inputs,
  pkgs,
  ...
}:

{
  # imports = [ inputs.hyprpanel.homeManagerModules.hyprpanel ];

  home.packages = with pkgs; [ upower ];

  # programs.hyprpanel = {
  #   # enable = true;
  #   overlay.enable = true;
  #   overwrite.enable = true;
  #
  #   settings = {
  #     theme.bar.transparent = true;
  #     theme.font = {
  #       name = "Fira Code Nerd Font";
  #       size = "14px";
  #     };
  #   };
  # };
}
