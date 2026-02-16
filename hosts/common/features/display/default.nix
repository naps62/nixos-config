{ inputs, pkgs, ... }:
{
  imports = [
    ./wayland.nix
    ./sddm.nix
  ];
}
