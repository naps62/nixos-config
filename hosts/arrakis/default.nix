{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    inputs.hardware.nixosModules.dell-xps-13-9315
    ./hardware-configuration.nix
    ../common/global
    ../common/features/laptop.nix
    ../common/features/networking.nix
    ../common/features/gpu/intel-graphics.nix
    ../common/features/display
    ../common/features/pipewire.nix
    ../common/features/docker.nix
    ../common/features/fonts.nix
    ../common/features/nix-ld.nix
    ../common/features/bluetooth.nix
    ../common/features/ledger.nix
    ../common/features/android-studio.nix
    ../common/features/tailscale.nix
  ];

  networking.hostName = "arrakis";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [
      "i915=force_probe=46a6"
      "i915.enable_psr=0"
    ];
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
      "dialout"
    ];
    shell = pkgs.zsh;
    initialHashedPassword = "$y$j9T$uRTzF/sBdrqVGZTRhPuR00$wgLgEGlq.lEmlCPiy69jkbtfC9HKpyaVPDHDdBGtE5D";
    openssh.authorizedKeys.keys =
      let
        authorizedKeys = pkgs.fetchurl {
          url = "https://github.com/naps62.keys";
          sha256 = "sha256-L90zBt9vR4TqKj9wN2QsCvja4StgJsm/rdHuQSC9Mlg=";
        };
      in
      pkgs.lib.splitString "\n" (builtins.readFile authorizedKeys);
  };

  hardware.ipu6 = {
    enable = true;
    platform = "ipu6ep";
  };
}
