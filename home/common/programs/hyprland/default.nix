{
  config,
  inputs,
  pkgs,
  ...
}:
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
    package = null;
    portalPackage = null;
    plugins = [
      inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo
      inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprfocus
      inputs.hyprspace.packages.${pkgs.stdenv.hostPlatform.system}.Hyprspace
    ];
    settings = {
      plugin = {
        hyprexpo = {
          columns = 3;
          gap_size = 5;
          bg_col = "rgb(000000)";
          workspace_method = "center current";
        };
        hyprfocus = {
          enabled = true;
          mode = "flash";
          fade_opacity = 0.85;
        };
        overview = {
          autoDrag = true;
          exitOnClick = true;
          exitOnSwitch = true;
          showNewWorkspace = false;
          showEmptyWorkspace = false;
        };
      };
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
        on_focus_under_fullscreen = 2;
      };

      ecosystem = {
        no_update_news = true;
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

      # keep default animations, but speed them all up
      animations = {
        animation = [
          "global, 1, 2, default"
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

      windowrule = [
        # imv
        "float on, match:class imv"
        "move cursor -50% -50%, match:class imv"

        "float on, match:title termfilechooser"
        "move center, match:title termfilechooser"

        # bluetooth
        "float on, match:class blueman-manager"
        "move cursor -50% -50%, match:class blueman-manager"
        "size 600 400, match:class blueman-manager"

        # pavucontrol
        "float on, match:class pavucontrol"
        "move cursor -50% -50%, match:class pavucontrol"
        "size 600 600, match:class pavucontrol"

        # metamask
        "float on, match:class chrome-nkbihfbeogaeaoehlefnkodbefgpgknn-.*"

        # bitwarden, chrome
        "float on, match:class chrome-nngceckbapebfimnlniiiahkandclblb-.*"

        # no gaps when only window
        "border_size 0, match:float 0, match:workspace w[t1]"
        "rounding 0, match:float 0, match:workspace w[t1]"
        "border_size 0, match:float 0, match:workspace w[tg1]"
        "rounding 0, match:float 0, match:workspace w[tg1]"
        "border_size 0, match:float 0, match:workspace f[1]"
        "rounding 0, match:float 0, match:workspace f[1]"

        "move center, match:workspace special:terminal"
        "move center, match:workspace special:yazi"
      ];

      "$mod" = "SUPER";

      bind = [
        "$mod, g, hyprexpo:expo, toggle"
        "$mod, tab, overview:toggle,"
        "$mod, t, exec, kitty"
        "$mod, v, togglefloating"
        "$mod, q, killactive"
        "$mod, f, fullscreen, 0"
        "$mod SHIFT, f, fullscreen, 1"

        # rofi
        "$mod, space, exec, launcher_t2"

        # nerd-dictation
        # "$mod, d, exec, nerd-dictation-toggle"

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
