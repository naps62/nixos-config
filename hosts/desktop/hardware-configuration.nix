# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "vmd"
    "xhci_pci"
    "ahci"
    "nvme"
    "thunderbolt"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/c8b56d56-3482-48d4-a8dd-825c4c2cf10e";
    fsType = "ext4";
  };

  boot.initrd.luks.devices = {
    "luks-51347cdc-de81-4132-b21c-f1d089e387eb".device = "/dev/disk/by-uuid/51347cdc-de81-4132-b21c-f1d089e387eb";
    "luks-9ffb64c6-54c2-46f2-9df5-e42c33a52d1a".device = "/dev/disk/by-uuid/9ffb64c6-54c2-46f2-9df5-e42c33a52d1a";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D86A-A762";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/mapper/luks-9ffb64c6-54c2-46f2-9df5-e42c33a52d1a"; }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp5s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
