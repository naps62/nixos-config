{ config, pkgs, ... }:
let
  rofiLaunchers = import ../../../pkgs/rofi-launchers/package.nix { };
in
{
  imports = [
    ./rofi.nix
    ./dunst.nix
    ./cursor.nix
  ];

  home.packages = with pkgs; [
    hyprcursor
    pamixer
    hyprshot
    hyprpanel
    playerctl
    hyprsunset
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
        numlock_by_default = 2;
      };

      cursor = {
        no_hardware_cursors = "yes";
      };

      general = {
        border_size = 0;
        gaps_in = 4;
        gaps_out = 0;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      xwayland = {
        force_zero_scaling = true;
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

      env = [
        "XCURSOR_SIZE, 32"
        "HYPRCURSOR_THEME, rose-pine-hyprcursor"
        "HYPRCURSOR_SIZE, 24"
      ];

      "exec-once" = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "hyprpanel"
        "nm-applet"
        "hyprsunset"
      ];

      windowrulev2 = [
        # imv
        "float, class:imv"
        "move cursor -50% -50%, class:imv"

        # bluetooth
        "float, class:blueman-manager"
        "move cursor -50% -50%, class:blueman-manager"
        "size 600 400, class:blueman-manager"

        # pavucontrol
        "float, class:pavucontrol"
        "move cursor -50% -50%, class:pavucontrol"
        "size 600 600, class:pavucontrol"
      ];

      "$mod" = "SUPER";

      bind = [
        "$mod, t, exec, ghostty"
        "$mod, e, exec, thunar"
        "$mod, v, togglefloating"
        "$mod, q, killactive"
        "$mod, f, fullscreen, 0"
        "$mod SHIFT, f, fullscreen, 1"

        # rofi
        "$mod, space, exec, launcher_t2"

        # printscreen
        ", Print, exec, hyprshot -m region --output-folder ~/screenshots"
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
}
