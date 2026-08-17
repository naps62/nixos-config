{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../common/global
    ../common/features/user.nix
    ../common/features/networking.nix
    ../common/features/display
    ../common/features/pipewire.nix
    ../common/features/remote-desktop.nix
    ../common/features/docker.nix
    ../common/features/fonts.nix
    ../common/features/nix-ld.nix
    ../common/features/appimage.nix
    ../common/features/home
  ];

  networking.hostName = "yolo";

  # Lets the Proxmox host drive clean shutdowns/reboots and report the guest's
  # IP. The qemu-guest profile in hardware-configuration.nix only sets up the
  # virtio drivers; the agent itself is a separate service.
  services.qemuGuest.enable = true;

  # Not a security downgrade: naps62 is in `docker`, which is already
  # root-equivalent, and sshd is key-only — so the prompt guards nothing while
  # blocking unattended rebuilds (nh shells out to sudo and needs a TTY).
  security.sudo.wheelNeedsPassword = false;

  # Nix shells out to git for the `type = "git"` flake inputs (hyprland).
  # Without it at system level, a fresh install cannot build the home config
  # that would have provided git — so neither rebuild works.
  environment.systemPackages = [ pkgs.git ];

  # This clone lives under ~/tea, not the ~/projects path global/nix.nix assumes.
  programs.nh.flake = lib.mkForce "/home/naps62/tea/nixos-config";

  # No physical seat: Sunshine is a user service and cannot capture until a
  # graphical session exists, so a cold boot must reach one unattended. No
  # hyprlock on start (unlike konishi) — nobody could type the password in.
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "naps62";
    };
    defaultSession = "hyprland";
  };

  # A Proxmox guest has no emulated sound card, so PipeWire starts with no sink
  # and Sunshine has nothing to capture — the stream is silent. This sink is the
  # only one, so it wins the default and Sunshine records its monitor.
  services.pipewire.extraConfig.pipewire."10-null-sink" = {
    "context.objects" = [
      {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = "sunshine-sink";
          "node.description" = "Sunshine";
          "media.class" = "Audio/Sink";
          "audio.position" = "FL,FR";
        };
      }
    ];
  };

  # Pinned to 16 to match the cluster being migrated off Ubuntu; restoring that
  # dump into a newer default would need a pg_upgrade first.
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
  };
}
