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
    ../common/features/user.nix
    ../common/features/laptop.nix
    ../common/features/networking.nix
    ../common/features/gpu/intel-graphics.nix
    ../common/features/display
    ../common/features/pipewire.nix
    ../common/features/docker.nix
    ../common/features/appimage.nix
    ../common/features/fonts.nix
    ../common/features/nix-ld.nix
    ../common/features/bluetooth.nix
    ../common/features/ledger.nix
    ../common/features/android-studio.nix
    ../common/features/home
  ];

  networking.hostName = "arrakis";

  boot.kernelParams = [
    "i915=force_probe=46a6"
    "i915.enable_psr=0"
  ];

  hardware.ipu6 = {
    enable = true;
    platform = "ipu6ep";
  };

  services.fprintd.enable = true;
}
