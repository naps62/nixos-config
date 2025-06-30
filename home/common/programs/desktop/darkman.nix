{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    dconf
  ];

  services.darkman = {
    enable = true;
    darkModeScripts = {
      gtk-theme = ''
        ${pkgs.dconf}/bin/dconf write \
        /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
        ${pkgs.dconf}/bin/dconf write \
        /org/gnome/desktop/interface/gtk-theme "'Orchis-Dark-Compact'"
      '';
    };
    lightModeScripts = {
      gtk-theme = ''
        ${pkgs.dconf}/bin/dconf write \
        /org/gnome/desktop/interface/color-scheme "'prefer-light'"
        ${pkgs.dconf}/bin/dconf write \
        /org/gnome/desktop/interface/gtk-theme "'Orchis-Compact'"
      '';
    };
  };

  xdg.configFile."darkman/config.yaml".text = ''
    usegeoclue: true
  '';
}
