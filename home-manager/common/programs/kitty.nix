{ config, pkgs, ... }: {
  programs.kitty = {
    enable = true;
    settings = {
      confirm_os_window_close = 0;
      enable_audio_bell = false;

      enabled_layouts = "tall, grid, fat, splits";

      # font
      font_family = "FiraCode Nerd Font Regular";
      bold_font = "FiraCode Nerd Font Bold";
      italic_font = "VictorMono Nerd Font Mono Oblique";
      bold_italic_font = "VictorMono Nerd Font Mono Bold Oblique";
      disable_ligatures = "cursor";

      # keys
    };

    keybindings = {
      "kitty_mod+t" = "new_tab_with_cmd";
      "kitty_mod+enter" = "new_window_with_cwd";
      "kitty_mod+r" = "set_tab_title";

      "kitty_mod+u" = "previous_tab";
      "kitty_mod+i" = "next_tab";

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
  };
}
