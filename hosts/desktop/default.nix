{
  inputs,
  pkgs,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../common/global
    ../common/features/networking.nix
    ../common/features/gpu/nvidia.nix
    ../common/features/display
    ../common/features/pipewire.nix
    ../common/features/docker.nix
    ../common/features/fonts.nix
    ../common/features/nix-ld.nix
    ../common/features/bluetooth.nix
    ../common/features/ledger.nix
    ../common/features/android-studio.nix
    ../common/features/wine.nix
    ../common/features/home
  ];

  networking.hostName = "konishi";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernel.sysctl = {
      "net.ipv6.conf.all.disable_ipv6" = 1;
    };
  };

  system.stateVersion = "24.05";

  programs.zsh.enable = true;

  services.xserver.displayManager.sessionCommands = ''
    BOTTOM='HDMI-0'
    TOP='DP-0'
    RIGHT='DP-2'

    ${pkgs.xorg.xrandr}/bin/xrandr --output $BOTTOM --primary --mode 3840x2160 --pos 0x0 --rotate normal --output $TOP --mode 3840x2160 --above $BOTTOM --rotate normal --output $RIGHT --mode 3840x2160 --pos 3840x-1680 --rotate left
    ${pkgs.xorg.xrandr}/bin/xrandr --dpi 160
  '';

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
          sha256 = "sha256-+Tkks+tpB2LJQQiyYd7HOdTjHZfr653HSgb1up0JDIQ=";
        };
      in
      pkgs.lib.splitString "\n" (builtins.readFile authorizedKeys);
  };

  networking.nameservers = [
    "100.100.100.100"
    "10.1.10.1"
  ];
}
