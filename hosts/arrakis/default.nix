{
  inputs,
  pkgs,
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

  users.users.naps62.extraGroups = [ "video" ];

  # IPU6 webcam — kernel/firmware support only
  # Camera works via libcamera (cam -l, cam -c 1 --capture) but no
  # reliable browser integration yet without always-on LED
  hardware.firmware = [ pkgs.ivsc-firmware ];
  environment.systemPackages = [ pkgs.libcamera ];

  services.fprintd.enable = true;
}
