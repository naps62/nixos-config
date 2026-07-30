_:
{
  # Hyprland 0.55+ is Lua-only (see home/common/programs/hyprland).
  wayland.windowManager.hyprland.extraConfig = ''
    hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1, bitdepth = 8 })
    hl.monitor({ output = "DP-1", mode = "preferred", position = "auto-up", scale = 1 })
    hl.monitor({ output = "DP-2", mode = "preferred", position = "auto-up", scale = 1 })
    hl.monitor({ output = "DP-3", mode = "preferred", position = "auto-up", scale = 1 })
    hl.monitor({ output = "DP-4", mode = "preferred", position = "auto-up", scale = 1 })
  '';
}
