{ pkgs, ... }:
{
  users.users.naps62.extraGroups = [
    "kvm"
    "adbusers"
  ];

  programs.adb.enable = true;

  services.udev.packages = with pkgs; [
    android-udev-rules
  ];

  environment.systemPackages = with pkgs; [
    android-studio
  ];
}
