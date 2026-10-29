{ pkgs, lib, ... }:
# Home Assistant agent: lets HA suspend this PC and see whether Sunshine and
# Steam are running, over outbound MQTT only. Wake is HA's Wake on LAN button.
#
# Broker credentials live in /etc/ha-agent/mqtt.env (root, 0400), outside the
# store:  MQTT_USER=...  and  MQTT_PASS=...
let
  host = "10.6.10.12";
  base = "office-desktop";
  avail = "${base}/availability";

  device = {
    identifiers = [ "office_desktop" ];
    name = "Office Desktop";
    model = "NixOS gaming PC";
  };

  entity = cfg: builtins.toJSON (cfg // { device = device; availability_topic = avail; });

  discovery = {
    "homeassistant/button/office_desktop/suspend/config" = entity {
      name = "Suspend";
      unique_id = "office_desktop_suspend";
      command_topic = "${base}/command";
      payload_press = "suspend";
      icon = "mdi:power-sleep";
    };
    "homeassistant/binary_sensor/office_desktop/sunshine/config" = entity {
      name = "Sunshine";
      unique_id = "office_desktop_sunshine";
      state_topic = "${base}/sunshine";
      device_class = "running";
      payload_on = "ON";
      payload_off = "OFF";
    };
    "homeassistant/binary_sensor/office_desktop/steam/config" = entity {
      name = "Steam";
      unique_id = "office_desktop_steam";
      state_topic = "${base}/steam";
      device_class = "running";
      payload_on = "ON";
      payload_off = "OFF";
    };
  };

  # mosquitto clients read their options from a file, which keeps the password
  # out of the process list. Written fresh into the unit's runtime directory.
  mkOpts = ''
    umask 077
    printf -- '-h ${host}\n-u %s\n-P %s\n' "$MQTT_USER" "$MQTT_PASS" > "$RUNTIME_DIRECTORY/opts"
    pub() { mosquitto_pub -o "$RUNTIME_DIRECTORY/opts" -r "$@"; }
  '';

  listen = pkgs.writeShellApplication {
    name = "ha-agent-listen";
    runtimeInputs = [ pkgs.mosquitto pkgs.systemd ];
    text = ''
      ${mkOpts}
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (t: p: "pub -t '${t}' -m '${p}'") discovery
      )}
      pub -t '${avail}' -m online

      # -R skips retained commands so a stale "suspend" can't fire on restart.
      mosquitto_sub -o "$RUNTIME_DIRECTORY/opts" -k 30 -R -t '${base}/command' \
        --will-topic '${avail}' --will-payload offline --will-retain |
        while read -r cmd; do
          if [ "$cmd" = suspend ]; then
            pub -t '${avail}' -m offline
            systemctl suspend
          fi
        done
    '';
  };

  report = pkgs.writeShellApplication {
    name = "ha-agent-report";
    runtimeInputs = [ pkgs.mosquitto pkgs.procps ];
    text = ''
      ${mkOpts}
      state() { if pgrep -f "$1" >/dev/null; then echo ON; else echo OFF; fi; }
      # Sunshine runs through a wrapper, so match the binary path, not comm.
      pub -t '${base}/sunshine' -m "$(state '(^|/)\.?sunshine(-wrapped)?( |$)')"
      pub -t '${base}/steam' -m "$(state '(^|/)steam( |$)')"
    '';
  };

  common = {
    EnvironmentFile = "/etc/ha-agent/mqtt.env";
    RuntimeDirectory = "ha-agent-%N";
  };
in
{
  systemd.services.ha-agent-listen = {
    description = "Home Assistant MQTT command listener";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = common // {
      ExecStart = lib.getExe listen;
      Restart = "always";
      RestartSec = 5;
    };
  };

  systemd.services.ha-agent-report = {
    description = "Report Sunshine and Steam state to Home Assistant";
    serviceConfig = common // {
      Type = "oneshot";
      ExecStart = lib.getExe report;
    };
  };

  systemd.timers.ha-agent-report = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "30s";
    };
  };

  # Reconnect right away so HA sees "online" after wake instead of waiting for
  # the keepalive to notice.
  powerManagement.resumeCommands = ''
    systemctl restart --no-block ha-agent-listen.service
  '';
}
