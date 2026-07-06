{
  config,
  lib,
  pkgs,
  ...
}:
# Lazy, VPN-friendly SMB/CIFS automounts.
#
# Each entry becomes a systemd *automount* rather than a plain mount, so:
#   * boot never hangs — nothing connects to the server at boot; only the
#     lightweight .automount unit is installed (noauto + x-systemd.automount).
#   * it mounts on first access — when something touches the mount point (e.g.
#     RetroArch reading its save dir), systemd performs the real CIFS mount.
#   * it's VPN-safe — a short mount-timeout means an access while the VPN is
#     down fails fast instead of blocking, and the automount re-arms so the next
#     access retries. Once wg-home is up, the next access succeeds. An idle
#     timeout unmounts the share so it re-mounts fresh after a VPN drop (no
#     stale handles).
#
# NOTE: wg-home is a NetworkManager connection managed outside the flake, so the
# mount deliberately does NOT depend on the wg interface unit — the on-access
# retry model needs no knowledge of when the VPN is up.
let
  cfg = config.custom.smbMounts;
in
{
  options.custom.smbMounts = lib.mkOption {
    description = "Guest SMB/CIFS shares to expose as lazy, VPN-safe automounts.";
    default = [ ];
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          server = lib.mkOption {
            type = lib.types.str;
            description = "SMB server host or IP (reachable over the VPN), e.g. \"10.10.0.1\".";
          };
          share = lib.mkOption {
            type = lib.types.str;
            description = "Share name on the server, e.g. \"retroarch\".";
          };
          mountPoint = lib.mkOption {
            type = lib.types.str;
            description = "Local mount point, e.g. \"/mnt/retroarch\".";
          };
          user = lib.mkOption {
            type = lib.types.str;
            default = "naps62";
            description = "Local owner of the mounted files (CIFS uid/gid).";
          };
          idleTimeout = lib.mkOption {
            type = lib.types.str;
            default = "600";
            description = "Seconds of inactivity before the share is unmounted.";
          };
        };
      }
    );
  };

  config = lib.mkIf (cfg != [ ]) {
    # mount.cifs helper must be on PATH for systemd to perform the mount.
    environment.systemPackages = [ pkgs.cifs-utils ];

    fileSystems = lib.listToAttrs (
      map (m: {
        name = m.mountPoint;
        value = {
          device = "//${m.server}/${m.share}";
          fsType = "cifs";
          options = [
            # --- guest auth (no credentials) ---
            "guest"
            # --- lazy, VPN-safe automount ---
            "_netdev" # network fs: don't treat as a boot-blocking local mount
            "noauto" # don't mount at boot…
            "x-systemd.automount" # …mount on first access instead
            "x-systemd.mount-timeout=10s" # fail fast if the server is unreachable
            "x-systemd.idle-timeout=${m.idleTimeout}" # unmount when idle → fresh remount after VPN drop
            "nofail" # never let a failed mount fault the system
            # --- ownership / perms so ${m.user} can read+write ---
            "uid=${m.user}"
            "gid=users"
            "file_mode=0664"
            "dir_mode=0775"
            # If the server is old and rejects the negotiated dialect, pin it,
            # e.g. add "vers=1.0" and "sec=ntlm". Modern servers auto-negotiate.
          ];
        };
      }) cfg
    );
  };
}
