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
    ../common/features/pipewire.nix
    ../common/features/docker.nix
    ../common/features/fonts.nix
    ../common/features/syncthing.nix
  ];

  networking.hostName = "arrakis";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
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

  services.nfs.server.enable = true;
}
