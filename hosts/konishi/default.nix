{
  pkgs,
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
    ../common/features/wine.nix
    ../common/features/gaming
    ../common/features/appimage.nix
    ../common/features/home
  ];

  networking.hostName = "konishi";

  # Arm Wake-on-LAN (magic packet) on the Intel igc NIC and re-apply it on every
  # boot — the driver resets WoL state otherwise. Lets Moonlight wake this box
  # from suspend to stream. NOTE: also needs "Wake on LAN" enabled in BIOS (and
  # ErP/deep-S5 disabled if you want wake from full power-off, not just suspend).
  networking.interfaces.enp5s0.wakeOnLan.enable = true;

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
