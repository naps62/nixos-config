{ inputs, pkgs, modulesPath, nixpkgs, lib, ... }: {
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../common/global
    ../common/features/hyprland.nix
    ../common/features/docker.nix
    ../common/features/desktop-apps.nix
  ];
}
