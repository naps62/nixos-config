{ pkgs, ... }:
let
  clip2path = pkgs.writeShellScript "clip2path" ''
    set -euo pipefail

    jq=${pkgs.jq}/bin/jq
    scp=${pkgs.openssh}/bin/scp
    wlpaste=${pkgs.wl-clipboard}/bin/wl-paste
    xclip=${pkgs.xclip}/bin/xclip
    find=${pkgs.findutils}/bin/find

    # kitty/kitten stay unpinned: remote control has to reach the running
    # instance, whose build may differ from pkgs.kitty.

    "$find" /tmp -maxdepth 1 -name 'clip_*' -mtime +1 -delete 2>/dev/null || true

    # Some apps advertise a lossy format before image/png.
    pick_type() {
      if grep -qx 'image/png' <<<"$1"; then
        echo image/png
      else
        grep -m1 '^image/' <<<"$1" | cut -d';' -f1
      fi
    }

    ext_of() {
      local e=''${1#image/}
      e=''${e%%+*}
      e=''${e#x-}
      tr -cd 'a-zA-Z0-9' <<<"$e"
    }

    # Destination of the ssh client running in the focused window, empty if
    # that window is local. Prefers the real ssh process over the `kitten ssh`
    # wrapper, whose own long options would confuse the parser below.
    ssh_dest() {
      local -a argv
      mapfile -t argv < <(kitty @ ls | "$jq" -r '
        [ .[] | select(.is_focused)
          | .tabs[] | select(.is_focused)
          | .windows[] | select(.is_focused)
          | .foreground_processes[]?
          | { b: ((.cmdline[0] // "") | split("/") | last), c: .cmdline }
        ] as $p
        | ( [ $p[] | select(.b == "ssh") ] + [ $p[] | select(.b == "kitten") ] )
        | (.[0].c // [])[]')

      [ ''${#argv[@]} -gt 0 ] || return 0
      if [ "''${argv[0]##*/}" = kitten ]; then
        [ "''${argv[1]:-}" = ssh ] || return 0
        argv=("''${argv[@]:2}")
      else
        argv=("''${argv[@]:1}")
      fi

      local valueflags=bcDEeFIiJLlmOopQRSWw a
      while [ ''${#argv[@]} -gt 0 ]; do
        a=''${argv[0]}
        case "$a" in
          --) echo "''${argv[1]:-}"; return 0 ;;
          -?)
            case "$valueflags" in *"''${a#-}"*) argv=("''${argv[@]:1}") ;; esac
            argv=("''${argv[@]:1}")
            ;;
          -*) argv=("''${argv[@]:1}") ;;
          *) echo "$a"; return 0 ;;
        esac
      done
    }

    send_path() {
      local file=$1 dest remote
      dest=$(ssh_dest)
      if [ -n "$dest" ]; then
        remote=/tmp/''${file##*/}
        if ! "$scp" -q -o BatchMode=yes -o ConnectTimeout=5 "$file" "$dest:$remote"; then
          kitten notify --app-name clip2path clip2path "copy to $dest failed, nothing pasted"
          return 1
        fi
        file=$remote
      fi
      printf '%q' "$file" | kitty @ send-text --stdin
    }

    # Text goes through the real paste action. send-text has no bracketed
    # paste, so multi-line text would run line by line in a shell.
    if [ -n "''${WAYLAND_DISPLAY:-}" ]; then
      types=$("$wlpaste" --list-types)
      if grep -q '^image/' <<<"$types"; then
        type=$(pick_type "$types")
        file=$(mktemp --suffix=".$(ext_of "$type")" /tmp/clip_XXXXXXXX)
        "$wlpaste" --type "$type" > "$file"
        send_path "$file"
      else
        kitty @ action paste_from_clipboard
      fi
    elif [ -n "''${DISPLAY:-}" ]; then
      types=$("$xclip" -selection clipboard -t TARGETS -o)
      if grep -q '^image/' <<<"$types"; then
        type=$(pick_type "$types")
        file=$(mktemp --suffix=".$(ext_of "$type")" /tmp/clip_XXXXXXXX)
        "$xclip" -selection clipboard -t "$type" -o > "$file"
        send_path "$file"
      else
        kitty @ action paste_from_clipboard
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
    # Fixed theme — noctalia no longer toggles kitty with dark/light mode.
    themeFile = "Catppuccin-Mocha";
    settings = {
      confirm_os_window_close = 0;
      cursor_trail = 1;
      copy_on_select = true;

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
      # --cwd=current: locally keeps the dir; over `kitten ssh` it clones the
      # SSH connection into the new split (the "mirroring").
      "kitty_mod+v" = "combine : goto_layout splits : launch --cwd=current --location=vsplit";
      "kitty_mod+s" = "combine : goto_layout splits : launch --cwd=current --location=hsplit";
      # Same splits, but a fresh LOCAL shell — no --cwd=current, so they never
      # clone an SSH session even when the active window is remote.
      "kitty_mod+shift+v" = "combine : goto_layout splits : launch --location=vsplit";
      "kitty_mod+shift+s" = "combine : goto_layout splits : launch --location=hsplit";
      "kitty_mod+r" = "set_tab_title";

      "kitty_mod+u" = "previous_tab";
      "kitty_mod+i" = "next_tab";

      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "launch --type=background --allow-remote-control --keep-focus ${clip2path}";

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
      cursor_shape block
    '';
  };

  xdg.configFile."kitty/sessions".source = ./sessions;
}
