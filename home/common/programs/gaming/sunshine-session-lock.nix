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

  blankOutputs = lib.concatMapStringsSep " " lib.escapeShellArg cfg.sunshineBlankOutputs;

  sunshine-session-lock = pkgs.writeShellApplication {
    name = "sunshine-session-lock";
    runtimeInputs = [
      pkgs.systemd
      pkgs.procps
    ];
    text = ''
      # systemctl --user reaches the session manager through $XDG_RUNTIME_DIR/bus;
      # sunshine's environment does not always carry the variable.
      export XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
      stamp="$XDG_RUNTIME_DIR/sunshine-session-unlocked"
      # Read by hypridle.service as ConditionPathExists=!%t/sunshine-streaming,
      # so a home-manager activation mid-stream cannot restart the daemon behind
      # our back. Lives on tmpfs, so a reboot clears a stamp left by a crash.
      streaming="$XDG_RUNTIME_DIR/sunshine-streaming"

      # The graphical seat session — NOT the `manager` session that the sunshine
      # user service itself runs in. Sunshine's environment carries no
      # XDG_SESSION_ID, so bare `loginctl lock-session` has nothing to resolve.
      # Selected by property rather than column position, which shifts between
      # systemd releases.
      # Outputs Sunshine does not capture. Hyprland stops compositing a
      # DPMS-off output entirely, so for the life of the stream the GPU renders
      # one 4K screen instead of three.
      #
      # These do NOT come back on their own: misc.mouse_move_enables_dpms and
      # misc.key_press_enables_dpms are both false by default on 0.56, so the
      # `lock` path is the only thing that restores them. A blank-but-unfixable
      # desktop is the failure mode to watch for if that path ever stops running
      # — recover with `hypr-dpms on`.
      outputs=(${blankOutputs})

      set_blanked() {
        local out
        for out in ''${outputs[@]+"''${outputs[@]}"}; do
          # Never fatal: losing the stream because one output name went stale
          # (cable moved, monitor off) would be a much worse trade.
          ${config.custom.hyprland.dpmsCommand} "$1" "$out" || true
        done
      }

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
          # Gamepad input arrives on a uinput joystick, which is not part of the
          # wl_seat, so it never resets Hyprland's idle notifier: controller-only
          # play looks idle and the 900s listener locks mid-game. The dbus
          # inhibitor cannot prevent this either, because hypridle runs with
          # ignore_dbus_inhibit = true (see hyprland/default.nix). Stopping the
          # daemon for the life of the stream is the only lever left.
          touch "$streaming"
          systemctl --user stop hypridle || true

          set_blanked off

          # No hyprlock running means the session was already unlocked: do
          # nothing, and leave no stamp so `lock` won't lock it on the way out.
          if pkill -u "$(id -u)" -USR1 -x hyprlock; then
            touch "$stamp"
          fi
          ;;

        lock)
          # Before the stamp check: idle timers and the blanked outputs must
          # come back even when the stream arrived at an already-unlocked
          # session and left no stamp.
          rm -f "$streaming"
          systemctl --user start hypridle || true
          set_blanked on

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

  options.custom.gaming.sunshineBlankOutputs = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = [
      "HDMI-A-1"
      "DP-2"
    ];
    description = ''
      Outputs to DPMS-off for the duration of a Sunshine stream — every screen
      except the one Sunshine captures. Which one that is comes from the
      journal: `journalctl --user -u sunshine | grep "Selected monitor"`.
      Leave empty to keep all displays on.
    '';
  };

  config = lib.mkIf cfg.sunshineSessionLock {
    home.packages = [ sunshine-session-lock ];

    # A failed condition makes `systemctl start` a silent no-op rather than an
    # error, so this only suppresses the restart that home-manager activation
    # performs; the explicit start in the `lock` path removes the stamp first.
    systemd.user.services.hypridle.Unit.ConditionPathExists = "!%t/sunshine-streaming";
  };
}
