{ inputs, pkgs, ... }:
{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./nix.nix
    ./ssh.nix
  ];

  environment.systemPackages = with pkgs; [
    python3
    gcc
    gnumake
  ];

  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
    ];
  };

  time = {
    timeZone = "Europe/Lisbon";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "pt_PT.UTF-8";
      LC_IDENTIFICATION = "pt_PT.UTF-8";
      LC_MEASUREMENT = "pt_PT.UTF-8";
      LC_MONETARY = "pt_PT.UTF-8";
      LC_NAME = "pt_PT.UTF-8";
      LC_NUMERIC = "pt_PT.UTF-8";
      LC_PAPER = "pt_PT.UTF-8";
      LC_TELEPHONE = "pt_PT.UTF-8";
      LC_TIME = "pt_PT.UTF-8";
    };
  };

  services.dbus.packages = with pkgs; [ gcr ];
}
