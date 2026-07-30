{
  ...
}:
{
  imports = [
    ../common/programs/default.nix
    ../common/programs/desktop
    ../common/programs/zen-browser.nix
    ../common/programs/hyprland
    ../common/programs/kitty
    ../common/programs/ethui.nix
    ../common/programs/gpg.nix
    ../common/features/xdg.nix
    ../common/features/downloads-cleanup.nix
    ../common/programs/3d.nix
    ../common/programs/godot.nix
    ../common/programs/gaming
    ./monitors.nix
  ];

  custom.hyprland.cursorSize = 32;

  # Moonlight: client for the Sunshine server on konishi (stream games to this laptop).
  custom.gaming.moonlight = true;

  # RetroArch (bare — cores/ROMs added by hand, WebDAV configured in-app).
  custom.gaming.retroarch = true;

  wayland.windowManager.hyprland.extraConfig = ''
    hl.workspace_rule({ workspace = "1", monitor = "DP-3" })
    hl.workspace_rule({ workspace = "2", monitor = "eDP-1" })
    hl.workspace_rule({ workspace = "3", monitor = "eDP-1" })
    hl.workspace_rule({ workspace = "4", monitor = "eDP-1" })

    hl.window_rule({
      match = { class = "bevy-.*" },
      no_initial_focus = true,
      float = true,
      size = "800 600",
      move = "100%-800 100%-600",
    })
  '';

  # v4 `bar.density` has no v5 equivalent; spacing is tuned via
  # bar.main.padding / widget_spacing / thickness if needed.
}
