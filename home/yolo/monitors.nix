_:
{
  # Hyprland 0.55+ is Lua-only (see home/common/programs/hyprland).
  #
  # Matches every output rather than naming one: the virtio-gpu connector name
  # varies by qemu display backend (Virtual-1 vs Virtual-0). Explicit mode, not
  # `preferred` — this is the resolution Sunshine streams.
  wayland.windowManager.hyprland.extraConfig = ''
    hl.monitor({ output = "", mode = "2560x1440@60", position = "0x0", scale = 1 })
  '';
}
