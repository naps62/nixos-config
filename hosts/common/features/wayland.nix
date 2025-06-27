{ inputs, pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.wl-clipboard
  ];

  # thumbnail support for images
  services.tumbler.enable = true;

  nix.settings = {
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
}
