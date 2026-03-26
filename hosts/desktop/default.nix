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
    ../common/features/user.nix
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
    ../common/features/appimage.nix
    ../common/features/home
  ];

  networking.hostName = "konishi";

  services.xserver.displayManager.sessionCommands = ''
    BOTTOM='HDMI-0'
    TOP='DP-0'
    RIGHT='DP-2'

    # Match Hyprland layout: TOP at 0x0, BOTTOM at 0x2160, RIGHT at 3840x180
    ${pkgs.xrandr}/bin/xrandr \
      --output $TOP --mode 3840x2160 --pos 0x0 --rotate normal \
      --output $BOTTOM --primary --mode 3840x2160 --pos 0x2160 --rotate normal \
      --output $RIGHT --mode 3840x2160 --pos 3840x180 --rotate left
    ${pkgs.xrandr}/bin/xrandr --dpi 160
  '';

  networking.nameservers = [
    "100.100.100.100"
    "10.1.10.1"
  ];
}
