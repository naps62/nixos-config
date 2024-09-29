{ inputs, pkgs, ... }:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  hyprland-session = "${pkgs.hyprland}/share/wayland-sessions";
in {
  imports = [
    ./hardware-configuration.nix
    ../common/global
    ../common/features/networking.nix
    ../common/features/hyprland.nix
    ../common/features/docker.nix
    ../common/features/desktop-apps.nix
    ../common/features/syncthing.nix
  ];

  networking.hostName = "arrakis";

  boot = {
    loader = {
      grub = {
        enable = true;
        device = "/dev/vda";
        useOSProber = true;
      };
    };
  };

  system.stateVersion = "24.05";

  programs.zsh.enable = true;

  users.users.naps62 = {
    isNormalUser = true;
    description = "Miguel Palhas";
    extraGroups = [ "networkmanager" "input" "wheel" "docker" ];
    shell = pkgs.zsh;
    hashedPassword =
      "$y$j9T$0p/ZYQsSA/FroVjV59pI/0$LKyzass6W9GjJR0GLWI6xhVrLi0b5AYYMR3MvQKNK11";
  };

  fileSystems."mnt/nfs" = {
    device = "192.168.122.1:/home/naps62/projects/nixos";
    fsType = "nfs";
    options = [ "rw" "soft" ];
  };
}
