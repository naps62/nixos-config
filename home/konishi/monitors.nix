_:
{
  # Hyprland 0.55+ is Lua-only (see home/common/programs/hyprland); monitors and
  # workspace rules are expressed with the hl.* API in raw Lua.
  wayland.windowManager.hyprland.extraConfig = ''
    -- single monitor
    hl.monitor({ output = "DP-1", mode = "3840x2160", position = "0x0", scale = 1 })

    -- workspace -> monitor bindings
    hl.workspace_rule({ workspace = "1", monitor = "DP-1", default = true, persistent = true })
    hl.workspace_rule({ workspace = "2", monitor = "DP-1", persistent = true })
    hl.workspace_rule({ workspace = "3", monitor = "DP-1", persistent = true })
    hl.workspace_rule({ workspace = "4", monitor = "DP-1" })
    hl.workspace_rule({ workspace = "5", monitor = "DP-1" })
    hl.workspace_rule({ workspace = "6", monitor = "DP-1" })
  '';
}
