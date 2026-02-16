{ inputs, pkgs, ... }:
{
  imports = [
    ./wayland.nix
    ./gdm.nix
  ];
}
