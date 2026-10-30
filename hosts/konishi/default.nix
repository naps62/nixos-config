{
  pkgs,
  lib,
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
    ../common/features/display/plasma.nix
    ../common/features/pipewire.nix
    ../common/features/docker.nix
    ../common/features/fonts.nix
    ../common/features/kdeconnect.nix
    ../common/features/nix-ld.nix
    ../common/features/bluetooth.nix
    ../common/features/ledger.nix
    ../common/features/wine.nix
    ../common/features/gaming
    ../common/features/gaming/gaming-mode.nix
    ../common/features/gaming/session-watch.nix
    ../common/features/appimage.nix
    ../common/features/flatpak.nix
    ../common/features/smb-mounts.nix
    ../common/features/transmission.nix
    ../common/features/ydotool.nix
    ../common/features/udisks.nix
    ../common/features/home
    ../common/features/ha-agent.nix
  ];

  networking.hostName = "konishi";

  # Boot time: this box is gaming-first, so nothing here should delay the
  # session. Hold Space at boot to get the systemd-boot menu back.
  boot.loader.timeout = 0;

  # Hide boot text: the console only shows Gaming Mode starting.
  boot.consoleLogLevel = 0;
  # spinner, not the default bgrt: bgrt shows the firmware logo, which the BIOS
  # has disabled here.
  boot.plymouth = {
    enable = true;
    theme = "spinner";
  };
  boot.kernelParams = [
    "quiet"
    "loglevel=3"
    "udev.log_level=3"
    "systemd.show_status=false"
    "vt.global_cursor_default=0"
  ];

  # Starts on first `docker` use via docker.socket. Containers with a restart
  # policy do not come back until then.
  virtualisation.docker.enableOnBoot = false;

  networking.modemmanager.enable = false;

  systemd.services.transmission.wantedBy = lib.mkForce [ ];

  # The refresh timer is Persistent, so it fired at every boot.
  systemd.timers.fwupd-refresh.timerConfig.Persistent = lib.mkForce false;

  systemd.services.NetworkManager-wait-online.enable = false;

  # Runs 3 minutes after boot instead of competing with the session. After an
  # NVIDIA bump, Flatpak GL apps fail until it has run.
  systemd.services.flatpak-managed-install.wantedBy = lib.mkForce [ ];
  systemd.timers.flatpak-managed-install = {
    wantedBy = [ "timers.target" ];
    timerConfig.OnBootSec = "3min";
  };

  # Set here rather than in hardware-configuration.nix so it survives a
  # nixos-generate-config regeneration; the list merges with that file's.
  fileSystems."/".options = [ "noatime" ];

  # NAS media share and yolo VM — reachable only over the wg-home VPN. Not
  # automounted here: anything touching /mnt blocked the session while the VPN
  # was down. Connect the VPN, then `sudo mount /mnt/media` (or /mnt/yolo).
  custom.smbMounts = [
    {
      server = "10.6.10.45";
      share = "media";
      mountPoint = "/mnt/media";
      automount = false;
    }
    {
      # yolo VM's /home/naps62 (share defined in hosts/yolo/default.nix).
      server = "10.7.10.2";
      share = "home";
      mountPoint = "/mnt/yolo";
      automount = false;
    }
  ];

  # Arm Wake-on-LAN (magic packet) on the Intel igc NIC and re-apply it on every
  # boot — the driver resets WoL state otherwise. Lets Moonlight wake this box
  # from suspend to stream. NOTE: also needs "Wake on LAN" enabled in BIOS (and
  # ErP/deep-S5 disabled if you want wake from full power-off, not just suspend).
  networking.interfaces.enp5s0.wakeOnLan.enable = true;

  # Boot straight into Gaming Mode (gamescope + Steam): SDDM auto-logs naps62 in
  # to the gamescope session, so Sunshine (a user service that needs a session)
  # is up after a cold boot or Wake-on-LAN and Moonlight lands on Steam. autoStart
  # also lets steamos-manager switch sessions, which "Switch to Desktop" needs;
  # that goes to Hyprland, and logging out of it returns to Gaming Mode. Safe
  # without a lock screen: no full-disk encryption here, and streaming needs a
  # paired Moonlight client. konishi-only — never arrakis.
  jovian.steam = {
    autoStart = true;
    desktopSession = "hyprland";
  };

  custom.gamingMode.output = "DP-1";

  networking.nameservers = [
    "100.100.100.100"
    "10.1.10.1"
  ];
}
