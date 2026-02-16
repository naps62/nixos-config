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
      kitty-theme = ''
        # Switch all Kitty instances to dark theme
        ${pkgs.kitty}/bin/kitten themes --reload-in=all Catppuccin-Mocha
      '';
      claude-theme = ''
        # Switch Claude Code to dark theme
        CLAUDE_CONFIG=~/.claude.json
        if [ -f "$CLAUDE_CONFIG" ]; then
          ${pkgs.jq}/bin/jq '.theme = "dark"' "$CLAUDE_CONFIG" > "$CLAUDE_CONFIG.tmp" && mv "$CLAUDE_CONFIG.tmp" "$CLAUDE_CONFIG"
        fi
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
      kitty-theme = ''
        # Switch all Kitty instances to light theme
        ${pkgs.kitty}/bin/kitten themes --reload-in=all Catppuccin-Latte
      '';
      claude-theme = ''
        # Switch Claude Code to light theme
        CLAUDE_CONFIG=~/.claude.json
        if [ -f "$CLAUDE_CONFIG" ]; then
          ${pkgs.jq}/bin/jq '.theme = "light"' "$CLAUDE_CONFIG" > "$CLAUDE_CONFIG.tmp" && mv "$CLAUDE_CONFIG.tmp" "$CLAUDE_CONFIG"
        fi
      '';
    };
  };

  xdg.configFile."darkman/config.yaml".text = ''
    lat: 41.55
    lng: -8.42
    dbusserver: true
  '';
}
