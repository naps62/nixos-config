{ pkgs, ... }:
{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        # Required for LE Audio (BAP): ISO sockets / CIS live behind
        # BlueZ's experimental gate. Without this the XM6 falls back to
        # classic A2DP, and mic use forces the HSP/HFP downgrade.
        Experimental = true;
        KernelExperimental = true;
      };
    };
  };

  services.blueman.enable = true;

  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy";
    after = [
      "network.target"
      "sound.target"
    ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };
}
