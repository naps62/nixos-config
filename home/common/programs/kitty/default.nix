{ config, pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      cursor_trail = 1;
      copy_on_select = true;
      background_opacity = 0.9;

      enabled_layouts = "tall, grid, fat, splits, stack";

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
      # tab_title_template = "{tab.active_wd.split('/')[-1]}{' :{}'.format(num_windows) if num_windows > 1 else ''}";
      tab_bar_filter = "session:~ or session:^$";

      # keys
      kitty_mod = "alt";

      # remove control
      allow_remote_control = true;
      listen_on = "unix:/tmp/kitty.sock";

      enable_audio_bell = false;
      bell_on_tab = true;
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
      "kitty_mod+space" = "toggle_layout stack";

      "ctrl+shift+0x27" = "change_font_size all +2.0";
      "ctrl+shift+minus" = "change_font_size all -2.0";
      "ctrl+shift+backspace" = "change_font_size all 0";

      "kitty_mod+h" = "neighboring_window left";
      "kitty_mod+j" = "neighboring_window down";
      "kitty_mod+k" = "neighboring_window up";
      "kitty_mod+l" = "neighboring_window right";

      "f7>/" = "goto_session";
    };

    extraConfig = ''
      include themes/noctalia.conf
    '';
  };

  xdg.configFile."kitty/sessions".source = ./sessions;
}
