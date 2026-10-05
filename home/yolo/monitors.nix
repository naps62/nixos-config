_: {
  # Hyprland 0.55+ is Lua-only (see home/common/programs/hyprland).
  #
  # Matches every output rather than naming one: the virtio-gpu connector name
  # varies by qemu display backend (Virtual-1 vs Virtual-0). Explicit mode, not
  # `preferred` — this is the resolution Sunshine streams.
  #
  # 1080p, not 2160p: everything is tiny at 4K@1x on a typical Moonlight client.
  # It also leaves x264 plenty of margin — virtio-gpu has no NVENC/VAAPI, and
  # software encode measured 73fps at 2160p against 135fps at 1440p.
  wayland.windowManager.hyprland.extraConfig = ''
    hl.monitor({ output = "", mode = "1920x1080@60", position = "0x0", scale = 1 })
  '';
}
