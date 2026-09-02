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
    ../common/features/kdeconnect.nix
    ../common/features/nix-ld.nix
    ../common/features/bluetooth.nix
    ../common/features/ledger.nix
    ../common/features/wine.nix
    ../common/features/gaming
    ../common/features/appimage.nix
    ../common/features/flatpak.nix
    ../common/features/smb-mounts.nix
    ../common/features/home
  ];

  networking.hostName = "konishi";

  # Set here rather than in hardware-configuration.nix so it survives a
  # nixos-generate-config regeneration; the list merges with that file's.
  fileSystems."/".options = [ "noatime" ];

  # NAS media share — reachable only over the wg-home VPN. Lazy automount, so it
  # never blocks boot and (re)mounts on first access once the VPN is up.
  custom.smbMounts = [
    {
      server = "10.6.10.45";
      share = "media";
      mountPoint = "/mnt/media";
    }
    {
      # yolo VM's /home/naps62 (share defined in hosts/yolo/default.nix).
      server = "10.7.10.2";
      share = "home";
      mountPoint = "/mnt/yolo";
    }
  ];

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

  # Boot straight into a locked Hyprland instead of the SDDM greeter: SDDM
  # auto-logs naps62 in, the session starts, and hyprlock (exec-once in the home
  # config) immediately locks it — so the first thing you see is hyprlock, the
  # one themeable lock screen. Safe on this box: no full-disk encryption means
  # SDDM-vs-autologin is a marginal boundary anyway, and it also lets Moonlight
  # reach the box after a *cold boot* (Sunshine is a user service that only runs
  # once a session exists), not just from suspend. konishi-only — never arrakis.
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "naps62";
    };
    defaultSession = "hyprland";
  };

  networking.nameservers = [
    "100.100.100.100"
    "10.1.10.1"
  ];
}
