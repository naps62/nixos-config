{ inputs, pkgs, ... }:
{
  networking = {
    networkmanager = {
      enable = true;
    };

  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # environment.etc.nsswitch.text = {
  #   hosts = [
  #     "files"
  #     "mdns4_minimal"
  #     "[NOTFOUND=return]"
  #     "dns"
  #   ];
  # };
}
