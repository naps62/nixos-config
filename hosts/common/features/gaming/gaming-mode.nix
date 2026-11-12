{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
# SteamOS-style gaming mode: the "Steam" session in SDDM, with Plasma
# (display/plasma.nix) as its desktop mode. Built on Jovian-NixOS's steam
# module; NVIDIA is not a Jovian-supported target.
let
  cfg = config.custom.gamingMode;

  # The session script hard-codes `-O '*',eDP-1`, so on several monitors gaming
  # mode lands on whichever output gamescope enumerates first.
  #
  # On NVIDIA, direct scanout and the HDR float formats produce artifacts and
  # flickering rectangles (Vulkan reports no DRM modifiers for them), so HDR is
  # dropped and composition forced.
  gamescopeShim = pkgs.writeShellScriptBin "gamescope" ''
    args=(--force-composition --disable-layers --disable-color-management)
    skip=0
    for arg in "$@"; do
      if [ "$skip" = 1 ]; then skip=0; continue; fi
      case "$arg" in
        --hdr-enabled) continue ;;
        "*,eDP-1") arg="${cfg.output},*" ;;
        # The session script hard-codes -w 1280 -h 800, so Steam's UI is
        # rendered at 800p and upscaled; games pick their own size.
        -w|-h) skip=1; continue ;;
      esac
      args+=("$arg")
    done
    args+=(-w ${toString cfg.width} -h ${toString cfg.height})
    exec /run/wrappers/bin/gamescope "''${args[@]}"
  '';
in
{
  imports = [ inputs.jovian.nixosModules.default ];

  options.custom.gamingMode.output = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    example = "HDMI-A-1";
    description = ''
      DRM connector gaming mode prefers when several are connected. Leave null
      on a single screen.
    '';
  };

  options.custom.gamingMode.width = lib.mkOption {
    type = lib.types.int;
    default = 3840;
    description = "Resolution Steam's UI renders at inside gamescope.";
  };

  options.custom.gamingMode.height = lib.mkOption {
    type = lib.types.int;
    default = 2160;
    description = "See width.";
  };

  config = {
    jovian.steam = {
      enable = true;
      user = "naps62";
    };

    # Steam Deck kernel flags, zram, earlyoom and bluetooth tuning.
    jovian.steamos.useSteamOSConfig = false;

    services.orca.enable = false;

    # Steam sets GAMESCOPE_COMPOSITE_FORCE=0 once it starts, overriding the
    # shim's --force-composition and bringing back the NVIDIA scanout tearing.
    environment.etc."gamescope/scripts/99-force-composition.lua" = lib.mkIf (cfg.output != null) {
      text = ''
        gamescope.hook("OnPostPaint", function()
          if not gamescope.convars.composite_force.value then
            warn("force-composition: re-enabling composite_force")
            gamescope.convars.composite_force.value = true
          end
        end)
      '';
    };

    # Jovian installs the same cap_sys_nice gamescope wrapper; two definitions
    # collide.
    programs.gamescope.capSysNice = lib.mkForce false;

    # Sourced by the session script just before it execs gamescope.
    environment.etc."jovian/gamescope-session/pre-start".text = ''
      # The user systemd manager outlives a Hyprland logout and keeps its
      # WAYLAND_DISPLAY, so gamescope starts nested on a dead socket, not DRM.
      unset WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE
    ''
    + lib.optionalString (cfg.output != null) ''
      export PATH=${gamescopeShim}/bin:$PATH
    '';
  };
}
