{ config, pkgs, ... }:
let
  clip2path = pkgs.writeShellScript "clip2path" ''
    set -e

    if [ -n "$WAYLAND_DISPLAY" ]; then
      types=$(wl-paste --list-types)
      if grep -q '^image/' <<<"$types"; then
        ext=$(grep -m1 '^image/' <<<"$types" | cut -d/ -f2 | cut -d';' -f1)
        file="/tmp/clip_$(date +%s).''${ext}"
        wl-paste > "$file"
        printf '%q' "$file" | kitty @ send-text --stdin
      else
        wl-paste --no-newline | kitty @ send-text --stdin
      fi
    elif [ -n "$DISPLAY" ]; then
      types=$(xclip -selection clipboard -t TARGETS -o)
      if grep -q '^image/' <<<"$types"; then
        ext=$(grep -m1 '^image/' <<<"$types" | cut -d/ -f2 | cut -d';' -f1)
        file="/tmp/clip_$(date +%s).''${ext}"
        xclip -selection clipboard -t "image/''${ext}" -o > "$file"
        printf '%q' "$file" | kitty @ send-text --stdin
      else
        xclip -selection clipboard -o | kitty @ send-text --stdin
      fi
    fi
  '';

  scrollbackPager = pkgs.writeShellScript "kitty-scrollback" ''
    f=$(mktemp)
    cat | perl -0777 -pe 's/\x1b(?:\[[\x30-\x3f]*[\x20-\x2f]*[\x40-\x7e]|\][^\x07\x1b]*(?:\x07|\x1b\\)|.)//g; s/\s+\z/\n/' > "$f"
    nvim + -c "set ft=sh noma" "$f"
    rm "$f"
  '';
in
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

      scrollback_pager = "${scrollbackPager}";

      enable_audio_bell = false;
      bell_on_tab = true;
    };

    keybindings = {
      "kitty_mod+t" = "new_tab_with_cwd";
      "kitty_mod+enter" = "new_window_with_cwd";
      "kitty_mod+v" = "combine : goto_layout splits : launch --cwd=current --location=vsplit";
      "kitty_mod+s" = "combine : goto_layout splits : launch --cwd=current --location=hsplit";
      "kitty_mod+r" = "set_tab_title";

      "kitty_mod+u" = "previous_tab";
      "kitty_mod+i" = "next_tab";

      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+v" = "launch --type=background --allow-remote-control --keep-focus ${clip2path}";

      "ctrl+shift+l" = "next_layout";
      "ctrl+shift+left" = "resize_window narrower";
      "ctrl+shift+right" = "resize_window right";
      "kitty_mod+space" = "toggle_layout stack";

      "ctrl+shift+0x27" = "change_font_size all +2.0";
      "ctrl+shift+minus" = "change_font_size all -2.0";
      "ctrl+shift+backspace" = "change_font_size all 0";

      "kitty_mod+h" = "neighboring_window left";
      "kitty_mod+shift+h" = "show_scrollback";
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
