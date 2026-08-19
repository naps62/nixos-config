{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.custom.hyprland;

  # Every length in the stylesheet goes through this, so one option resizes the
  # whole dashboard for 4K hosts.
  px = n: "${toString (builtins.ceil (n * cfg.panelScale))}px";

  mkScript =
    name: runtimeInputs:
    pkgs.writeShellApplication {
      inherit name runtimeInputs;
      text = builtins.readFile (./scripts + "/${name}.sh");
    };

  battery = mkScript "battery" [
    pkgs.coreutils
    pkgs.findutils
    pkgs.jq
  ];
  network = mkScript "network" [
    pkgs.networkmanager
    pkgs.gawk
    pkgs.gnused
    pkgs.jq
  ];
  bluetooth = mkScript "bluetooth" [
    pkgs.bluez
    pkgs.coreutils
    pkgs.findutils
    pkgs.gawk
    pkgs.jq
  ];
  audio = mkScript "audio" [
    pkgs.gawk
    pkgs.jq
    pkgs.wireplumber
  ];
  panelToggle = mkScript "eww-panel" [
    config.programs.eww.package
    pkgs.jq
    inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
  ];

  eww = lib.getExe config.programs.eww.package;
  bluetoothctl = "${pkgs.bluez}/bin/bluetoothctl";
  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  wpaperctl = "${pkgs.wpaperd}/bin/wpaperctl";

  # setsid, and before the close rather than after it: eww kills the onclick
  # handler's process group when the window it came from goes away, so a bare
  # `close panel; cmd` never reaches cmd.
  act = cmd: "${pkgs.util-linux}/bin/setsid --fork ${cmd}; ${eww} close panel";
in
{
  home.packages = [
    panelToggle
    pkgs.waypaper
  ];

  programs.eww = {
    enable = true;

    systemd.enable = true;

    yuckConfig = ''
      ;; Each script prints one JSON object; widgets read .icon / .label / .sub
      ;; off it.
      (defpoll clock-time :interval "10s" :initial "--:--" `date +%H:%M`)
      (defpoll clock-date :interval "1h"  :initial ""      `date "+%A, %d %B"`)

      (defpoll battery
        :interval "30s"
        :initial '{"present":false,"icon":"","label":"","sub":""}'
        `${lib.getExe battery}`)

      (defpoll network
        :interval "10s"
        :initial '{"icon":"","label":"...","sub":""}'
        `${lib.getExe network}`)

      (defpoll bluetooth
        :interval "10s"
        :initial '{"powered":false,"icon":"","label":"...","sub":""}'
        `${lib.getExe bluetooth}`)

      (defpoll speaker
        :interval "2s"
        :initial '{"present":false,"volume":0,"muted":true,"icon":""}'
        `${lib.getExe audio} sink`)

      (defpoll mic
        :interval "2s"
        :initial '{"present":false,"volume":0,"muted":true,"icon":""}'
        `${lib.getExe audio} source`)

      (defwidget card [title]
        (box :class "card" :orientation "v" :space-evenly false
          (label :class "card-title" :halign "start" :text title :visible {title != ""})
          (box :orientation "v" :space-evenly false
            (children))))

      (defwidget row [icon label sub onclick]
        (eventbox :class "row" :cursor "pointer" :onclick onclick
          (box :space-evenly false
            (label :class "row-icon" :text icon)
            (box :orientation "v" :space-evenly false :hexpand true
              (label :class "row-label" :halign "start" :text label)
              (label :class "row-sub" :halign "start" :text sub :visible {sub != ""})))))

      ;; Mute button, slider, readout. `state` is the speaker/mic json object.
      (defwidget volume [state node]
        (box :space-evenly false :visible {state.present}
          (button :class {state.muted ? "mute muted" : "mute"}
                  :onclick "${wpctl} set-mute ''${node} toggle"
                  {state.icon})
          (scale :class "slider" :hexpand true
                 :value {state.volume} :min 0 :max 101
                 :onchange "${wpctl} set-volume ''${node} {}%")
          (label :class "row-sub" :text {"''${state.volume}%"})))

      (defwidget action [icon tooltip onclick]
        (button :class "action" :tooltip tooltip :onclick onclick icon))

      (defwidget dashboard []
        (box :class "dash" :orientation "v" :space-evenly false

          (box :space-evenly false

            (card :title ""
              (label :class "clock-time" :halign "start" :text clock-time)
              (label :class "clock-date" :halign "start" :text clock-date))

            (card :title "System"
              (box :visible {battery.present} :space-evenly false
                (row :icon {battery.icon} :label {battery.label}
                     :sub {battery.sub} :onclick ""))
              (row :icon {network.icon} :label {network.label} :sub {network.sub}
                   :onclick "${act "${pkgs.networkmanagerapplet}/bin/nm-connection-editor"}")
              (row :icon {bluetooth.icon} :label {bluetooth.label} :sub {bluetooth.sub}
                   :onclick "${act "${pkgs.blueman}/bin/blueman-manager"}")))

          (box :space-evenly false

            (card :title "Audio"
              (volume :state speaker :node "@DEFAULT_AUDIO_SINK@")
              (volume :state mic :node "@DEFAULT_AUDIO_SOURCE@"))

            (card :title "Actions"
              (box :space-evenly false :halign "start"
                (action :icon "󰑐" :tooltip "Next wallpaper"
                        :onclick "${wpaperctl} next")
                (action :icon "󰸉" :tooltip "Pick wallpaper"
                        :onclick "${act "${lib.getExe pkgs.waypaper}"}")
                (action :icon "󰂯" :tooltip "Toggle bluetooth"
                        :onclick {bluetooth.powered
                                  ? "${bluetoothctl} power off"
                                  : "${bluetoothctl} power on"})
                (action :icon "󰌾" :tooltip "Lock"
                        :onclick "${act "${pkgs.systemd}/bin/loginctl lock-session"}"))))))

      ;; Sized to its content. A full-screen backdrop would give click-outside-
      ;; to-close, but its handler also fires for clicks on the sliders.
      (defwindow panel
        :namespace "eww-panel"
        :geometry (geometry :anchor "center")
        :stacking "overlay"
        (dashboard))
    '';

    scssConfig = ''
      $bg:     rgba(46, 52, 64, 0.96);
      $card:   rgba(59, 66, 82, 0.72);
      $border: #4c566a;
      $fg:     #eceff4;
      $muted:  #81a1c1;
      $accent: #88c0d0;
      $red:    #bf616a;

      * {
        all: unset;
        font-family: "FiraCode Nerd Font", monospace;
      }

      window {
        background-color: transparent;
      }

      .dash {
        background-color: $bg;
        border: ${px 1} solid $border;
        border-radius: ${px 20};
        padding: ${px 14};
        color: $fg;
      }

      .card {
        background-color: $card;
        border-radius: ${px 14};
        padding: ${px 16};
        margin: ${px 6};
        min-width: ${px 300};
      }

      .card-title {
        font-size: ${px 11};
        color: $muted;
        margin-bottom: ${px 8};
      }

      .clock-time {
        font-size: ${px 56};
        font-weight: 600;
      }

      .clock-date {
        font-size: ${px 14};
        color: $muted;
      }

      .row {
        border-radius: ${px 10};
        padding: ${px 10} ${px 12};

        &:hover {
          background-color: rgba(136, 192, 208, 0.14);
        }
      }

      .row-icon {
        font-size: ${px 22};
        color: $accent;
        min-width: ${px 34};
      }

      .row-label {
        font-size: ${px 14};
      }

      .row-sub {
        font-size: ${px 11};
        color: $muted;
      }

      .mute {
        font-size: ${px 20};
        color: $accent;
        min-width: ${px 34};

        &.muted {
          color: $red;
        }
      }

      .slider {
        margin: 0 ${px 12};
        min-width: ${px 180};

        trough {
          background-color: rgba(76, 86, 106, 0.6);
          border-radius: ${px 8};
          min-height: ${px 8};

          highlight {
            background-color: $accent;
            border-radius: ${px 8};
          }
        }
      }

      .action {
        background-color: rgba(76, 86, 106, 0.45);
        border-radius: ${px 12};
        padding: ${px 12} ${px 18};
        margin-right: ${px 8};
        font-size: ${px 20};
        color: $fg;

        &:hover {
          background-color: $accent;
          color: #2e3440;
        }
      }
    '';
  };
}
