{
  inputs,
  pkgs,
  config,
  ...
}:
let
  tuigreet = "${pkgs.greetd.tuigreet}/bin/tuigreet";
  hyprland-session = "${pkgs.hyprland}/share/wayland-sessions";
in
{
  imports = [
    ./hardware-configuration.nix
    ../common/global
    ../common/features/networking.nix
    ../common/features/nvidia.nix
    ../common/features/wayland.nix
    ../common/features/pipewire.nix
    ../common/features/docker.nix
    ../common/features/fonts.nix
    ../common/features/nix-ld.nix
    ../common/features/bluetooth.nix
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
    extraGroups = [
      "networkmanager"
      "input"
      "wheel"
      "docker"
    ];
    shell = pkgs.zsh;
    initialHashedPassword = "$y$j9T$uRTzF/sBdrqVGZTRhPuR00$wgLgEGlq.lEmlCPiy69jkbtfC9HKpyaVPDHDdBGtE5D";
    openssh.authorizedKeys.keys =
      let
        authorizedKeys = pkgs.fetchurl {
          url = "https://github.com/naps62.keys";
          sha256 = "sha256-dP8LjaburPwfIr2jhly9rMwOLJyUkQP7Em5IKH/qXbY=";
        };
      in
      pkgs.lib.splitString "\n" (builtins.readFile authorizedKeys);
  };
}
