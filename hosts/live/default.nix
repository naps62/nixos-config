{ inputs, pkgs, modulesPath, ... }: {
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")
    ../common/global
    ../common/docker.nix
  ];
}
