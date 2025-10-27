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
    steam-run
    android-studio-tools
    nss
    vulkan-loader
    libpulseaudio
    xorg.libX11
    xorg.libXext
    xorg.libXdamage
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXtst
    xorg.libxcb
    xorg.libXcomposite
  ];
}
