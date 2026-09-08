{
  config,
  lib,
  pkgs,
  ...
}:
# Unlock the desktop when a Moonlight client connects, re-lock when it leaves.
#
# Without this the box locks on idle (hypridle, 15 min) and every later stream
# arrives at a hyprlock screen, which on a phone means three-finger-tapping the
# on-screen keyboard and typing the password into the stream. This wires the
# unlock to Sunshine's stream lifecycle instead.
#
# hyprlock releases the session lock on SIGUSR1 with no PAM prompt at all
# (src/core/hyprlock.cpp: handleUnlockSignal -> CAuth::enqueueUnlock). That is
# the whole mechanism; `loginctl unlock-session` does NOT work, because Wayland
# lockers own the unlock decision by design.
#
# SECURITY: this makes "holds a paired Moonlight client" equivalent to "can
# unlock this desktop", and password managers live on this box. Pairing is
# PIN-gated through the Sunshine web UI, so the exposure is a stolen/borrowed
# phone or Shield, plus the pairing certs in ~/.config/sunshine/sunshine_state.json.
# The re-lock on stream end is what keeps the window narrow — it is not a
# nicety, so treat a silently failing `lock` as a real bug.
#
# The matching hook is NOT set here. It lives in ~/.config/sunshine/sunshine.conf
# as:
#
#   global_prep_cmd = [{"do":"/home/naps62/.nix-profile/bin/sunshine-session-lock unlock","undo":"/home/naps62/.nix-profile/bin/sunshine-session-lock lock"}]
#
# That file is deliberately hand-managed rather than rendered from
# `services.sunshine.settings`: setting that option freezes the whole config
# into the Nix store and, as the module puts it, "no configuration is possible
# from the web UI" — which is how yolo ended up stuck on the default
# fec_percentage while konishi runs a hand-tuned 1.
let
  cfg = config.custom.gaming;

  sunshine-session-lock = pkgs.writeShellApplication {
    name = "sunshine-session-lock";
    runtimeInputs = [
      pkgs.systemd
      pkgs.procps
    ];
    text = ''
      stamp="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/sunshine-session-unlocked"

      # The graphical seat session — NOT the `manager` session that the sunshine
      # user service itself runs in. Sunshine's environment carries no
      # XDG_SESSION_ID, so bare `loginctl lock-session` has nothing to resolve.
      # Selected by property rather than column position, which shifts between
      # systemd releases.
      graphical_session() {
        local s
        while read -r s; do
          [ "$(loginctl show-session "$s" -p Class --value)" = "user" ] || continue
          [ "$(loginctl show-session "$s" -p Type --value)" = "wayland" ] || continue
          echo "$s"
          return 0
        done < <(loginctl list-sessions --no-legend | awk '{print $1}')
        return 1
      }

      case "''${1:-}" in
        unlock)
          # No hyprlock running means the session was already unlocked: do
          # nothing, and leave no stamp so `lock` won't lock it on the way out.
          if pkill -u "$(id -u)" -USR1 -x hyprlock; then
            touch "$stamp"
          fi
          ;;

        lock)
          [ -e "$stamp" ] || exit 0
          rm -f "$stamp"
          s="$(graphical_session)" || exit 0
          # Via logind rather than spawning hyprlock directly, so LockedHint
          # flips and hypridle stays in agreement about the session state.
          loginctl lock-session "$s"
          ;;

        *)
          echo "usage: sunshine-session-lock unlock|lock" >&2
          exit 64
          ;;
      esac
    '';
  };
in
{
  options.custom.gaming.sunshineSessionLock = lib.mkEnableOption ''
    unlocking the session while a Sunshine stream is connected. Only for hosts
    that actually run Sunshine, and read the security note in this file first
  '';

  config = lib.mkIf cfg.sunshineSessionLock {
    home.packages = [ sunshine-session-lock ];
  };
}
