{ pkgs, ... }:
{
  # services.blueman-applet.enable = true;

  # systemd.user.services.mpris-proxy = {
  #   description = "Mpris proxy";
  #   after = [
  #     "network.target"
  #     "sound.target"
  #   ];
  #   wantedBy = [ "default.target" ];
  #   serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  # };
}
