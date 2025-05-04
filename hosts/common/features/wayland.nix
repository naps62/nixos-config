{ inputs, pkgs, ... }:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  hyprland-session = "${pkgs.hyprland}/share/wayland-sessions";
in
{
  programs.hyprland.enable = true;
  environment.systemPackages = [
    pkgs.wl-clipboard
  ];

  environment.etc."greetd/sessions/i3.desktop".text = ''
    [Desktop Entry]
    Name=i3
    Exec=i3
    Type=Application
  '';

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${tuigreet} --time --remember --remember-session --sessions ${hyprland-session} --xsessions /etc/greetd/sessions/i3.desktop";
        user = "greeter";
      };
    };
  };

  # thumbnail support for images
  services.tumbler.enable = true;

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
}
