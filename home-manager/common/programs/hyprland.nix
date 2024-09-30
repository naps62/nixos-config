{ config, pkgs, ... }: {
  wayland.windowManager.hyprland.settings = {
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

    bindm = [
      "$mod, t, exec kitty"
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
      "$mod SHIFT, 7, movetoworkspace, 7"
      "$mod SHIFT, 8, movetoworkspace, 8"
      "$mod SHIFT, 9, movetoworkspace, 9"
      "$mod SHIFT, 0, movetoworkspace, 10"
    ];

  };
}
