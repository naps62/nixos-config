{ config, pkgs, ... }: {
  home.packages = [ pkgs.eww ];
  xdg.configFile = {
    "eww/eww.yuck".text = ''
      ;; Variables
      (defpoll clock_time :interval "5s" "date +\%I:%M")
      (defpoll clock_date :interval "1m" "date '+%d/%m'")
      (defpoll volume_percent :interval "3s" :initial 0 "pactl get-sink-volume @DEFAULT_SINK@ | head -n1 | cut -d'/' -f 2 | xargs | tr -d '%'")
      ;; (defpoll brightness_percent :interval "5s" "brightnessctl -m -d intel_backlight | awk -F, '{print substr($4, 0, length($4)-1)}' | tr -d '%'")
      (defpoll bwindowrulesattery :interval "15s" "./scripts/battery --bat")
      (defpoll battery_status :interval "1m" "./scripts/battery --bat-st")
      (defpoll memory :interval "5s" :initial 0 "scripts/memory")
      (defpoll cpu :interval "5s" :initial 0 "scripts/cpu")
      (defpoll cputemp :interval "5s" :initial 0 "scripts/cputemp")
      (defpoll memory_used_mb :interval "2m" "scripts/mem-ad used")
      (defpoll memory_total_mb :interval "2m" "scripts/mem-ad total")
      (defpoll memory_free_mb :interval "2m" "scripts/mem-ad free")
      (defvar bar_hover false)
      (deflisten workspace "scripts/workspace")

      (defvar eww "/home/naps62/.bin/eww -c $HOME/.config/eww")
      (defvar exec_audio_control "hyprctl dispatch exec '[center]' pavucontrol")
      (defvar exec_nmtui "hyprctl dispatch exec '[center]' 'kitty --class eww-nmtui -e nmtui'")
      (defvar exec_workspace_scroll "echo {} | sed -e 's/up/-1/g' -e 's/down/+1/g' | xargs hyprctl dispatch workspace")

      (defpoll network_name :interval "1m" "~/.config/eww/scripts/network name")
      (defpoll network_icon :interval "1m" "~/.config/eww/scripts/network icon")
      (defpoll network_class :interval "1m" "~/.config/eww/scripts/network class")

      ;;
      ;; widgets
      ;;

      (defwidget widget_network [] 
      (box :class "network" :space-evenly "false"
        (button :class "${network_class}" :onclick exec_nmtui "${network_icon} ${network_name}")))


      (defwidget widget_workspaces []
        (eventbox :onscroll exec_workspace_scroll
          (literal :content workspace))
        )

      ;; (defwidget widget_battery []
      ;;   (circular-progress :value battery
      ;;       :class "circle battery"
      ;;       :thickness 4
      ;;     (button 
      ;;         :class "icon"
      ;;         :tooltip "battery on ${battery}%"
      ;;         "󰂁")))


      (defwidget widget_cputemp []
        (circular-progress :value cputemp
            :class "circle cputemp"
            :thickness 4
          (button 
              :class "icon"
              :onclick "$HOME/.config/eww/scripts/pop system"
              "󰔏")))

      (defwidget widget_ram []
        (circular-progress :value memory
            :class "circle memory"
            :thickness 4
          (button 
              :class "icon"
              :tooltip "using ${memory}% ram"
              :onclick "$HOME/.config/eww/scripts/pop system"
              "󰍛")))

      (defwidget widget_cpu []
        (circular-progress :value cpu
            :class "circle cpu"
            :thickness 4
          (button 
              :class "icon"
              :tooltip "using ${memory}% CPU"
              :onclick "$HOME/.config/eww/scripts/pop system"
              "󰻠")))

      (defwidget widget_space []
          (box :class "space"))

      (defwidget widget_clock []
      (box :class "clock"
        (label :text clock_time :class "clock-time")
        (button :class "clock-date" clock_date)))
        
      (defwidget widget_volume []
        (box :class "volume" :space-evenly "false"
          (button :onclick exec_audio_control "󰕾")
          (scale :class "slider"
            :value volume_percent
            :tooltip "${volume_percent}%"
            :max 100
            :min 0
            :onchange "pactl set-sink-volume @DEFAULT_SINK@ {}%" )))

      ;; (defwidget widget_bright []
      ;; (eventbox :onhover "${eww} update br_reveal=true" :onhoverlost "${eww} update br_reveal=false"
      ;;   (box :class "module-2" :space-evenly "false" :orientation "h" :spacing "3" 
      ;;     (label :text "" :class "bright_icon" :tooltip "brightness")
      ;;       (revealer :transition "slideleft"
      ;;         :reveal br_reveal
      ;;         :duration "350ms"
      ;;         (scale    :class "slider brightness"
      ;;           :value brightness_percent
      ;;           :orientation "h"
      ;;           :tooltip "${brightness_percent}%"
      ;;           :max 100
      ;;           :min 0
      ;;           :onchange "brightnessctl set {}%" )))))

      ;;
      ;; bar layout
      ;;
      (defwidget left []
        (box :orientation "h" 
          :space-evenly false  
          :halign "start"
        (widget_workspaces)))

      (defwidget center []
        (box :orientation "h" 
          :space-evenly false  
          :halign "center"
        (box)))

      (defwidget right []
        (box :orientation "h" 
          :space-evenly false  
          :halign "end"
        ;; (widget_bright)
        (widget_volume)
        (widget_network)
        (widget_space)
        ;; (widget_battery)
        (widget_ram)
        (widget_cpu)
        (widget_cputemp)
        (widget_space)
        (systray)
        (widget_space)
        (widget_clock)
        (widget_space)))

      (defwidget bar_inner []
        (box
            :orientation "h"
          (left)
          (right)))

      ;;
      ;; main window
      ;;
      (defwindow bar
        :geometry (
          geometry 
          :x "0%"
          :y "0px"
          :width "2080px"
          :anchor "top center")
        :windowtype "dock"
        :monitor 0
        :exclusive true
      (bar_inner))
    '';
    "eww/eww.scss".text = ''
      //
      // catppuccin-mocha
      //
      $rosewater: #f5e0dc;
      $flamingo: #f2cdcd;
      $pink: #ff3ac6;
      $mauve: #cba6f7;
      $red: #f38ba8;
      $maroon: #eba0ac;
      $peach: #f9e2af;
      $yellow: #f9e2af;
      $green: #a6e3a1;
      $teal: #94e2d5;
      $sky: #89dceb;
      $sapphire: #74c7ec;
      $blue: #89b4fa;
      $lavender: #b4befe;
      $text: #cdd6f4;
      $subtext1: #bac2de;
      $subtext0: #a6adc8;
      $overlay2: #9399b2;
      $overlay1: #7f849c;
      $overlay0: #6c7086;
      $surface2: #585b70;
      $surface1: #45475a;
      $surface0: #313244;
      $base: #1e1e2e;
      $mantle: #181825;
      $crust: #11111b;

      :not(menu):not(menuitem) {
        all: unset;
        font-family:
          Material Design Icons,
          FiraCode Nerd Font;
      }

      //
      // color theming
      //

      tooltip.background,
      .window,
      menu,
      menuitem,
      .bar {
        background-color: $crust;
      }

      .memory * {
        color: $mauve;
      }
      .cpu * {
        color: $peach;
      }
      .cputemp * {
        color: $red;
      }
      .battery * {
        color: $red;
      }

      .clock {
        color: $text;
      }

      //
      // General
      //

      .bar {
        // min-height: 30px;
        font-size: 16;
        transition: all 0.1s ease-out;
        border-radius: 0px 0px 10 10;
      }

      .bar {
        opacity: 1;
      }

      .space {
        margin: 0px 10px;
      }

      //
      // tooltip
      //

      tooltip.background {
        border-radius: 10px;
      }

      tooltip label {
      }

      //
      // clock
      //

      .clock-time {
        font-weight: bold;
        margin-right: 5px;
      }

      //
      // circular bars
      //

      .circle {
        border-radius: 10px;
        margin: 0 5;
      }

      .circle .icon {
        font-size: 16px;
        padding: 10px;
      }

      //
      // sliders
      //

      .slider,
      .slider trough highlight {
        border-radius: 10px;
      }

      //
      // network
      //

      .network,
      .volume {
        margin: 0 5px;

        & button {
          margin-right: 10;
        }

        .connected {
          color: $green;
        }

        .disconnected {
          color: $peach;
        }
      }

      //
      // brightness
      //

      .bright_icon {
        font-size: 12;
        color: #e4c9af;
      }

      //
      // sliders
      //

      .slider trough highlight {
        background-image: linear-gradient(
          to right,
          $yellow 30%,
          $peach 50%,
          $red 100% * 50
        );
      }

      scale trough {
        background-color: $surface1;
        border-radius: 16px;
        min-height: 10px;
        min-width: 100px;
      }

      //
      // systray
      //

      menu  {
        border-radius: 16px;
      }

      menuitem {
        padding: 8px;
        border-radius: 8px;
        color: $text;
          background-color: $surface2;

        &:disabled {
          color: $overlay2;
        }
      }

      //
      // workspaces
      //

      .w0,
      .w01,
      .w02,
      .w03,
      .w04,
      .w05,
      .w06,
      .w011,
      .w022,
      .w033,
      .w044,
      .w055,
      .w066 {
        border-radius: 10px;
        font-size: 16px;
        padding: 5px 5;
        min-height: 25px;
        min-width: 60px;
      }

      // Unoccupied
      .w0 {
        color: $overlay0;
      }

      // Occupied
      .w01,
      .w02,
      .w03,
      .w04,
      .w05,
      .w06 {
        color: $text;
      }

      // Focused
      .w011,
      .w022,
      .w033,
      .w044,
      .w055,
      .w066 {
        font-size: 16px;
        background-color: $sky;
        color: $crust;
        font-weight: bold;
      }
    '';
  };
}
