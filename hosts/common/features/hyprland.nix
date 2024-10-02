{ inputs, pkgs, ... }:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  hyprland-session = "${pkgs.hyprland}/share/wayland-sessions";
in {
  programs.hyprland.enable = true;

  environment.systemPackages = [ pkgs.hyprcursor ];

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command =
          "${tuigreet} --time --remember --remember-session --sessions ${hyprland-session}";
        user = "greeter";
      };
    };
  };
}
