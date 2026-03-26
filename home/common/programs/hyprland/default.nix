{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.hyprland;
in
{
  options.custom.hyprland = {
    yaziSize = lib.mkOption {
      type = lib.types.str;
      default = "1400 1400";
      description = "Size of the yazi special workspace window";
    };
    cursorSize = lib.mkOption {
      type = lib.types.int;
      default = 24;
      description = "Cursor size for XCURSOR_SIZE and HYPRCURSOR_SIZE";
    };
  };

  imports = [
    ./cursor.nix
    ./noctalia
    ./wallpapers.nix
  ];

  config = {
    home.packages = with pkgs; [
      hyprcursor
      pamixer
      hyprshot
      satty
      playerctl
      hyprsunset
      libnotify
      cliphist
      wf-recorder
      slurp
    ];

    home.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
      plugins = [ ];
      settings = {
        plugin = {
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
            popups = false;
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
          "XCURSOR_SIZE, ${toString cfg.cursorSize}"
          "HYPRCURSOR_THEME, rose-pine-hyprcursor"
          "HYPRCURSOR_SIZE, ${toString cfg.cursorSize}"
        ];

        "exec-once" = [
          "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
          "hyprctl setcursor Nordzy-cursors ${toString cfg.cursorSize}"
          "hyprsunset"
          "nerd-dictation begin --simulate-input-tool WTYPE --suspend-on-start && touch ~/.cache/nerd-dictation-suspended"
          "noctalia-shell"
        ];

        layerrule = [
          "blur 1, match:namespace noctalia-background-.*"
          "ignore_alpha 0.5, match:namespace noctalia-background-.*"
        ];
        workspace = [
          # no gaps when only window
          "w[t1], gapsout:0, gapsin:0"
          "w[tg1], gapsout:0, gapsin:0"
          "f[1], gapsout:0, gapsin:0"

          "special:terminal, on-created-empty:[float; size 1400 1000; move center] kitty, persistent:false"
          "special:yazi, on-created-empty:[float; size ${cfg.yaziSize}; move center] kitty --session sessions/yazi, persistent:false"
        ];

        windowrule = [
          # satty
          "float on, match:class com.gabm.satty"

          # imv
          "float on, match:class imv"
          "size 1920 1080, match:class imv"
          "move (cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5)), match:class imv"

          # mpv
          "float on, match:class mpv"
          "size 1920 1080, match:class mpv"
          "move (cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5)), match:class mpv"

          "float on, match:title termfilechooser"
          "size 1200 800, match:title termfilechooser"
          "move center, match:title termfilechooser"

          # thunar
          "float on, match:class thunar"
          "size 1800 1200, match:class thunar"
          "move (cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5)), match:class thunar"

          # bluetooth
          "float on, match:class \\.blueman-manager-wrapped"
          "size 1200 800, match:class \\.blueman-manager-wrapped"
          "move (cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5)), match:class \\.blueman-manager-wrapped"

          # pavucontrol
          "float on, match:class org\\.pulseaudio\\.pavucontrol"
          "size 1200 1200, match:class org\\.pulseaudio\\.pavucontrol"
          "move (cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5)), match:class org\\.pulseaudio\\.pavucontrol"

          # metamask
          "float on, match:class chrome-nkbihfbeogaeaoehlefnkodbefgpgknn-.*"

          # bitwarden, chrome
          "float on, match:class chrome-nngceckbapebfimnlniiiahkandclblb-.*"

          # claude for chrome
          "float on, match:class chrome-fcoeoabgfenejglbffodgkkbkcdhcgfn-.*"
          "move (cursor_x-(window_w*0.5)) (cursor_y-(window_h*0.5)), match:class chrome-fcoeoabgfenejglbffodgkkbkcdhcgfn-.*"

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
          "$mod, n, exec, noctalia-shell ipc call controlCenter toggle"
          "$mod, t, exec, kitty"
          "$mod, v, togglefloating"
          "$mod, q, killactive"
          "$mod, f, fullscreen, 0"
          "$mod SHIFT, f, fullscreen, 1"

          "$mod, space, exec, noctalia-shell ipc call launcher toggle"

          # printscreen
          ", Print, exec, hyprshot -m region --raw | satty --filename - --output-filename ~/downloads/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"
          "SHIFT, Print, exec, hyprshot -m window --raw | satty --filename - --output-filename ~/downloads/screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"

          # move focus with mod + arrows
          "$mod, h, movefocus, l"
          "$mod, j, movefocus, d"
          "$mod, k, movefocus, u"
          "$mod, l, movefocus, r"

          # Switch workspaces with mod + [0-9]
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
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

    services.hyprpaper.enable = false;

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = "hyprctl dispatch dpms on";
          ignore_dbus_inhibit = false;
          lock_cmd = "noctalia-shell ipc call lockScreen lock";
        };
        listener = [
          {
            timeout = 900;
            on-timeout = "noctalia-shell ipc call lockScreen lock";
          }
          {
            timeout = 1200;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
        ];
      };
    };
  };
}
