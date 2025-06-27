{
  inputs,
  pkgs,
  lib,
  ...
}:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  hyprland-session = "${pkgs.hyprland}/share/wayland-sessions";
  session-dirs = lib.concatStringsSep ":" [
    "${pkgs.hyprland}/share/wayland-sessions"
    "${pkgs.gnome-session}/share/xsessions"
    "${pkgs.hyprland}/share"
    "${pkgs.gnome-session}/share"
    "/usr/share/wayland-sessions"
    "/usr/share/xsessions"
    "/usr/share"
    "/usr/local/share"
  ];
in
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "/run/current-system/sw/bin/greet-launcher";
        user = "greeter";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    greetd.tuigreet
    (writeShellScriptBin "greet-launcher" ''
      export XDG_DATA_DIRS=${session-dirs}
      exec ${pkgs.greetd.tuigreet}/bin/tuigreet \
        --sessions ${session-dirs} \
        --remember --time \
        --cmd /etc/greetd/xsession
    '')
  ];

  environment.etc."greetd/xsession" = {
    text = ''
      #!/bin/sh
      case "$1" in
        *wayland*) export XDG_SESSION_TYPE=wayland ;;
        *) export XDG_SESSION_TYPE=x11; export DISPLAY=:0 ;;
      esac

      exec "$1"
    '';
    mode = "0755";
  };

  security.pam.services.greetd.enable = true;
}
