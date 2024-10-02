{ config, pkgs, ... }: {
  home.sessionVariables = {
    HYPRCURSOR_THEME = "Phinger Cursors";
    HYPRCURSOR_SIZE = 32;
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    XCURSOR_SIZE = 32;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      decoration = {
        blur = {
          enabled = "yes";
          size = 30;
          passes = 1;
          new_optimizations = "on";
        };

        drop_shadow = "yes";
        shadow_range = 2;
        shadow_render_power = 1;
      };

      input = {
        kb_layout = "us";
        kb_options = "ctrl:nocaps";
        follow_mouse = 1;
        repeat_delay = 150;
        repeat_rate = 25;

        touchpad = { natural_scroll = "yes"; };
        numlock_by_default = "true";
      };

      cursor = { no_hardware_cursors = "yes"; };

      general = {
        gaps_in = 2;
        gaps_out = 0;
      };

      animations = {
        bezier = "easeOutQuad, 0.5, 1, 0.89, 1";
        animation = [
          "windows, 1, 4, easeOutQuad"
          "windowsMove, 1, 1, easeOutQuad"
          "windowsOut, 1, 4, default, popin 80%"
          "border, 1, 4, default"
          "borderangle, 1, 4, default"
          "fade, 1, 4, default"
          "workspaces, 1, 3, default"
        ];

      };

      dwindle = { preserve_split = "yes"; };
      master = { orientation = "center"; };

      "exec-once" = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
      ];

      "$mod" = "SUPER";
      bind = [
        "$mod, t, exec, kitty"
        "$mod, e, exec, thunar"
        "$mod, v, togglefloating"
        "$mod, q, killactive"
        "$mod, f, fullscreen, 0"
        "$mod SHIFT, f, fullscreen, 1"

        # move focus with mod + arrows
        "$mod, h, movefocus, l"
        "$mod, j, movefocus, d"
        "$mod, k, movefocus, u"
        "$mod, l, movefocus, r"

        # Switch workspaces with mod + [0-9]
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"

        # Move active window to a workspace with mod + SHIFT + [0-9]
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"

        # Scroll through existing workspaces with mod + scroll
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # media
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86MonBrightnessUp, exec, light -A 10"
        ", XF86MonBrightnessDown, exec, light -U 10"
      ];
    };
  };
}
