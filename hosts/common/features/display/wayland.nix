{ inputs, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wl-clipboard
    hyprland
  ];

  services.displayManager.sessionPackages = with pkgs; [
    hyprland
  ];

  # thumbnail support for images
  services.tumbler.enable = true;

  environment.etc."xdg/wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=Hyprland Wayland Compositor
    Exec=Hyprland
    Type=Application
    DesktopNames=Hyprland
  '';

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
}
