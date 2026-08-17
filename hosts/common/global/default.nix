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

  # NixOS provides /bin/sh but not /bin/bash. Some third-party scripts
  # hardcode #!/bin/bash, so provide it too.
  system.activationScripts.binbash = ''
    ln -sf ${pkgs.bash}/bin/bash /bin/bash
  '';

  # Compressed RAM swap — better behaviour under memory pressure.
  zramSwap.enable = true;

  # Periodic SSD TRIM.
  services.fstrim.enable = true;
}
