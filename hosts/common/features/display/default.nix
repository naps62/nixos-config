{ inputs, pkgs, ... }:
{
  imports = [
    ./wayland.nix
    ./x11.nix
    ./gdm.nix
  ];
}
