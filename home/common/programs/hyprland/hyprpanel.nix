{
  inputs,
  config,
  pkgs,
  ...
}:

{
  imports = [ inputs.hyprpanel.homeManagerModules.hyprpanel ];

  programs.hyprpanel = {
    enable = true;

    systemd.enable = true;
    overwrite.enable = true;

    settings = {
      theme.bar.transparent = true;
      theme.font = {
        name = "Fira Code Nerd Font";
        size = "14px";
      };
    };
  };
}
