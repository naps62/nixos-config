_:
# Homelab host aliases, yolo-only. Ported from the hand-written ~/.ssh/config
# on the Ubuntu box.
{
  programs.ssh.settings = {
    "grafana" = {
      HostName = "10.6.10.30";
      User = "root";
      IdentityFile = "~/.ssh/crowdsec-loki-10.6.10.30";
    };

    "jellyfin" = {
      HostName = "10.6.10.18";
      User = "root";
      IdentityFile = "~/.ssh/crowdsec-loki-10.6.10.30";
    };

    "authelia" = {
      HostName = "10.6.10.42";
      User = "root";
      IdentityFile = "~/.ssh/authelia-10.6.10.42";
    };

    "whisper" = {
      HostName = "10.6.10.43";
      User = "root";
      IdentityFile = "~/.ssh/wyoming-voice";
      IdentitiesOnly = true;
      StrictHostKeyChecking = "accept-new";
    };

    "proxmox" = {
      HostName = "10.1.10.3";
      Port = 22022;
      User = "root";
      IdentityFile = "~/.ssh/proxmox-temp";
      # Was `crowdsec-loki` in the hand-written config, which is no longer a
      # Host — same machine, now aliased `grafana`.
      ProxyJump = "grafana";
      StrictHostKeyChecking = "accept-new";
    };
  };
}
