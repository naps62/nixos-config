{
  ...
}:
{
  imports = [
    ../common/programs/default.nix
    ../common/programs/desktop
    ../common/programs/workstation-apps.nix
    ../common/programs/editors.nix
    ../common/programs/dev-workstation.nix
    ../common/programs/ai-gui.nix
    ../common/programs/zen-browser.nix
    ../common/programs/hyprland
    ../common/programs/kitty
    ../common/programs/gpg.nix
    ../common/programs/ethui.nix
    ../common/programs/3d.nix
    ../common/programs/godot.nix
    ../common/programs/gaming
    ../common/features/xdg.nix
    ../common/features/downloads-cleanup.nix
    ./monitors.nix
  ];

  home.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    # Was GDM_BACKEND, which nothing reads (SDDM is the DM here).
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";

    # Firefox/Zen decode video in a separate RDD process whose sandbox denies
    # /dev/nvidia*, so nvidia-vaapi-driver never initialises there and playback
    # silently drops to software. Costs one sandbox layer; no narrower switch
    # exists. Check with `nvidia-smi --query-gpu=utilization.decoder`.
    MOZ_DISABLE_RDD_SANDBOX = "1";
  };

  # Plain `nvdec` keeps frames in GPU memory and breaks some filters.
  custom.mpv.hwdec = "nvdec-copy";
  custom.blender.cuda = true;

  custom.hyprland = {
    yaziSize = "2400 1800";
    cursorSize = 42;
    # The screen actually shared in every call; skips the xdph picker entirely.
    shareOutput = "HDMI-A-1";
    verticalOutputs = [ "DP-2" ];
    panelScale = 1.6;
  };

  custom.gaming = {
    enable = true;
    nvidia = true;
    retroarch = true;
    moonlight = true;
  };

  # 4K@1x monitors render the Electron AI apps tiny; scale their UI up. Tune to taste.
  custom.aiApps.deviceScaleFactor = "1.5";

  wayland.windowManager.hyprland.extraConfig = ''
    hl.on("hyprland.start", function()
      -- boot-into-lock: paired with SDDM autologin (host config), lock the
      -- session the moment Hyprland starts so a cold boot lands on hyprlock, not
      -- an open desktop. A brief flash before it paints is possible.
      hl.exec_cmd("hyprlock")
    end)

    -- ethui-dev
    hl.window_rule({ match = { title = "ethui-dev.*" }, workspace = "2", no_initial_focus = true })
    hl.window_rule({ match = { title = "ethui-dev - dialog.*" }, float = true })

    hl.window_rule({ match = { title = "ethui.*" }, workspace = "1", no_initial_focus = true })
    hl.window_rule({ match = { title = "ethui - dialog.*" }, float = true })

    hl.window_rule({ match = { title = [[^\[bevy\].*]] }, workspace = "1" })

    hl.window_rule({ match = { class = "bevy-.*" }, workspace = "3 silent", no_initial_focus = true, fullscreen = true })

    hl.window_rule({
      match = { title = "egui-.*" },
      workspace = "1 silent",
      border_size = 0,
      float = true,
      no_blur = true,
      move = "100%-w-20 100%-h-20",
    })

    -- gaming: Steam/Proton titles run under XWayland with WM_CLASS
    -- steam_app_<appid>. Send them fullscreen to workspace 3 (DP-1) — the same
    -- streamed workspace as Big Picture below — instead of opening tiled on
    -- whatever monitor Steam is on.
    -- Native (non-Proton) games have their own class — grab it with
    -- `hyprctl clients | grep -iE "class|title"` while the game runs and add a
    -- matching rule here.
    hl.window_rule({ match = { class = "steam_app_.*" }, workspace = "3", fullscreen = true })

    -- Steam Big Picture shares the plain `steam` WM_CLASS with the normal
    -- client, so match its title instead. Without this it opens on whatever
    -- monitor the cursor is on, not the streamed one. Pin it to ws3 — DP-1's
    -- normal persistent workspace, which is what the stream captures. `.`
    -- stands in for the literal spaces to keep the rule string unambiguous.
    hl.window_rule({ match = { title = "Steam.Big.Picture.Mode" }, workspace = "3", fullscreen = true })

    -- Heroic (GOG/Epic launcher) streamed via Moonlight — `heroic --console`.
    -- Tile it on ws3 (DP-1, the captured screen) rather than letting it float
    -- or land on whatever monitor the cursor is on. Games it launches are
    -- Proton titles → caught by the steam_app_ rules above; native ones need
    -- their own class added here.
    hl.window_rule({ match = { class = "heroic" }, workspace = "3", tile = true })

    -- RetroArch streamed via Moonlight (also registered as a Sunshine app).
    -- Native Wayland app_id is `com.libretro.RetroArch` (set at map time) — the
    -- exact string is needed so the rule applies on spawn; a loose `retroarch`
    -- match misses at map and the window flashes onto the active workspace
    -- first. `silent` sends it to ws3 (DP-1, the captured screen) without
    -- yanking focus off whatever workspace you're driving from.
    hl.window_rule({ match = { class = "com.libretro.RetroArch" }, workspace = "3 silent", fullscreen = true })

    -- Experiment: was `true`. With a fullscreen game direct-scanning-out,
    -- Sunshine starting a capture forces the compositor off the direct path,
    -- and that surface/context churn is a suspected trigger for Chromium's
    -- `EGL_CONTEXT_LOST` crash (Big Picture drops to software rendering mid-
    -- stream). Disabled to test whether the crashes stop. If it makes no
    -- difference, flip back to `true` for the local fullscreen latency win.
    hl.config({ render = { direct_scanout = false } })
  '';

  programs.kitty.settings.font_size = 16;
}
