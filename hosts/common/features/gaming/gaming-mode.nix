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
  gamescopeShim = pkgs.writeShellScriptBin "gamescope" ''
    args=()
    for arg in "$@"; do
      if [ "$arg" = "*,eDP-1" ]; then
        arg="${cfg.output},*"
      fi
      args+=("$arg")
    done
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

  config = {
    jovian.steam = {
      enable = true;
      user = "naps62";
    };

    # Steam Deck kernel flags, zram, earlyoom and bluetooth tuning.
    jovian.steamos.useSteamOSConfig = false;

    services.orca.enable = false;

    # Jovian installs the same cap_sys_nice gamescope wrapper; two definitions
    # collide.
    programs.gamescope.capSysNice = lib.mkForce false;

    # Sourced by the session script just before it execs gamescope.
    environment.etc."jovian/gamescope-session/pre-start" = lib.mkIf (cfg.output != null) {
      text = ''
        export PATH=${gamescopeShim}/bin:$PATH
      '';
    };
  };
}
