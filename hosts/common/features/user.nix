{ pkgs, ... }:
{
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
      "adbusers"
      "kvm"
    ];
    shell = pkgs.zsh;
    initialHashedPassword = "$y$j9T$uRTzF/sBdrqVGZTRhPuR00$wgLgEGlq.lEmlCPiy69jkbtfC9HKpyaVPDHDdBGtE5D";
    openssh.authorizedKeys.keys =
      let
        authorizedKeys = pkgs.fetchurl {
          url = "https://github.com/naps62.keys";
          sha256 = "sha256-sjZVywzw6q4v0QMkOpjxnjAz1MononyY+qtEFX2U8hI=";
        };
      in
      pkgs.lib.splitString "\n" (builtins.readFile authorizedKeys);
  };

  boot.loader = {
    systemd-boot.enable = true;
    # Cap boot menu entries so old generations don't accumulate forever
    # (GC prunes the store; this prunes the boot entries).
    systemd-boot.configurationLimit = 20;
    efi.canTouchEfiVariables = true;
  };

  system.stateVersion = "24.05";
}
