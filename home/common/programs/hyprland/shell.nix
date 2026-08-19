{ pkgs, ... }:
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        terminal = "${pkgs.kitty}/bin/kitty";
        layer = "overlay";
        font = "FiraCode Nerd Font:size=12";
        icon-theme = "Tela black";
        lines = 12;
        width = 40;
        inner-pad = 8;
      };
      border = {
        radius = 12;
        width = 1;
      };
      colors = {
        background = "2e3440f0";
        text = "eceff4ff";
        match = "88c0d0ff";
        selection = "434c5eff";
        selection-text = "eceff4ff";
        border = "4c566aff";
      };
    };
  };

  services.mako = {
    enable = true;
    settings = {
      font = "FiraCode Nerd Font 11";
      background-color = "#2e3440f0";
      text-color = "#eceff4";
      border-color = "#4c566a";
      border-radius = 12;
      border-size = 1;
      padding = "14";
      margin = "12";
      default-timeout = 6000;
      anchor = "top-right";
      layer = "overlay";
    };
  };

  services.hyprpolkitagent.enable = true;
}
