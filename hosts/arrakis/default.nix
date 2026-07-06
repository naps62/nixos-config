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
    ../common/features/smb-mounts.nix
    ../common/features/home
  ];

  networking.hostName = "arrakis";

  # NAS media share — reachable only over the wg-home VPN. Lazy automount, so it
  # never blocks boot and (re)mounts on first access once the VPN is up.
  custom.smbMounts = [
    {
      server = "10.6.10.45";
      share = "media";
      mountPoint = "/mnt/media";
    }
  ];

  boot.kernelParams = [
    "i915=force_probe=46a6"
    "i915.enable_psr=0"
  ];

  users.users.naps62.extraGroups = [ "video" ];

  # IPU6 webcam (Dell XPS 9320, Alder Lake, ov01a10 sensor).
  # Uses Intel's hardware ISP via the official hardware.ipu6 module: the
  # proprietary HAL (ipu6-camera-bins/-hal + icamerasrc) feeds v4l2-relayd,
  # which exposes a normal /dev/video50 ("Intel MIPI Camera") that works in
  # every app (Chrome, Zen, mpv, OBS, ...). The module also hides the 32 raw
  # IPU6 nodes from WirePlumber/udev, which is what unbreaks Chrome.
  #
  # The relay is on-demand (v4l2-relayd opens the sensor only when an app opens
  # the loopback device), so the LED should follow usage rather than stay on.
  #
  # Bare libcamera still works as a fallback (software ISP, poor quality):
  #   libcamerify mpv av://v4l2:/dev/video0 --profile=low-latency --untimed
  hardware.ipu6 = {
    enable = true;
    platform = "ipu6ep"; # Alder Lake / Raptor Lake
  };

  # v4l2-relayd exits whenever a consumer closes the loopback and relies on
  # systemd to restart it for the next session. The default start-limit (5
  # restarts / 10s) permanently kills it under rapid open/close (e.g. an app
  # probing the device), leaving the camera dead until a manual restart.
  # Disable the limit and throttle restarts so it always self-heals.
  systemd.services.v4l2-relayd-ipu6 = {
    startLimitIntervalSec = 0;
    serviceConfig.RestartSec = "1";
  };

  # The module's rule to lock the raw IPU6 nodes to root gets clobbered by the
  # default "video4linux -> group video" rule, so they stay user-readable and
  # Chrome hangs enumerating all 32 of them. Re-assert with ':=' (locks the
  # value against later rules), matched on the kernel-set ID_V4L_PRODUCT.
  # GROUP/MODE alone isn't enough: logind's uaccess still leaves a stale
  # "user:<you>:rw" ACL on the nodes, so also drop the uaccess tag and wipe any
  # ACL on every event (setfacl -b) to keep the raw nodes truly root-only.
  services.udev.extraRules = ''
    SUBSYSTEM=="video4linux", ENV{ID_V4L_PRODUCT}=="ipu6", GROUP:="root", MODE:="0600", TAG-="uaccess", RUN+="${pkgs.acl}/bin/setfacl -b %N"
  '';

  services.fprintd.enable = true;
}
