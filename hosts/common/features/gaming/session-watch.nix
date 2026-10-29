{ pkgs, ... }:
# Black box recorder for the Hyprland / gamescope / Plasma session switching.
# When a switch wedges the box the journal survives, but the live state (which
# process is spinning, what failed, CPU pressure) does not. This samples every
# 15s and, on a trigger, writes a snapshot to /var/log/session-watch/. It only
# records; it never restarts or kills anything.
let
  user = "naps62";

  watch = pkgs.writeShellApplication {
    name = "session-watch";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      gnugrep
      procps
      systemd
    ];
    text = ''
      # A monitor must survive failing probes (and SIGPIPE from `head`).
      set +e +o pipefail
      dir=/var/log/session-watch
      mkdir -p "$dir"
      declare -A last

      user_ctl() { systemctl --user -M "${user}@.host" "$@"; }

      snapshot() {
        local reason=$1 now
        now=$(date +%s)
        # One snapshot per reason every 5 minutes.
        if [ $(( now - ''${last[$reason]:-0} )) -lt 300 ]; then return; fi
        last[$reason]=$now
        {
          echo "reason: $reason"
          date -Is
          echo; echo "== uptime / pressure"; uptime
          grep -H . /proc/pressure/cpu /proc/pressure/memory /proc/pressure/io
          echo; echo "== top cpu"; ps -eo pid,user,pcpu,pmem,etimes,comm --sort=-pcpu | head -16
          echo; echo "== sessions"; loginctl list-sessions --no-legend
          echo; echo "== failed (system)"; systemctl --failed --no-legend
          echo; echo "== failed (user)"; user_ctl --failed --no-legend || true
          echo; echo "== coredumps by process, last 10 min"
          journalctl --since "-10min" -t systemd-coredump --no-pager -q \
            | grep "dumped core" | sed -E 's/.*\(([^)]*)\).*/\1/' | sort | uniq -c | sort -rn | head
          echo; echo "== system journal, warnings, last 5 min"
          journalctl --since "-5min" -p warning --no-pager -q | tail -150
          echo; echo "== user journal, warnings, last 5 min"
          journalctl --since "-5min" -p warning --no-pager -q \
            _UID="$(id -u ${user})" | tail -150
          echo; echo "== sunshine.log tail"
          tail -40 /home/${user}/.config/sunshine/sunshine.log 2>/dev/null || true
        } > "$dir/$(date +%Y%m%d-%H%M%S)-$reason.txt" 2>&1
        # Keep the 60 most recent snapshots.
        # shellcheck disable=SC2012
        ls -1t "$dir" | tail -n +61 | while read -r f; do rm -f "$dir/$f"; done
      }

      while true; do
        cores=$(journalctl --since "-60s" -t systemd-coredump --no-pager -q \
          | grep -c "dumped core" || true)
        [ "$cores" -ge 10 ] && snapshot coredump-storm

        cpu=$(awk -F'[= ]' '/^some/ {print int($3)}' /proc/pressure/cpu)
        [ "$cpu" -ge 80 ] && snapshot cpu-pressure

        user_ctl is-failed --quiet sunshine.service && snapshot sunshine-failed
        sleep 15
      done
    '';
  };
in
{
  systemd.services.session-watch = {
    description = "Record diagnostics when the desktop session goes bad";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${watch}/bin/session-watch";
      Restart = "always";
      RestartSec = 10;
      Nice = 10;
    };
  };
}
