{ pkgs, config, ... }:
let
  inherit (config.custom.hyprland) cursorTheme cursorSize;
in
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
        /org/gnome/desktop/interface/cursor-theme "'${cursorTheme.dark}'"

        # Set environment variables for current session
        export HYPRCURSOR_THEME="${cursorTheme.dark}"
        export XCURSOR_THEME="${cursorTheme.dark}"

        # Update Hyprland cursor theme
        ${pkgs.hyprland}/bin/hyprctl setcursor ${cursorTheme.dark} ${toString cursorSize}
      '';
      noctalia-theme = ''
        noctalia msg theme-mode-set dark
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
        /org/gnome/desktop/interface/cursor-theme "'${cursorTheme.light}'"

        # Set environment variables for current session
        export HYPRCURSOR_THEME="${cursorTheme.light}"
        export XCURSOR_THEME="${cursorTheme.light}"

        # Update Hyprland cursor theme
        ${pkgs.hyprland}/bin/hyprctl setcursor ${cursorTheme.light} ${toString cursorSize}
      '';
      noctalia-theme = ''
        noctalia msg theme-mode-set light
      '';
    };
  };

  xdg.configFile."darkman/config.yaml".text = ''
    lat: 41.55
    lng: -8.42
    dbusserver: true
  '';
}
