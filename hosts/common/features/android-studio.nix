{ pkgs, ... }:
{
  users.users.naps62.extraGroups = [
    "kvm"
    "adbusers"
  ];

  # services.udev.packages = with pkgs; [
  #   android-udev-rules
  # ];

  environment.systemPackages = with pkgs; [
    android-studio
    steam-run
    android-studio-tools
    nss
    vulkan-loader
    libpulseaudio
    libx11
    libxext
    libxdamage
    libxfixes
    libxi
    libxrandr
    libxtst
    libxcb
    libxcomposite
  ];
}
