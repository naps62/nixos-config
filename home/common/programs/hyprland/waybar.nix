{ pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [
          "tray"
          "bluetooth"
          "network"
          "pulseaudio"
          "battery"
          "clock"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            "1" = "1";
            "2" = "2";
            "3" = "3";
            "4" = "4";
            "5" = "5";
            "6" = "6";
          };
          persistent-workspaces = {
            "*" = [ 1 2 3 4 5 6 ];
          };
        };

        "hyprland/window" = {
          max-length = 50;
        };

        tray = {
          icon-size = 16;
          spacing = 8;
        };

        bluetooth = {
          format = "󰂯";
          format-disabled = "󰂲";
          format-connected = "󰂱";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          on-click = "blueman-manager";
        };

        network = {
          format-wifi = "󰤨";
          format-ethernet = "󰈀";
          format-disconnected = "󰤭";
          tooltip-format-wifi = "{essid} ({signalStrength}%)";
          tooltip-format-ethernet = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format-disconnected = "Disconnected";
        };

        pulseaudio = {
          format = "{icon}";
          format-muted = "󰝟";
          format-icons = {
            default = [ "󰕿" "󰖀" "󰕾" ];
          };
          tooltip-format = "{volume}%";
          on-click = "pavucontrol";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          scroll-step = 5;
        };

        battery = {
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          states = {
            warning = 20;
            critical = 10;
          };
        };

        clock = {
          format = "{:%H:%M}";
          tooltip-format = "{:%A, %B %d, %Y}";
        };
      };
    };

    style = ''
      @define-color foreground #bac2de;
      @define-color background rgba(17, 17, 27, 0.85);
      @define-color active #b4befe;
      @define-color warning #f9e2af;
      @define-color critical #f38ba8;
      @define-color muted #6c7086;

      * {
        background-color: transparent;
        color: @foreground;
        border: none;
        border-radius: 0;
        min-height: 0;
        font-family: FiraCode Nerd Font;
        font-size: 15px;
      }

      window#waybar {
        background-color: @background;
      }

      .modules-left {
        margin-left: 10px;
      }

      .modules-right {
        margin-right: 10px;
      }

      #workspaces button {
        padding: 0 6px;
        margin: 0 2px;
        color: @muted;
      }

      #workspaces button.active {
        color: @active;
      }

      #workspaces button.urgent {
        color: @critical;
      }

      #window {
        color: @muted;
        font-size: 14px;
      }

      #tray,
      #bluetooth,
      #network,
      #pulseaudio,
      #battery,
      #clock {
        padding: 0 10px;
        color: @foreground;
      }

      #battery.warning {
        color: @warning;
      }

      #battery.critical {
        color: @critical;
      }

      #pulseaudio.muted {
        color: @muted;
      }

      tooltip {
        background-color: @background;
        border: 1px solid @muted;
        border-radius: 4px;
      }
    '';
  };
}
