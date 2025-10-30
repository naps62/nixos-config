{ config, pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;
      cursor_trail = 1;
      copy_on_select = true;
      background_opacity = 0.9;

      enabled_layouts = "tall, grid, fat, splits";

      # font
      font_family = "FiraCode Nerd Font Mono";
      bold_font = "FiraCode Nerd Font Mono Bold";
      italic_font = "VictorMono Nerd Font Mono Oblique";
      bold_italic_font = "VictorMono Nerd Font Mono Bold Oblique";
      disable_ligatures = "cursor";

      # tab-style
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_title_template = "{title}{' :{}'.format(num_windows) if num_windows > 1 else ''}";

      # keys
      kitty_mod = "alt";
    };

    keybindings = {
      "kitty_mod+t" = "new_tab_with_cwd";
      "kitty_mod+enter" = "new_window_with_cwd";
      "kitty_mod+r" = "set_tab_title";

      "kitty_mod+u" = "previous_tab";
      "kitty_mod+i" = "next_tab";

      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";

      "ctrl+shift+l" = "next_layout";
      "ctrl+shift+left" = "resize_window narrower";
      "ctrl+shift+right" = "resize_window right";

      "ctrl+shift+0x27" = "change_font_size all +2.0";
      "ctrl+shift+minus" = "change_font_size all -2.0";
      "ctrl+shift+backspace" = "change_font_size all 0";

      "kitty_mod+h" = "neighboring_window left";
      "kitty_mod+j" = "neighboring_window down";
      "kitty_mod+k" = "neighboring_window up";
      "kitty_mod+l" = "neighboring_window right";
    };

    extraConfig = ''
      background #1c1c1c
      foreground #ddeedd
      cursor #e2bbef
      selection_background #4d4d4d
      color0 #3d352a
      color8 #554444
      color1 #cd5c5c
      color9 #cc5533
      color2 #86af80
      color10 #88aa22
      color3 #e8ae5b
      color11 #ffa75d
      color4 #6495ed
      color12 #87ceeb
      color5 #deb887
      color13 #996600
      color6 #b0c4de
      color14 #b0c4de
      color7 #bbaa99
      color15 #ddccbb
      selection_foreground #1c1c1c
    '';
  };
}
