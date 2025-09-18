{
  lib,
  config,
  pkgs,
  ...
}:
{
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      modifier = "Mod4";
      terminal = "${pkgs.kitty}/bin/kitty";
      gaps = {
        inner = 10;
        outer = 0;
      };
      keybindings =
        let
          modifier = config.xsession.windowManager.i3.config.modifier;
        in
        lib.mkOptionDefault {
          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";

          "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          "XF86AudioMute" = "exec pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "XF86AudioMicMute" = "exec volumectl -m toggle-mute";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";
          "XF86AudioPlay" = "exec playerctl play-pause";

          "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";
          "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";

          "Print" = "exec flameshot gui";

          "${modifier}+space" = "exec launcher_t2";
        };
      bars = [
        {
          position = "top";
          statusCommand = "i3status-rs ~/.config/i3status-rust/config-default.toml";
        }
      ];
    };
    extraConfig = ''
      smart_gaps on
      hide_edge_borders smart_no_gaps

      for_window [class="kitty"] border none
      for_window [class="kitty"] gaps inner current set 0
      for_window [class="kitty"] gaps outer current set 0

      for_window [class="^zen"] border none
      for_window [class="^zen"] gaps inner current set 0
      for_window [class="^zen"] gaps outer current set 0
    '';
  };

  programs = {
    i3status-rust = {
      enable = true;
    };
  };

  # services.picom = {
  #   enable = true;
  #   backend = "glx";
  #   vSync = true;
  # };

  services.flameshot = {
    enable = true;

    settings.General = {
      drawFontSize = 10;
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };
}
