_: {
  # Hyprland 0.55+ is Lua-only (see home/common/programs/hyprland).
  #
  # Matches every output rather than naming one: the virtio-gpu connector name
  # varies by qemu display backend (Virtual-1 vs Virtual-0). Explicit mode, not
  # `preferred` — this is the resolution Sunshine streams.
  #
  # 2160p is near the ceiling: virtio-gpu has no NVENC/VAAPI, so Sunshine falls
  # back to x264, which measured 73fps here against 135fps at 1440p — a 60fps
  # client has only ~20% margin.
  wayland.windowManager.hyprland.extraConfig = ''
    hl.monitor({ output = "", mode = "3840x2160@60", position = "0x0", scale = 1 })
  '';
}
