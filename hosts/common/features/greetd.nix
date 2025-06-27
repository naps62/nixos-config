{ inputs, pkgs, ... }:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  hyprland-session = "${pkgs.hyprland}/share/wayland-sessions";
  session-dirs = lib.concatStringsSep ":" [
    "${pkgs.hyprland}/share"
    "${pkgs.gnome.gnome-session}/share"
    "${pkgs.xorg.xinit}/share"
    "/usr/share"
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
        --sessions /usr/share/wayland-sessions:/usr/share/xsessions \
        --remember --time \
        --cmd /etc/greetd/xsession
    '')
  ];

  environment.etc."greetd/xsession".text = ''
    #!/bin/sh
    case "$1" in
      *wayland*) export XDG_SESSION_TYPE=wayland ;;
      *) export XDG_SESSION_TYPE=x11;;
    esac
  '';
}
