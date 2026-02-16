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
      cursor-theme = ''
        ${pkgs.dconf}/bin/dconf write \
        /org/gnome/desktop/interface/cursor-theme "'Nordzy-cursors'"

        # Set environment variables for current session
        export HYPRCURSOR_THEME="Nordzy-cursors"
        export XCURSOR_THEME="Nordzy-cursors"

        # Update Hyprland cursor theme
        ${pkgs.hyprland}/bin/hyprctl setcursor Nordzy-cursors 42
      '';
    };
    lightModeScripts = {
      gtk-theme = ''
        ${pkgs.dconf}/bin/dconf write \
        /org/gnome/desktop/interface/color-scheme "'prefer-light'"
        ${pkgs.dconf}/bin/dconf write \
        /org/gnome/desktop/interface/gtk-theme "'Orchis-Compact'"
      '';
      cursor-theme = ''
        ${pkgs.dconf}/bin/dconf write \
        /org/gnome/desktop/interface/cursor-theme "'Nordzy-white'"

        # Set environment variables for current session
        export HYPRCURSOR_THEME="Nordzy-white"
        export XCURSOR_THEME="Nordzy-white"

        # Update Hyprland cursor theme
        ${pkgs.hyprland}/bin/hyprctl setcursor Nordzy-white 42
      '';
    };
  };

  xdg.configFile."darkman/config.yaml".text = ''
    lat: 41.55
    lng: -8.42
    dbusserver: true
  '';
}
