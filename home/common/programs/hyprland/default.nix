{ config, pkgs, ... }:
let
  rofiLaunchers = import ../../../pkgs/rofi-launchers/package.nix { };
in
{
  imports = [
    ./rofi.nix
    ./cursor.nix
    ./hyprpanel.nix
  ];

  home.packages = with pkgs; [
    hyprcursor
    pamixer
    hyprshot
    playerctl
    hyprsunset
    hyprlock
    xdg-desktop-portal-termfilechooser
  ];

  home.sessionVariables = {
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      input = {
        kb_options = "ctrl:nocaps";
        repeat_delay = 150;

        touchpad = {
          natural_scroll = "yes";
        };
        numlock_by_default = true;
      };

      cursor = {
        no_hardware_cursors = "yes";
      };

      general = {
        border_size = 1;
        gaps_in = 0;
        gaps_out = 0;
        snap = {
          enabled = true;
          border_overlap = true;
        };

        "col.inactive_border" = "0x99999999";
        "col.active_border" = "0x99999999";
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        new_window_takes_over_fullscreen = 2;
      };

      xwayland = {
        force_zero_scaling = true;
      };

      decoration = {
        blur = {
          enabled = true;
          # new_optimizations = false;
        };
        shadow = {
          enabled = false;
        };
      };

      animations = {
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.0"
          "winIn, 0.1, 1.0, 0.1, 1.0"
          "winOut, 0.3, -0.3, 0, 1"
          "liner, 1, 1, 1, 1"
          "fadeIn, 0, 0, 0.98, 1"
        ];
        animation = [
          "windows, 1, 2, wind, popin 80%"
          "windowsIn, 1, 2, fadeIn, popin 80%"
          "windowsOut, 1, 5, winOut, popin 80%"
          "windowsMove, 1, 5, wind, slide"
          "border, 1, 1, liner"
          "borderangle, 1, 30, liner, loop"
          "fade, 1, 2, fadeIn"
          "fadeIn, 1, 2, fadeIn"
          "fadeOut, 1, 2, winOut"
          "workspaces, 1, 2, wind"
          "windowsMove, 0, 1, default, slide"
          # "specialWorkspace, 0, 2, default, fade"
          "specialWorkspace, 1, 2, fadeIn, fade"
        ];
      };

      env = [
        "GDK_SCALE, 2.0"
        "XCURSOR_SIZE, 32"
        "HYPRCURSOR_THEME, rose-pine-hyprcursor"
        "HYPRCURSOR_SIZE, 24"
      ];

      "exec-once" = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "hyprpanel"
        "nm-applet"
        "hyprsunset"
        "nerd-dictation begin --simulate-input-tool WTYPE --suspend-on-start && touch ~/.cache/nerd-dictation-suspended"
      ];
      workspace = [
        # no gaps when only window
        "w[t1], gapsout:0, gapsin:0"
        "w[tg1], gapsout:0, gapsin:0"
        "f[1], gapsout:0, gapsin:0"

        "special:terminal, on-created-empty:[float; size 1400 1000; move center] kitty, persistent:false"
        "special:yazi, on-created-empty:[float; size 1400 1000; move center] kitty --session sessions/yazi, persistent:false"
      ];

      windowrulev2 = [
        # imv
        "float, class:imv"
        "move cursor -50% -50%, class:imv"

        "float, title:termfilechooser"
        "move center, title:termfilechooser"

        # bluetooth
        "float, class:blueman-manager"
        "move cursor -50% -50%, class:blueman-manager"
        "size 600 400, class:blueman-manager"

        # pavucontrol
        "float, class:pavucontrol"
        "move cursor -50% -50%, class:pavucontrol"
        "size 600 600, class:pavucontrol"

        # metamask
        "float, class:chrome-nkbihfbeogaeaoehlefnkodbefgpgknn-.*"

        # bitwarden, chrome
        "float, class:chrome-nngceckbapebfimnlniiiahkandclblb-.*"

        # no gaps when only window
        "bordersize 0, floating:0, onworkspace:w[t1]"
        "rounding 0, floating:0, onworkspace:w[t1]"
        "bordersize 0, floating:0, onworkspace:w[tg1]"
        "rounding 0, floating:0, onworkspace:w[tg1]"
        "bordersize 0, floating:0, onworkspace:f[1]"
        "rounding 0, floating:0, onworkspace:f[1]"

        "move center, onworkspace:special:terminal"
        "move center, onworkspace:special:yazi"
      ];

      "$mod" = "SUPER";

      bind = [
        "$mod, t, exec, kitty"
        "$mod, v, togglefloating"
        "$mod, q, killactive"
        "$mod, f, fullscreen, 0"
        "$mod SHIFT, f, fullscreen, 1"

        # rofi
        "$mod, space, exec, launcher_t2"

        # nerd-dictation
        "$mod, d, exec, nerd-dictation-toggle"

        # printscreen
        ", Print, exec, hyprshot -m region --output-folder ~/downloads/screenshots"
        "SHIFT, Print, exec, hyprshot -m window --output-folder ~/screenshots"

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

        # Move active window inside workspace
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, j, movewindow, d"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, l, movewindow, r"

        # Scroll through existing workspaces with mod + scroll
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"

        # special workspaces
        "$mod, x, togglespecialworkspace, terminal"
        "$mod, x, centerwindow"
        "$mod, e, togglespecialworkspace, yazi"
        "$mod, e, centerwindow"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
      ];
      bindl = [
        ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioMicMute, exec, volumectl -m toggle-mute"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioPlay, exec, playerctl play-pause"
      ];

      bindm = [
        # Move/resize windows with mod + LMB/RMB and dragging
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
        lock_cmd = "hyprlock";
      };
      listener = [
        {
          timeout = 900;
          on-timeout = "hyprlock";
        }
        {
          timeout = 1200;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];

    };
  };
}
