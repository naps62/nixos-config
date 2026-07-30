_:
{
  # Hyprland 0.55+ is Lua-only (see home/common/programs/hyprland); monitors and
  # workspace rules are expressed with the hl.* API in raw Lua.
  wayland.windowManager.hyprland.extraConfig = ''
    -- monitors (HDMI-A-1 listed first so it becomes the primary, ID 0)
    hl.monitor({ output = "HDMI-A-1", mode = "3840x2160", position = "0x2160", scale = 1 })
    hl.monitor({ output = "DP-2", mode = "3840x2160", position = "3840x180", scale = 1, transform = 1 })
    hl.monitor({ output = "DP-1", mode = "3840x2160", position = "0x0", scale = 1 })

    -- workspace -> monitor bindings
    hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1", default = true, persistent = true })  -- bottom-left (primary)
    hl.workspace_rule({ workspace = "2", monitor = "DP-2", persistent = true })                      -- right (vertical)
    hl.workspace_rule({ workspace = "3", monitor = "DP-1", persistent = true })                      -- top-left
    hl.workspace_rule({ workspace = "4", monitor = "HDMI-A-1" })
    hl.workspace_rule({ workspace = "5", monitor = "DP-2" })
    hl.workspace_rule({ workspace = "6", monitor = "DP-1" })
  '';
}
