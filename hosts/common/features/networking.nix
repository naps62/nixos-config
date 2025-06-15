{ inputs, pkgs, ... }:
{
  networking = {
    networkmanager = {
      enable = true;
    };

  };

  services.avahi = {
    enable = true;
    nssmdns = true;
    openFirewall = true;
  };

  services.nfs.client.enable = true;

  # environment.etc.nsswitch.text = {
  #   hosts = [
  #     "files"
  #     "mdns4_minimal"
  #     "[NOTFOUND=return]"
  #     "dns"
  #   ];
  # };
}
